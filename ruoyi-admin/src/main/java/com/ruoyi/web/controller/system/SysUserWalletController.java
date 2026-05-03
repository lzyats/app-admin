package com.ruoyi.web.controller.system;

import java.util.List;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUserWallet;
import com.ruoyi.common.core.domain.entity.SysUserWalletLog;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.core.text.Convert;
import com.ruoyi.system.domain.SysUserLevel;
import com.ruoyi.system.mapper.SysUserLevelMapper;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysUserWalletLogService;
import com.ruoyi.system.service.ISysUserWalletService;

/**
 * Wallet management controller.
 */
@RestController
@RequestMapping("/system/wallet")
public class SysUserWalletController extends BaseController
{
    @Autowired
    private ISysUserWalletService walletService;

    @Autowired
    private ISysUserWalletLogService logService;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private SysUserLevelMapper userLevelMapper;

    @GetMapping("/user/{userId}")
    public AjaxResult getWalletByUserId(@PathVariable Long userId,
            @RequestParam(value = "currencyType", required = false) String currencyType)
    {
        SysUserWallet wallet = StringUtils.isNotBlank(currencyType)
                ? walletService.selectWalletByUserIdAndCurrencyType(userId, normalizeCurrencyType(currencyType))
                : walletService.selectWalletByUserId(userId);
        if (wallet == null)
        {
            wallet = walletService.selectWalletByUserId(userId);
        }
        return AjaxResult.success(wallet);
    }

    @GetMapping("/list")
    @PreAuthorize("@ss.hasPermi('system:wallet:list')")
    public TableDataInfo list(SysUserWallet wallet)
    {
        startPage();
        List<SysUserWallet> list = walletService.selectWalletList(wallet);
        return getDataTable(list);
    }

    @PostMapping
    @PreAuthorize("@ss.hasPermi('system:wallet:add')")
    @Log(title = "Wallet", businessType = BusinessType.INSERT)
    public AjaxResult add(@RequestBody SysUserWallet wallet)
    {
        if (wallet.getUserId() == null)
        {
            return error("User ID cannot be empty.");
        }
        wallet.setCurrencyType(normalizeCurrencyType(wallet.getCurrencyType()));
        return AjaxResult.success(walletService.insertWallet(wallet));
    }

    @PutMapping
    @PreAuthorize("@ss.hasPermi('system:wallet:edit')")
    @Log(title = "Wallet", businessType = BusinessType.UPDATE)
    public AjaxResult edit(@RequestBody SysUserWallet wallet)
    {
        if (wallet.getWalletId() == null)
        {
            return error("Wallet ID cannot be empty.");
        }
        wallet.setCurrencyType(normalizeCurrencyType(wallet.getCurrencyType()));
        return AjaxResult.success(walletService.updateWallet(wallet));
    }

    @DeleteMapping("/{walletId}")
    @PreAuthorize("@ss.hasPermi('system:wallet:remove')")
    @Log(title = "Wallet", businessType = BusinessType.DELETE)
    public AjaxResult remove(@PathVariable Long walletId)
    {
        return AjaxResult.success(walletService.deleteWalletById(walletId));
    }

    @DeleteMapping("/batch")
    @PreAuthorize("@ss.hasPermi('system:wallet:remove')")
    @Log(title = "Wallet", businessType = BusinessType.DELETE)
    public AjaxResult removeBatch(@RequestBody Long[] walletIds)
    {
        return AjaxResult.success(walletService.deleteWalletByIds(walletIds));
    }

    @GetMapping("/log/user/{userId}")
    public TableDataInfo getLogsByUserId(@PathVariable Long userId)
    {
        startPage();
        List<SysUserWalletLog> list = logService.selectLogsByUserId(userId);
        return getDataTable(list);
    }

    @GetMapping("/log/list")
    @PreAuthorize("@ss.hasPermi('system:wallet:log:list')")
    public TableDataInfo logList(SysUserWalletLog log)
    {
        startPage();
        List<SysUserWalletLog> list = logService.selectLogList(log);
        return getDataTable(list);
    }

    @PostMapping("/log")
    @PreAuthorize("@ss.hasPermi('system:wallet:log:add')")
    @Log(title = "Wallet log", businessType = BusinessType.INSERT)
    public AjaxResult addLog(@RequestBody SysUserWalletLog log)
    {
        if (log.getUserId() == null)
        {
            return error("User ID cannot be empty.");
        }
        if (log.getAmount() == null || log.getAmount() == 0)
        {
            return error("Amount cannot be zero.");
        }
        if (StringUtils.isBlank(log.getType()))
        {
            return error("Log type cannot be empty.");
        }
        if (StringUtils.isBlank(log.getCurrencyType()) && log.getWalletId() != null)
        {
            SysUserWallet wallet = walletService.selectWalletById(log.getWalletId());
            if (wallet != null)
            {
                log.setCurrencyType(wallet.getCurrencyType());
            }
        }
        log.setCurrencyType(normalizeCurrencyType(log.getCurrencyType()));
        log.setOperatorName(SecurityUtils.getUsername());
        return AjaxResult.success(logService.insertLog(log));
    }

    @PostMapping("/adjust")
    @PreAuthorize("@ss.hasPermi('system:wallet:edit')")
    @Log(title = "Wallet adjust", businessType = BusinessType.UPDATE)
    @Transactional
    public AjaxResult adjust(@RequestBody WalletAdjustRequest request)
    {
        if (request == null || request.getUserId() == null)
        {
            return error("User ID cannot be empty.");
        }
        if (request.getAmount() == null || request.getAmount() <= 0D)
        {
            return error("Amount must be greater than zero.");
        }
        if (StringUtils.isBlank(request.getDirection()))
        {
            return error("Direction cannot be empty.");
        }
        if (StringUtils.isBlank(request.getType()))
        {
            return error("Type cannot be empty.");
        }

        String currencyType = normalizeCurrencyType(request.getCurrencyType());
        String direction = StringUtils.trim(request.getDirection()).toLowerCase();
        String type = StringUtils.trim(request.getType());
        BigDecimal amountMoney = moneyOf(request.getAmount());
        if (amountMoney.compareTo(BigDecimal.ZERO) <= 0)
        {
            return error("Amount must be greater than zero.");
        }

        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(request.getUserId(), currencyType);
        if (wallet == null)
        {
            SysUserWallet created = new SysUserWallet();
            created.setUserId(request.getUserId());
            created.setUserName(StringUtils.isNotBlank(request.getUserName()) ? request.getUserName().trim() : "");
            created.setCurrencyType(currencyType);
            created.setTotalInvest(0D);
            created.setAvailableBalance(0D);
            created.setUsdExchangeQuota(0D);
            created.setFrozenAmount(0D);
            created.setProfitAmount(0D);
            created.setPendingAmount(0D);
            created.setTotalRecharge(0D);
            created.setTotalWithdraw(0D);
            created.setCreateTime(new Date());
            created.setUpdateTime(new Date());
            walletService.insertWallet(created);
            wallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(request.getUserId(), currencyType);
        }
        if (wallet == null)
        {
            return error("Wallet does not exist.");
        }

        BigDecimal balanceBefore = moneyOf(wallet.getAvailableBalance());
        BigDecimal balanceAfter = balanceBefore;
        BigDecimal amountSigned = amountMoney;

        if ("deduct".equals(direction) || "minus".equals(direction) || "sub".equals(direction))
        {
            amountSigned = amountMoney.negate();
            balanceAfter = balanceBefore.subtract(amountMoney).setScale(2, RoundingMode.HALF_UP);
            if (balanceAfter.compareTo(BigDecimal.ZERO) < 0)
            {
                return error("Insufficient balance.");
            }
        }
        else if ("add".equals(direction) || "plus".equals(direction) || "recharge".equals(direction))
        {
            balanceAfter = balanceBefore.add(amountMoney).setScale(2, RoundingMode.HALF_UP);
        }
        else
        {
            return error("Unsupported direction.");
        }

        wallet.setAvailableBalance(balanceAfter.doubleValue());
        if (amountSigned.signum() > 0)
        {
            if ("recharge".equalsIgnoreCase(type))
            {
                wallet.setTotalRecharge(moneyOf(wallet.getTotalRecharge()).add(amountMoney).doubleValue());
            }
            else if ("profit".equalsIgnoreCase(type))
            {
                wallet.setProfitAmount(moneyOf(wallet.getProfitAmount()).add(amountMoney).doubleValue());
            }
        }
        else
        {
            if ("withdraw".equalsIgnoreCase(type))
            {
                wallet.setTotalWithdraw(moneyOf(wallet.getTotalWithdraw()).add(amountMoney).doubleValue());
            }
            else if ("invest".equalsIgnoreCase(type))
            {
                wallet.setTotalInvest(moneyOf(wallet.getTotalInvest()).add(amountMoney).doubleValue());
            }
        }
        wallet.setUpdateTime(new Date());
        walletService.updateWallet(wallet);

        SysUserWalletLog log = new SysUserWalletLog();
        log.setUserId(wallet.getUserId());
        log.setWalletId(wallet.getWalletId());
        log.setCurrencyType(currencyType);
        log.setAmount(amountSigned.doubleValue());
        log.setType(type);
        log.setStatus("success");
        log.setBalanceBefore(balanceBefore.doubleValue());
        log.setBalanceAfter(balanceAfter.doubleValue());
        log.setOperatorName(SecurityUtils.getUsername());
        log.setRemark(request.getRemark());
        log.setCreateTime(new Date());
        log.setUpdateTime(new Date());
        logService.insertLog(log);

        syncUserTotalsAndLevel(wallet.getUserId(), currencyType, type, amountMoney, amountSigned.signum() > 0);
        return AjaxResult.success();
    }

    @PutMapping("/log")
    @PreAuthorize("@ss.hasPermi('system:wallet:log:edit')")
    @Log(title = "Wallet log", businessType = BusinessType.UPDATE)
    public AjaxResult editLog(@RequestBody SysUserWalletLog log)
    {
        if (log.getLogId() == null)
        {
            return error("Log ID cannot be empty.");
        }
        return AjaxResult.success(logService.updateLog(log));
    }

    @DeleteMapping("/log/{logId}")
    @PreAuthorize("@ss.hasPermi('system:wallet:log:remove')")
    @Log(title = "Wallet log", businessType = BusinessType.DELETE)
    public AjaxResult removeLog(@PathVariable Long logId)
    {
        return AjaxResult.success(logService.deleteLogById(logId));
    }

    @DeleteMapping("/log/batch")
    @PreAuthorize("@ss.hasPermi('system:wallet:log:remove')")
    @Log(title = "Wallet log", businessType = BusinessType.DELETE)
    public AjaxResult removeLogBatch(@RequestBody Long[] logIds)
    {
        return AjaxResult.success(logService.deleteLogByIds(logIds));
    }

    private String normalizeCurrencyType(String currencyType)
    {
        if (StringUtils.isBlank(currencyType))
        {
            return "CNY";
        }
        String normalized = currencyType.trim().toUpperCase();
        return "USD".equals(normalized) ? "USD" : "CNY";
    }

    private void syncUserTotalsAndLevel(Long userId, String currencyType, String type, BigDecimal amount, boolean isAdd)
    {
        if (userId == null || amount == null || amount.compareTo(BigDecimal.ZERO) <= 0)
        {
            return;
        }
        BigDecimal amountCny = toCnyAmount(amount, currencyType);
        if (amountCny.compareTo(BigDecimal.ZERO) <= 0)
        {
            return;
        }

        if (isAdd && "recharge".equalsIgnoreCase(type))
        {
            userMapper.addUserTotalAmounts(userId, BigDecimal.ZERO, amountCny);
            return;
        }
        if (!isAdd && "withdraw".equalsIgnoreCase(type))
        {
            userMapper.addUserTotalAmounts(userId, amountCny.negate(), BigDecimal.ZERO);
            refreshUserLevel(userId);
        }
    }

    private void refreshUserLevel(Long userId)
    {
        com.ruoyi.common.core.domain.entity.SysUser user = userMapper.selectUserBaseById(userId);
        if (user == null)
        {
            return;
        }
        BigDecimal totalInvest = moneyOf(user.getTotalInvestAmount());
        SysUserLevel query = new SysUserLevel();
        query.setStatus("0");
        List<SysUserLevel> levels = userLevelMapper.selectUserLevelList(query);
        if (levels == null || levels.isEmpty())
        {
            return;
        }

        Integer bestLevel = user.getLevel();
        for (SysUserLevel level : levels)
        {
            if (level == null || level.getLevel() == null)
            {
                continue;
            }
            BigDecimal required = level.getRequiredGrowthValue() == null ? BigDecimal.ZERO : BigDecimal.valueOf(level.getRequiredGrowthValue());
            if (totalInvest.compareTo(required) >= 0)
            {
                if (bestLevel == null || level.getLevel() > bestLevel)
                {
                    bestLevel = level.getLevel();
                }
            }
        }

        if (bestLevel != null && (user.getLevel() == null || !bestLevel.equals(user.getLevel())))
        {
            userMapper.updateUserLevelValue(userId, bestLevel);
        }
    }

    private BigDecimal toCnyAmount(BigDecimal amount, String currencyType)
    {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        }
        String normalized = normalizeCurrencyType(currencyType);
        if ("USD".equalsIgnoreCase(normalized))
        {
            BigDecimal rate = readUsdRate();
            if (rate.compareTo(BigDecimal.ZERO) <= 0)
            {
                return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
            }
            return amount.multiply(rate).setScale(2, RoundingMode.HALF_UP);
        }
        return amount.setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal readUsdRate()
    {
        double raw = Convert.toDouble(configService.selectConfigByKey("app.currency.usdRate"), 7.0D);
        if (raw <= 0D)
        {
            raw = 7.0D;
        }
        return BigDecimal.valueOf(raw).setScale(6, RoundingMode.HALF_UP);
    }

    private BigDecimal moneyOf(Double value)
    {
        return BigDecimal.valueOf(value == null ? 0D : value).setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal moneyOf(double value)
    {
        return BigDecimal.valueOf(value).setScale(2, RoundingMode.HALF_UP);
    }

    public static class WalletAdjustRequest
    {
        private Long userId;
        private String userName;
        private String currencyType;
        private Double amount;
        private String direction;
        private String type;
        private String remark;

        public Long getUserId()
        {
            return userId;
        }

        public void setUserId(Long userId)
        {
            this.userId = userId;
        }

        public String getUserName()
        {
            return userName;
        }

        public void setUserName(String userName)
        {
            this.userName = userName;
        }

        public String getCurrencyType()
        {
            return currencyType;
        }

        public void setCurrencyType(String currencyType)
        {
            this.currencyType = currencyType;
        }

        public Double getAmount()
        {
            return amount;
        }

        public void setAmount(Double amount)
        {
            this.amount = amount;
        }

        public String getDirection()
        {
            return direction;
        }

        public void setDirection(String direction)
        {
            this.direction = direction;
        }

        public String getType()
        {
            return type;
        }

        public void setType(String type)
        {
            this.type = type;
        }

        public String getRemark()
        {
            return remark;
        }

        public void setRemark(String remark)
        {
            this.remark = remark;
        }
    }
}
