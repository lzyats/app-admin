package com.ruoyi.web.controller.app;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.entity.SysUserWallet;
import com.ruoyi.common.core.domain.entity.SysUserWalletLog;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysUserService;
import com.ruoyi.system.service.ISysUserSecurityAnswerService;
import com.ruoyi.system.service.ISysUserWalletLogService;
import com.ruoyi.system.service.ISysUserWalletService;

/**
 * APP 用户控制器。
 *
 * 这里主要处理 APP 端的用户资料、支付密码、钱包兑换等接口。
 * 
 * @author ruoyi
 */
@RestController
@RequestMapping("/app/user")
public class AppUserController {

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ISysUserWalletService walletService;

    @Autowired
    private ISysUserWalletLogService walletLogService;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ISysUserSecurityAnswerService securityAnswerService;

    /**
     * 检查支付密码是否已设置。
     *
     * 仅返回当前登录用户的状态，避免前端直接依赖其他用户数据。
     *
     * @param body 请求体，兼容携带 userId，但实际以当前登录用户为准
     * @return 是否已设置
     */
    @PostMapping("/payPwd/check")
    public AjaxResult checkPayPwdSet(@RequestBody(required = false) Map<String, Object> body) {
        Long userId = SecurityUtils.getUserId();
        if (body != null && body.get("userId") != null) {
            try {
                Long requestUserId = Long.valueOf(body.get("userId").toString());
                if (!requestUserId.equals(userId)) {
                    userService.checkUserDataScope(requestUserId);
                }
            } catch (Exception ignored) {
                // 忽略非法 userId，继续使用当前登录用户
            }
        }

        SysUser user = userService.selectUserById(userId);
        boolean isSet = user != null && StringUtils.isNotBlank(user.getPayPassword());
        return AjaxResult.success(isSet);
    }

    /**
     * 获取当前用户钱包列表。
     */
    @GetMapping("/wallets")
    public AjaxResult wallets() {
        Long userId = SecurityUtils.getUserId();
        SysUserWallet query = new SysUserWallet();
        query.setUserId(userId);
        List<SysUserWallet> wallets = new ArrayList<>(walletService.selectWalletList(query));
        wallets.sort(Comparator.comparingInt(wallet -> "USD".equalsIgnoreCase(wallet.getCurrencyType()) ? 1 : 0));
        return AjaxResult.success(wallets);
    }

    /**
     * 获取当前登录用户已设置的安全问题答案。
     */
    @GetMapping("/security/my")
    public AjaxResult getMySecurityAnswers() {
        Long userId = SecurityUtils.getUserId();
        if (userId == null || userId <= 0) {
            return AjaxResult.error("User is not logged in.");
        }
        return AjaxResult.success(securityAnswerService.selectAnswerByUserId(userId));
    }

    /**
     * 币种兑换。
     */
    @PostMapping("/currency/exchange")
    @Transactional
    public AjaxResult exchangeCurrency(@RequestBody(required = false) CurrencyExchangeBody body) {
        Long userId = SecurityUtils.getUserId();
        if (userId == null || userId <= 0) {
            return AjaxResult.error("User is not logged in.");
        }

        SysUser user = userService.selectUserById(userId);
        if (user == null) {
            return AjaxResult.error("User does not exist.");
        }

        CurrencyExchangeBody request = body == null ? new CurrencyExchangeBody() : body;
        String fromCurrency = normalizeCurrencyType(request.getFromCurrency());
        String toCurrency = normalizeCurrencyType(request.getToCurrency());
        double amount = request.getAmount() == null ? 0D : request.getAmount();
        if (amount <= 0D) {
            return AjaxResult.error("Exchange amount must be greater than zero.");
        }
        if (fromCurrency.equals(toCurrency)) {
            return AjaxResult.error("Source and target currencies must be different.");
        }

        boolean supportDirect = readBool("app.currency.supportRmbToUsd", true);
        double usdRate = readDouble("app.currency.usdRate", 7.0D);
        if (usdRate <= 0D) {
            return AjaxResult.error("Exchange rate is invalid.");
        }
        if (!isValidPair(fromCurrency, toCurrency)) {
            return AjaxResult.error("Unsupported exchange direction.");
        }

        SysUserWallet sourceWallet = ensureWallet(userId, user.getUserName(), fromCurrency);
        SysUserWallet targetWallet = ensureWallet(userId, user.getUserName(), toCurrency);
        double sourceBalanceBefore = valueOf(sourceWallet.getAvailableBalance());
        double sourceQuotaBefore = valueOf(sourceWallet.getUsdExchangeQuota());
        BigDecimal amountMoney = moneyOf(amount);
        if (amountMoney.compareTo(BigDecimal.ZERO) <= 0) {
            return AjaxResult.error("Exchange amount must be greater than zero.");
        }
        if (moneyOf(sourceBalanceBefore).compareTo(amountMoney) < 0) {
            return AjaxResult.error("Source wallet balance is insufficient.");
        }
        if (!supportDirect && "CNY".equals(fromCurrency) && moneyOf(sourceQuotaBefore).compareTo(amountMoney) < 0) {
            return AjaxResult.error("Exchange quota is insufficient.");
        }

        BigDecimal rateMoney = BigDecimal.valueOf(usdRate);
        BigDecimal targetAmountMoney = convertAmount(amountMoney, fromCurrency, toCurrency, rateMoney);
        BigDecimal sourceBalanceAfter = moneyOf(sourceBalanceBefore).subtract(amountMoney).setScale(2, RoundingMode.HALF_UP);
        BigDecimal sourceQuotaAfter = moneyOf(sourceQuotaBefore);
        if (!supportDirect && "CNY".equals(fromCurrency)) {
            sourceQuotaAfter = sourceQuotaAfter.subtract(amountMoney).setScale(2, RoundingMode.HALF_UP);
        }
        BigDecimal targetBalanceBefore = moneyOf(valueOf(targetWallet.getAvailableBalance()));
        BigDecimal targetBalanceAfter = targetBalanceBefore.add(targetAmountMoney).setScale(2, RoundingMode.HALF_UP);
        BigDecimal targetQuotaBefore = moneyOf(valueOf(targetWallet.getUsdExchangeQuota()));
        BigDecimal targetQuotaAfter = targetQuotaBefore;
        if (!supportDirect && "USD".equals(fromCurrency)) {
            targetQuotaAfter = targetQuotaBefore.add(targetAmountMoney).setScale(2, RoundingMode.HALF_UP);
        }
        Date now = new Date();
        String orderNo = generateExchangeOrderNo();

        sourceWallet.setAvailableBalance(sourceBalanceAfter.doubleValue());
        if (!supportDirect && "CNY".equals(fromCurrency)) {
            sourceWallet.setUsdExchangeQuota(sourceQuotaAfter.doubleValue());
        }
        sourceWallet.setUpdateTime(now);
        walletService.updateWallet(sourceWallet);
        insertWalletLog(
            sourceWallet,
            "exchange_out",
            amountMoney.doubleValue(),
            sourceBalanceBefore,
            sourceBalanceAfter.doubleValue(),
            orderNo,
            "Exchange out: " + fromCurrency + " to " + toCurrency
        );

        targetWallet.setAvailableBalance(targetBalanceAfter.doubleValue());
        if (!supportDirect && "USD".equals(fromCurrency)) {
            targetWallet.setUsdExchangeQuota(targetQuotaAfter.doubleValue());
        }
        targetWallet.setUpdateTime(now);
        walletService.updateWallet(targetWallet);
        insertWalletLog(
            targetWallet,
            "exchange_in",
            targetAmountMoney.doubleValue(),
            targetBalanceBefore.doubleValue(),
            targetBalanceAfter.doubleValue(),
            orderNo,
            "Exchange in: " + fromCurrency + " to " + toCurrency
        );

        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("fromCurrency", fromCurrency);
        result.put("toCurrency", toCurrency);
        result.put("amount", amountMoney.doubleValue());
        result.put("receivedAmount", targetAmountMoney.doubleValue());
        result.put("sourceBalance", valueOf(sourceWallet.getAvailableBalance()));
        result.put("targetBalance", valueOf(targetWallet.getAvailableBalance()));
        SysUserWallet cnyWallet = "CNY".equalsIgnoreCase(sourceWallet.getCurrencyType()) ? sourceWallet : targetWallet;
        if ("CNY".equalsIgnoreCase(cnyWallet.getCurrencyType())) {
            result.put("usdExchangeQuota", valueOf(cnyWallet.getUsdExchangeQuota()));
        }
        return AjaxResult.success(result);
    }

    private SysUserWallet ensureWallet(Long userId, String userName, String currencyType) {
        String normalizedCurrency = normalizeCurrencyType(currencyType);
        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyType(userId, normalizedCurrency);
        if (wallet != null) {
            return wallet;
        }

        Date now = new Date();
        wallet = new SysUserWallet();
        wallet.setUserId(userId);
        wallet.setUserName(userName);
        wallet.setCurrencyType(normalizedCurrency);
        wallet.setTotalInvest(0D);
        wallet.setAvailableBalance(0D);
        wallet.setUsdExchangeQuota(0D);
        wallet.setFrozenAmount(0D);
        wallet.setProfitAmount(0D);
        wallet.setPendingAmount(0D);
        wallet.setTotalRecharge(0D);
        wallet.setTotalWithdraw(0D);
        wallet.setCreateTime(now);
        wallet.setUpdateTime(now);
        walletService.insertWallet(wallet);

        wallet = walletService.selectWalletByUserIdAndCurrencyType(userId, normalizedCurrency);
        if (wallet == null) {
            throw new IllegalStateException("User wallet does not exist.");
        }
        return wallet;
    }

    private void insertWalletLog(
            SysUserWallet wallet,
            String type,
            double amount,
            double balanceBefore,
            double balanceAfter,
            String orderNo,
            String remark) {
        SysUserWalletLog log = new SysUserWalletLog();
        log.setUserId(wallet.getUserId());
        log.setWalletId(wallet.getWalletId());
        log.setCurrencyType(wallet.getCurrencyType());
        log.setAmount(roundMoney(amount));
        log.setType(type);
        log.setStatus("success");
        log.setBalanceBefore(roundMoney(balanceBefore));
        log.setBalanceAfter(roundMoney(balanceAfter));
        log.setOrderNo(orderNo);
        log.setOperatorName(SecurityUtils.getUsername());
        log.setRemark(remark);
        log.setCreateTime(new Date());
        log.setUpdateTime(new Date());
        walletLogService.insertLog(log);
    }

    private boolean isValidPair(String fromCurrency, String toCurrency) {
        return ("CNY".equals(fromCurrency) && "USD".equals(toCurrency))
            || ("USD".equals(fromCurrency) && "CNY".equals(toCurrency));
    }

    private BigDecimal convertAmount(BigDecimal amount, String fromCurrency, String toCurrency, BigDecimal usdRate) {
        if ("CNY".equals(fromCurrency) && "USD".equals(toCurrency)) {
            return amount.divide(usdRate, 2, RoundingMode.HALF_UP);
        }
        if ("USD".equals(fromCurrency) && "CNY".equals(toCurrency)) {
            return amount.multiply(usdRate).setScale(2, RoundingMode.HALF_UP);
        }
        return amount.setScale(2, RoundingMode.HALF_UP);
    }

    private double valueOf(Double value) {
        return value == null ? 0D : value;
    }

    private double roundMoney(double value) {
        return moneyOf(value).doubleValue();
    }

    private BigDecimal moneyOf(double value) {
        return BigDecimal.valueOf(value).setScale(2, RoundingMode.HALF_UP);
    }

    private boolean readBool(String key, boolean defaultValue) {
        String raw = StringUtils.trim(configService.selectConfigByKey(key));
        if (StringUtils.isEmpty(raw)) {
            return defaultValue;
        }
        return "1".equals(raw) || "true".equalsIgnoreCase(raw) || "yes".equalsIgnoreCase(raw);
    }

    private double readDouble(String key, double defaultValue) {
        String raw = StringUtils.trim(configService.selectConfigByKey(key));
        if (StringUtils.isEmpty(raw)) {
            return defaultValue;
        }
        try {
            return Double.parseDouble(raw);
        } catch (NumberFormatException ignored) {
            return defaultValue;
        }
    }

    private String normalizeCurrencyType(String currencyType) {
        if (StringUtils.isBlank(currencyType)) {
            return "CNY";
        }
        String normalized = currencyType.trim().toUpperCase();
        return "USD".equals(normalized) ? "USD" : "CNY";
    }

    private String generateExchangeOrderNo() {
        return "EX" + DateUtils.dateTimeNow() + IdUtils.fastSimpleUUID().substring(0, 8).toUpperCase();
    }

    public static class CurrencyExchangeBody {
        private String fromCurrency;
        private String toCurrency;
        private Double amount;

        public String getFromCurrency() {
            return fromCurrency;
        }

        public void setFromCurrency(String fromCurrency) {
            this.fromCurrency = fromCurrency;
        }

        public String getToCurrency() {
            return toCurrency;
        }

        public void setToCurrency(String toCurrency) {
            this.toCurrency = toCurrency;
        }

        public Double getAmount() {
            return amount;
        }

        public void setAmount(Double amount) {
            this.amount = amount;
        }
    }
}
