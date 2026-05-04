package com.ruoyi.web.controller.app;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.entity.SysUserWallet;
import com.ruoyi.common.core.domain.entity.SysUserWalletLog;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.security.crypto.ApiCryptoService;
import com.ruoyi.system.domain.SysInvestProduct;
import com.ruoyi.system.mapper.SysAppInvestOrderMapper;
import com.ruoyi.system.mapper.SysInvestProductMapper;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysTeamStatService;
import com.ruoyi.system.service.ISysUserService;
import com.ruoyi.system.service.ISysUserWalletLogService;
import com.ruoyi.system.service.ISysUserWalletService;
import tools.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/app/invest/order")
public class AppInvestOrderController extends BaseController
{
    private static final String CONTRACT_TEMPLATE_KEY = "app.invest.contract.template";
    private static final String IDEMPOTENT_LOCK_KEY = "app:invest:submit:lock:";
    private static final String IDEMPOTENT_RESULT_KEY = "app:invest:submit:result:";

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ISysUserWalletService walletService;

    @Autowired
    private ISysUserWalletLogService walletLogService;

    @Autowired
    private SysInvestProductMapper investProductMapper;

    @Autowired
    private SysAppInvestOrderMapper appInvestOrderMapper;

    @Autowired
    private ApiCryptoService apiCryptoService;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private ISysTeamStatService teamStatService;

    @PostMapping("/contract/preview")
    public AjaxResult previewContract(@RequestBody Map<String, Object> body)
    {
        Map<String, Object> payload = normalizePayload(body);
        Long userId = getLoginUser().getUserId();
        Long productId = parseLong(payload.get("productId"), 0L);
        SysUser user = userService.selectUserById(userId);
        Map<String, Object> latestSigned = null;
        if (productId != null && productId > 0L)
        {
            latestSigned = appInvestOrderMapper.selectLatestValidContractSign(userId, productId);
        }

        String verifiedRealName = user == null ? null : StringUtils.trim(user.getRealName());
        String investorNo = StringUtils.isNotBlank(verifiedRealName)
            ? verifiedRealName
            : (user == null ? String.valueOf(userId) : user.getUserName());
        String investorName = StringUtils.isNotBlank(verifiedRealName)
            ? verifiedRealName
            : (user == null ? "投资者" : StringUtils.defaultIfBlank(user.getNickName(), user.getUserName()));
        BigDecimal amount = parseDecimal(payload.get("amount"), BigDecimal.ZERO);
        Integer cycleDays = parseInt(payload.get("cycleDays"), 0);
        BigDecimal rate = parseDecimal(payload.get("singleRate"), BigDecimal.ZERO);
        String productName = StringUtils.trim(String.valueOf(payload.get("productName")));
        if (StringUtils.isBlank(productName) || "null".equalsIgnoreCase(productName))
        {
            productName = "投资产品";
        }

        String template = StringUtils.trim(configService.selectConfigByKey(CONTRACT_TEMPLATE_KEY));
        if (StringUtils.isBlank(template))
        {
            template = defaultTemplate();
        }
        template = template.replace("${investorNo}", StringUtils.defaultString(investorNo))
            .replace("${investorName}", StringUtils.defaultString(investorName))
            .replace("${productName}", StringUtils.defaultString(productName))
            .replace("${amount}", amount.stripTrailingZeros().toPlainString())
            .replace("${cycleDays}", String.valueOf(cycleDays))
            .replace("${rate}", rate.stripTrailingZeros().toPlainString());

        Map<String, Object> data = new HashMap<String, Object>();
        data.put("investorNo", investorNo);
        data.put("investorName", investorName);
        data.put("realName", StringUtils.defaultString(verifiedRealName));
        data.put("platformName", "投资平台");
        data.put("amount", amount);
        data.put("cycleDays", cycleDays);
        data.put("rate", rate);
        data.put("contractTemplate", template);
        data.put("contractSample", template);
        data.put("contractKey", CONTRACT_TEMPLATE_KEY);
        data.put("signedBefore", latestSigned != null && !latestSigned.isEmpty());
        return AjaxResult.success(data);
    }

    @GetMapping("/list")
    public AjaxResult list(String tab)
    {
        Long userId = getLoginUser().getUserId();
        String normalizedTab = normalizeTab(tab);
        List<Map<String, Object>> rows = appInvestOrderMapper.selectAppInvestOrderList(userId, normalizedTab);
        Map<String, Object> stat = appInvestOrderMapper.selectAppInvestOrderStat(userId);
        Map<String, Object> data = new LinkedHashMap<String, Object>();
        data.put("tab", normalizedTab);
        data.put("totalCount", parseInt(stat == null ? null : stat.get("totalCount"), 0));
        data.put("runningCount", parseInt(stat == null ? null : stat.get("runningCount"), 0));
        data.put("endedCount", parseInt(stat == null ? null : stat.get("endedCount"), 0));
        data.put("list", rows);
        return AjaxResult.success(data);
    }

    @GetMapping("/incomes")
    public AjaxResult incomes()
    {
        Long userId = getLoginUser().getUserId();
        Map<String, Object> summary = appInvestOrderMapper.selectAppInvestIncomeSummary(userId);
        List<Map<String, Object>> summaryByCurrency = appInvestOrderMapper.selectAppInvestIncomeSummaryByCurrency(userId);
        List<Map<String, Object>> logs = appInvestOrderMapper.selectAppInvestIncomeLogs(userId);
        Map<String, Object> data = new LinkedHashMap<String, Object>();
        data.put("receivedInterest", parseDecimal(summary == null ? null : summary.get("receivedInterest"), BigDecimal.ZERO));
        data.put("pendingInterest", parseDecimal(summary == null ? null : summary.get("pendingInterest"), BigDecimal.ZERO));
        data.put("receivedPrincipal", parseDecimal(summary == null ? null : summary.get("receivedPrincipal"), BigDecimal.ZERO));
        data.put("pendingPrincipal", parseDecimal(summary == null ? null : summary.get("pendingPrincipal"), BigDecimal.ZERO));
        data.put("summaryByCurrency", summaryByCurrency);
        data.put("logs", logs);
        return AjaxResult.success(data);
    }

    @PostMapping("/submit")
    @Transactional(rollbackFor = Exception.class)
    public AjaxResult submit(@RequestBody Map<String, Object> body)
    {
        Map<String, Object> payload = normalizePayload(body);
        Long userId = getLoginUser().getUserId();
        String clientReqNo = StringUtils.trim((String) payload.get("clientReqNo"));
        if (StringUtils.isBlank(clientReqNo))
        {
            throw new ServiceException("请求流水不能为空");
        }
        String lockKey = IDEMPOTENT_LOCK_KEY + userId + ":" + clientReqNo;
        String resultKey = IDEMPOTENT_RESULT_KEY + userId + ":" + clientReqNo;
        String cachedResult = stringRedisTemplate.opsForValue().get(resultKey);
        if (StringUtils.isNotBlank(cachedResult))
        {
            return toCachedSuccess(cachedResult);
        }
        Map<String, Object> existingOrder = appInvestOrderMapper.selectOrderByUserAndClientReqNo(userId, clientReqNo);
        if (existingOrder != null && !existingOrder.isEmpty())
        {
            Map<String, Object> data = buildExistingResult(existingOrder);
            stringRedisTemplate.opsForValue().set(resultKey, objectMapper.writeValueAsString(data), 10, TimeUnit.MINUTES);
            return AjaxResult.success(data);
        }
        Boolean locked = stringRedisTemplate.opsForValue().setIfAbsent(lockKey, "1", 15, TimeUnit.SECONDS);
        if (locked == null || !locked)
        {
            String existingResult = stringRedisTemplate.opsForValue().get(resultKey);
            if (StringUtils.isNotBlank(existingResult))
            {
                return toCachedSuccess(existingResult);
            }
            throw new ServiceException("订单提交处理中，请勿重复提交");
        }
        try
        {
        // 支付校验必须读取实时用户数据，避免缓存短暂不一致导致误判“未设置支付密码”
        SysUser user = userService.selectUserBaseById(userId);
        if (user == null)
        {
            throw new ServiceException("用户不存在");
        }

        boolean agreed = parseBoolean(payload.get("agreed"));
        String signatureData = StringUtils.trim((String) payload.get("signatureData"));
        String payPwd = StringUtils.trim((String) payload.get("payPwd"));
        Long productId = parseLong(payload.get("productId"), 0L);
        Map<String, Object> latestSigned = null;
        if (productId != null && productId > 0L)
        {
            latestSigned = appInvestOrderMapper.selectLatestValidContractSign(userId, productId);
        }
        final boolean signedBefore = latestSigned != null && !latestSigned.isEmpty();
        if (!agreed)
        {
            if (!signedBefore)
            {
                throw new ServiceException("请先勾选同意合同条款");
            }
            agreed = true;
        }
        if (StringUtils.isBlank(signatureData) && signedBefore)
        {
            Object oldSignatureData = latestSigned.get("signatureData");
            signatureData = oldSignatureData == null ? "" : String.valueOf(oldSignatureData).trim();
        }
        if (StringUtils.isBlank(signatureData))
        {
            throw new ServiceException("请先手写签名");
        }
        if (StringUtils.isBlank(user.getPayPassword()))
        {
            throw new ServiceException("支付密码未设置");
        }
        if (StringUtils.isBlank(payPwd) || !SecurityUtils.matchesPassword(payPwd, user.getPayPassword()))
        {
            throw new ServiceException("支付密码错误");
        }

        if (productId == null || productId <= 0)
        {
            throw new ServiceException("产品ID不能为空");
        }

        SysInvestProduct product = investProductMapper.selectInvestProductByIdForUpdate(productId);
        if (product == null || !"0".equals(product.getStatus()))
        {
            throw new ServiceException("产品不可用");
        }
        Date now = new Date();
        if (product.getStartTime() != null && now.before(product.getStartTime()))
        {
            throw new ServiceException("产品未开始");
        }
        if (product.getEndTime() != null && now.after(product.getEndTime()))
        {
            throw new ServiceException("产品已过有效期");
        }
        BigDecimal progressPercent = parseDecimal(product.getProgressPercent(), BigDecimal.ZERO);
        if (progressPercent.compareTo(BigDecimal.valueOf(100)) >= 0)
        {
            throw new ServiceException("产品进度已100%，暂不可下单");
        }
        String investMode = StringUtils.upperCase(StringUtils.defaultIfBlank(product.getInvestMode(), "SHARE"));
        BigDecimal orderPrincipalAmount = parseDecimal(payload.get("amount"), BigDecimal.ZERO).setScale(2, RoundingMode.DOWN);
        if (orderPrincipalAmount.compareTo(BigDecimal.ZERO) <= 0 && "AMOUNT".equals(investMode))
        {
            throw new ServiceException("投资金额必须大于0");
        }

        BigDecimal minAmount = parseDecimal(product.getMinInvestAmount(), BigDecimal.ZERO).setScale(2, RoundingMode.DOWN);
        BigDecimal maxAmount = parseDecimal(product.getMaxInvestAmount(), BigDecimal.ZERO).setScale(2, RoundingMode.DOWN);
        long investShares = 0L;
        long totalShares = product.getTotalShares() == null ? 0L : product.getTotalShares();
        long soldShares = product.getSoldShares() == null ? 0L : product.getSoldShares();
        BigDecimal totalAmount = parseDecimal(product.getTotalAmount(), BigDecimal.ZERO).setScale(2, RoundingMode.DOWN);
        BigDecimal soldAmount = parseDecimal(product.getSoldAmount(), BigDecimal.ZERO).setScale(2, RoundingMode.DOWN);
        BigDecimal remainAmount = totalAmount.subtract(soldAmount);
        if (remainAmount.compareTo(BigDecimal.ZERO) < 0)
        {
            remainAmount = BigDecimal.ZERO;
        }
        if ("SHARE".equals(investMode))
        {
            Long payloadShares = parseLong(payload.get("purchaseShares"), 0L);
            if (payloadShares == null || payloadShares <= 0L)
            {
                throw new ServiceException("购买份数必须大于0");
            }
            investShares = payloadShares;
            orderPrincipalAmount = minAmount.multiply(BigDecimal.valueOf(investShares)).setScale(2, RoundingMode.DOWN);
            if (orderPrincipalAmount.compareTo(BigDecimal.ZERO) <= 0)
            {
                throw new ServiceException("投资金额必须大于0");
            }
            if (maxAmount.compareTo(BigDecimal.ZERO) > 0 && orderPrincipalAmount.compareTo(maxAmount) > 0)
            {
                throw new ServiceException("投资金额超过最高可投");
            }
            long remainShares = totalShares - soldShares;
            if (remainShares < 0)
            {
                remainShares = 0L;
            }
            if (totalShares > 0 && investShares > remainShares)
            {
                throw new ServiceException("产品剩余份额不足");
            }
        }
        else
        {
            if (totalAmount.compareTo(BigDecimal.ZERO) > 0 && remainAmount.compareTo(BigDecimal.ZERO) <= 0)
            {
                throw new ServiceException("产品剩余金额不足");
            }
            if (minAmount.compareTo(BigDecimal.ZERO) > 0 && orderPrincipalAmount.compareTo(minAmount) < 0)
            {
                throw new ServiceException("投资金额低于起投金额");
            }
            if (maxAmount.compareTo(BigDecimal.ZERO) > 0 && orderPrincipalAmount.compareTo(maxAmount) > 0)
            {
                throw new ServiceException("投资金额超过最高可投");
            }
            if (remainAmount.compareTo(BigDecimal.ZERO) > 0 && orderPrincipalAmount.compareTo(remainAmount) > 0)
            {
                throw new ServiceException("产品剩余金额不足");
            }
            investShares = calcInvestShares(orderPrincipalAmount, minAmount);
        }

        Integer limitTimes = product.getLimitTimes() == null ? 0 : product.getLimitTimes();
        if (limitTimes > 0)
        {
            int investedCount = appInvestOrderMapper.countUserInvestOrderByProduct(userId, productId);
            if (investedCount >= limitTimes)
            {
                throw new ServiceException("已达到该产品可投次数上限");
            }
        }

        String currency = normalizeWalletCurrency(product.getCurrency());
        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(userId, currency);
        if (wallet == null)
        {
            throw new ServiceException(currency + "钱包不存在");
        }
        BigDecimal balanceBefore = parseDecimal(wallet.getAvailableBalance(), BigDecimal.ZERO).setScale(2, RoundingMode.DOWN);
        if (balanceBefore.compareTo(orderPrincipalAmount) < 0)
        {
            throw new ServiceException("余额不足");
        }
        BigDecimal balanceAfter = balanceBefore.subtract(orderPrincipalAmount).setScale(2, RoundingMode.DOWN);
        BigDecimal totalInvestAfter = parseDecimal(wallet.getTotalInvest(), BigDecimal.ZERO).add(orderPrincipalAmount).setScale(2, RoundingMode.DOWN);
        wallet.setAvailableBalance(balanceAfter.doubleValue());
        wallet.setTotalInvest(totalInvestAfter.doubleValue());
        wallet.setUpdateTime(new Date());
        walletService.updateWallet(wallet);

        String orderNo = buildNo("IO", userId);
        String contractNo = buildNo("IC", userId);
        String userName = StringUtils.defaultIfBlank(user.getUserName(), String.valueOf(userId));
        String realName = StringUtils.trim(user.getRealName());
        String contractInvestorName = StringUtils.defaultIfBlank(realName, StringUtils.defaultIfBlank(user.getNickName(), userName));
        String productName = StringUtils.defaultIfBlank(product.getProductName(), "投资产品");
        BigDecimal singleRate = parseDecimal(product.getSingleRate(), BigDecimal.ZERO);
        BigDecimal groupRate = parseDecimal(product.getGroupRate(), BigDecimal.ZERO);
        boolean groupMode = parseBoolean(payload.get("groupMode"));
        BigDecimal effectiveRate = groupMode ? groupRate : singleRate;
        Integer cycleDays = product.getCycleDays() == null ? 1 : product.getCycleDays();
        BigDecimal expectedIncome = orderPrincipalAmount.multiply(effectiveRate)
            .divide(BigDecimal.valueOf(100), 2, RoundingMode.DOWN);

        appInvestOrderMapper.insertInvestOrder(
            orderNo,
            clientReqNo,
            userId,
            userName,
            productId,
            productName,
            currency,
            groupMode ? "1" : "0",
            orderPrincipalAmount,
            singleRate,
            groupRate,
            effectiveRate,
            cycleDays,
            expectedIncome,
            contractNo,
            userName,
            "APP在线签约认购"
        );

        String contractText = StringUtils.trim((String) payload.get("contractText"));
        if (StringUtils.isBlank(contractText))
        {
            contractText = StringUtils.trim(configService.selectConfigByKey(CONTRACT_TEMPLATE_KEY));
        }
        if (StringUtils.isBlank(contractText))
        {
            contractText = defaultTemplate();
        }
        contractText = contractText
            .replace("${investorNo}", contractInvestorName)
            .replace("${investorName}", contractInvestorName)
            .replace("${productName}", productName)
            .replace("${amount}", orderPrincipalAmount.stripTrailingZeros().toPlainString())
            .replace("${cycleDays}", String.valueOf(cycleDays))
            .replace("${rate}", effectiveRate.stripTrailingZeros().toPlainString());
        appInvestOrderMapper.insertContractSign(
            contractNo,
            orderNo,
            userId,
            productId,
            contractText,
            signatureData,
            "1",
            new Date(),
            userName
        );

        Long orderId = appInvestOrderMapper.selectInvestOrderIdByOrderNo(orderNo);
        if (orderId != null && orderId > 0)
        {
            writeOrderPlans(orderId, userId, product, orderPrincipalAmount, effectiveRate, expectedIncome);
        }

        investProductMapper.increaseSoldShares(productId, investShares, orderPrincipalAmount);

        SysUserWalletLog log = new SysUserWalletLog();
        log.setUserId(userId);
        log.setWalletId(wallet.getWalletId());
        log.setCurrencyType(currency);
        log.setAmount(orderPrincipalAmount.doubleValue());
        log.setType("invest");
        log.setStatus("success");
        log.setBalanceBefore(balanceBefore.doubleValue());
        log.setBalanceAfter(balanceAfter.doubleValue());
        log.setOrderNo(orderNo);
        log.setOperatorName(userName);
        log.setRemark("APP在线签约认购");
        log.setCreateTime(new Date());
        walletLogService.insertLog(log);

        BigDecimal investDeltaCny = toCnyAmount(currency, orderPrincipalAmount);
        userMapper.addUserTotalAmounts(userId, investDeltaCny, BigDecimal.ZERO);
        if (orderId != null && orderId > 0L)
        {
            teamStatService.recordInvestOrderEvent(userId, orderId, orderPrincipalAmount, new Date());
        }

        Map<String, Object> data = new HashMap<String, Object>();
        data.put("orderNo", orderNo);
        data.put("contractNo", contractNo);
        data.put("signed", true);
        data.put("signedAt", new Date());
        data.put("msg", "签约并认购成功");
        stringRedisTemplate.opsForValue().set(resultKey, objectMapper.writeValueAsString(data), 10, TimeUnit.MINUTES);
        return AjaxResult.success(data);
        }
        catch (ServiceException e)
        {
            throw e;
        }
        catch (Exception e)
        {
            throw new ServiceException("订单提交失败：" + e.getMessage());
        }
        finally
        {
            stringRedisTemplate.delete(lockKey);
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> normalizePayload(Map<String, Object> body)
    {
        if (body == null || body.isEmpty())
        {
            return Collections.emptyMap();
        }
        Object data = body.get("data");
        if (data instanceof Map)
        {
            return (Map<String, Object>) data;
        }
        if (data != null)
        {
            String text = data.toString().trim();
            if (!text.isEmpty())
            {
                try
                {
                    String plainJson = apiCryptoService.decryptText(text);
                    Map<String, Object> payload = objectMapper.readValue(plainJson, Map.class);
                    if (payload != null)
                    {
                        return payload;
                    }
                }
                catch (Exception ignored)
                {
                }
            }
        }
        return body;
    }

    private String defaultTemplate()
    {
        return "甲方（投资者）：${investorNo}\n\n"
            + "乙方（平台方）：投资平台\n\n"
            + "投资产品：${productName}\n"
            + "投资金额：¥${amount}\n"
            + "投资期限：${cycleDays}天\n"
            + "预期收益率：${rate}%\n\n"
            + "合同条款：\n"
            + "1. 甲方同意按照本合同约定向乙方投资指定金额的资金。\n"
            + "2. 乙方承诺按照约定的收益率和期限向甲方支付投资收益。\n"
            + "3. 投资期间，甲方不得提前撤回投资资金。\n"
            + "4. 如因不可抗力因素导致投资损失，双方共同承担风险。";
    }

    private BigDecimal parseDecimal(Object value, BigDecimal defaultValue)
    {
        if (value == null)
        {
            return defaultValue;
        }
        if (value instanceof BigDecimal)
        {
            return (BigDecimal) value;
        }
        try
        {
            return new BigDecimal(value.toString().trim());
        }
        catch (Exception e)
        {
            return defaultValue;
        }
    }

    private Integer parseInt(Object value, Integer defaultValue)
    {
        if (value == null)
        {
            return defaultValue;
        }
        if (value instanceof Number)
        {
            return ((Number) value).intValue();
        }
        try
        {
            return Integer.parseInt(value.toString().trim());
        }
        catch (Exception e)
        {
            return defaultValue;
        }
    }

    private Long parseLong(Object value, Long defaultValue)
    {
        if (value == null)
        {
            return defaultValue;
        }
        if (value instanceof Number)
        {
            return ((Number) value).longValue();
        }
        try
        {
            return Long.parseLong(value.toString().trim());
        }
        catch (Exception e)
        {
            return defaultValue;
        }
    }

    private boolean parseBoolean(Object value)
    {
        if (value instanceof Boolean)
        {
            return ((Boolean) value).booleanValue();
        }
        if (value == null)
        {
            return false;
        }
        String text = value.toString().trim();
        return "1".equals(text) || "true".equalsIgnoreCase(text) || "yes".equalsIgnoreCase(text);
    }

    private String normalizeWalletCurrency(String productCurrency)
    {
        String c = StringUtils.upperCase(StringUtils.defaultIfBlank(productCurrency, "CNY"));
        if ("USDT".equals(c))
        {
            return "USD";
        }
        if (!"USD".equals(c) && !"CNY".equals(c))
        {
            return "CNY";
        }
        return c;
    }

    private BigDecimal toCnyAmount(String currency, BigDecimal amount)
    {
        BigDecimal safeAmount = amount == null ? BigDecimal.ZERO : amount;
        if (!"USD".equalsIgnoreCase(currency))
        {
            return safeAmount.setScale(2, RoundingMode.DOWN);
        }
        BigDecimal usdRate = parseDecimal(configService.selectConfigByKey("app.currency.usdRate"), BigDecimal.ONE);
        if (usdRate.compareTo(BigDecimal.ZERO) <= 0)
        {
            usdRate = BigDecimal.ONE;
        }
        return safeAmount.multiply(usdRate).setScale(2, RoundingMode.DOWN);
    }

    private void writeOrderPlans(Long orderId, Long userId, SysInvestProduct product,
        BigDecimal investAmount, BigDecimal effectiveRate, BigDecimal expectedIncome)
    {
        String interestMode = StringUtils.upperCase(StringUtils.defaultIfBlank(product.getInterestMode(), "MATURITY"));
        String principalMode = StringUtils.upperCase(StringUtils.defaultIfBlank(product.getPrincipalMode(), "MATURITY"));
        int cycleDays = product.getCycleDays() == null ? 1 : product.getCycleDays().intValue();
        Date baseTime = new Date();
        int stageNo = 1;

        List<Map<String, Object>> stageConfig = parseStageConfig(product.getStageConfigJson());
        if ("DAILY".equals(interestMode))
        {
            BigDecimal dailyInterest = expectedIncome.divide(BigDecimal.valueOf(Math.max(cycleDays, 1)), 6, RoundingMode.DOWN);
            BigDecimal consumed = BigDecimal.ZERO;
            for (int i = 1; i <= cycleDays; i++)
            {
                BigDecimal amount = i == cycleDays ? expectedIncome.subtract(consumed) : dailyInterest;
                consumed = consumed.add(amount);
                appInvestOrderMapper.insertOrderPlan(orderId, product.getProductId(), userId, "INTEREST", stageNo++,
                    plusDays(baseTime, i), effectiveRate, amount.max(BigDecimal.ZERO), "按天返息计划");
            }
        }
        else if ("STAGED".equals(interestMode))
        {
            stageNo = writeStagedPlans(orderId, userId, product, expectedIncome, effectiveRate, baseTime, stageNo, "INTEREST", stageConfig);
        }
        else
        {
            appInvestOrderMapper.insertOrderPlan(orderId, product.getProductId(), userId, "INTEREST", stageNo++,
                plusDays(baseTime, cycleDays), effectiveRate, expectedIncome.max(BigDecimal.ZERO), "到期返息计划");
        }

        if ("STAGED".equals(principalMode))
        {
            writeStagedPlans(orderId, userId, product, investAmount, BigDecimal.ZERO, baseTime, 1, "PRINCIPAL", stageConfig);
        }
        else
        {
            appInvestOrderMapper.insertOrderPlan(orderId, product.getProductId(), userId, "PRINCIPAL", 1,
                plusDays(baseTime, cycleDays), BigDecimal.ZERO, investAmount.max(BigDecimal.ZERO), "到期返本计划");
        }
    }

    private int writeStagedPlans(Long orderId, Long userId, SysInvestProduct product, BigDecimal totalAmount,
        BigDecimal rate, Date baseTime, int startStage, String planType, List<Map<String, Object>> stageConfig)
    {
        int cycleDays = product.getCycleDays() == null ? 1 : product.getCycleDays().intValue();
        int stageCount = "PRINCIPAL".equals(planType)
            ? (product.getPrincipalStageCount() == null ? 0 : product.getPrincipalStageCount().intValue())
            : (product.getInterestStageCount() == null ? 0 : product.getInterestStageCount().intValue());
        if (stageCount <= 0)
        {
            stageCount = 1;
        }

        BigDecimal consumed = BigDecimal.ZERO;
        int stageNo = startStage;
        for (int i = 1; i <= stageCount; i++)
        {
            BigDecimal ratio = extractRatio(stageConfig, planType, i, stageCount);
            int dayOffset = extractDayOffset(stageConfig, planType, i, stageCount, cycleDays);
            BigDecimal stageAmount = i == stageCount
                ? totalAmount.subtract(consumed)
                : totalAmount.multiply(ratio).setScale(6, RoundingMode.DOWN);
            if (stageAmount.compareTo(BigDecimal.ZERO) < 0)
            {
                stageAmount = BigDecimal.ZERO;
            }
            consumed = consumed.add(stageAmount);
            appInvestOrderMapper.insertOrderPlan(orderId, product.getProductId(), userId, planType, stageNo++,
                plusDays(baseTime, dayOffset), rate, stageAmount, "分段计划");
        }
        return stageNo;
    }

    private BigDecimal extractRatio(List<Map<String, Object>> stageConfig, String planType, int stageNo, int stageCount)
    {
        if (stageConfig == null || stageConfig.isEmpty())
        {
            return BigDecimal.ONE.divide(BigDecimal.valueOf(stageCount), 8, RoundingMode.DOWN);
        }
        for (Map<String, Object> node : stageConfig)
        {
            int no = parseInt(node.get("stageNo"), 0);
            String type = StringUtils.upperCase(String.valueOf(node.get("type")));
            if (no == stageNo && (StringUtils.isBlank(type) || planType.equals(type)))
            {
                BigDecimal percent = parseDecimal(node.get("ratio"), null);
                if (percent == null)
                {
                    percent = parseDecimal(node.get("percent"), null);
                }
                if (percent == null)
                {
                    continue;
                }
                if (percent.compareTo(BigDecimal.ONE) > 0)
                {
                    return percent.divide(BigDecimal.valueOf(100), 8, RoundingMode.DOWN);
                }
                return percent.max(BigDecimal.ZERO);
            }
        }
        return BigDecimal.ONE.divide(BigDecimal.valueOf(stageCount), 8, RoundingMode.DOWN);
    }

    private int extractDayOffset(List<Map<String, Object>> stageConfig, String planType, int stageNo, int stageCount, int cycleDays)
    {
        if (stageConfig != null)
        {
            for (Map<String, Object> node : stageConfig)
            {
                int no = parseInt(node.get("stageNo"), 0);
                String type = StringUtils.upperCase(String.valueOf(node.get("type")));
                if (no == stageNo && (StringUtils.isBlank(type) || planType.equals(type)))
                {
                    Integer day = parseInt(node.get("day"), null);
                    if (day == null)
                    {
                        day = parseInt(node.get("dayOffset"), null);
                    }
                    if (day != null && day.intValue() > 0)
                    {
                        return day.intValue();
                    }
                }
            }
        }
        return stageNo >= stageCount ? cycleDays : (int) Math.floor((double) cycleDays * stageNo / stageCount);
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> parseStageConfig(String stageConfigJson)
    {
        if (StringUtils.isBlank(stageConfigJson))
        {
            return Collections.emptyList();
        }
        try
        {
            List<Map<String, Object>> list = objectMapper.readValue(stageConfigJson, List.class);
            return list == null ? Collections.emptyList() : list;
        }
        catch (Exception e)
        {
            return new ArrayList<Map<String, Object>>();
        }
    }

    private Date plusDays(Date baseTime, int days)
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(baseTime == null ? new Date() : baseTime);
        cal.add(Calendar.DAY_OF_MONTH, Math.max(days, 0));
        return cal.getTime();
    }

    private String buildNo(String prefix, Long userId)
    {
        return prefix + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()) + String.format("%06d", userId);
    }

    private long calcInvestShares(BigDecimal amount, BigDecimal shareUnitAmount)
    {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0)
        {
            return 1L;
        }
        if (shareUnitAmount == null || shareUnitAmount.compareTo(BigDecimal.ZERO) <= 0)
        {
            return 1L;
        }
        long shares = amount.divide(shareUnitAmount, 0, RoundingMode.DOWN).longValue();
        return shares <= 0L ? 1L : shares;
    }

    private String normalizeTab(String tab)
    {
        String normalized = StringUtils.lowerCase(StringUtils.defaultString(tab, "total"));
        if ("running".equals(normalized) || "ended".equals(normalized))
        {
            return normalized;
        }
        return "total";
    }

    @SuppressWarnings("unchecked")
    private AjaxResult toCachedSuccess(String cachedJson)
    {
        try
        {
            Map<String, Object> data = objectMapper.readValue(cachedJson, Map.class);
            data.put("idempotent", true);
            return AjaxResult.success(data);
        }
        catch (Exception e)
        {
            return AjaxResult.success();
        }
    }

    private Map<String, Object> buildExistingResult(Map<String, Object> existingOrder)
    {
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("orderNo", existingOrder.get("orderNo"));
        data.put("contractNo", existingOrder.get("contractNo"));
        data.put("signed", true);
        data.put("signedAt", existingOrder.get("createTime"));
        data.put("idempotent", true);
        data.put("msg", "请勿重复提交，已返回原订单");
        return data;
    }
}
