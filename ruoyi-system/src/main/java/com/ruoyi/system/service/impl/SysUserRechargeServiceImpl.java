package com.ruoyi.system.service.impl;

import java.util.Date;
import java.util.List;
import java.math.BigDecimal;
import java.math.RoundingMode;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.entity.SysUserWallet;
import com.ruoyi.common.core.domain.entity.SysUserWalletLog;
import com.ruoyi.common.core.text.Convert;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.system.domain.SysUserRecharge;
import com.ruoyi.system.domain.SysUserLevel;
import com.ruoyi.system.mapper.SysUserRechargeMapper;
import com.ruoyi.system.mapper.SysUserLevelMapper;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.service.ISysBusinessNoticeService;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysUserRechargeService;
import com.ruoyi.system.service.ISysUserWalletLogService;
import com.ruoyi.system.service.ISysUserWalletService;

/**
 * User recharge service implementation.
 */
@Service
public class SysUserRechargeServiceImpl implements ISysUserRechargeService
{
    private static final int STATUS_PENDING = 0;
    private static final int STATUS_APPROVED = 1;
    private static final int STATUS_REJECTED = 2;

    @Autowired
    private SysUserRechargeMapper rechargeMapper;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ISysUserWalletService walletService;

    @Autowired
    private ISysUserWalletLogService walletLogService;

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private SysUserLevelMapper userLevelMapper;

    @Autowired
    private ISysBusinessNoticeService businessNoticeService;

    @Override
    public SysUserRecharge selectRechargeById(Long rechargeId)
    {
        return rechargeMapper.selectRechargeById(rechargeId);
    }

    @Override
    public List<SysUserRecharge> selectRechargeList(SysUserRecharge recharge)
    {
        return rechargeMapper.selectRechargeList(recharge);
    }

    @Override
    @Transactional
    public int insertRecharge(SysUserRecharge recharge)
    {
        normalizeRecharge(recharge, true);
        recharge.setStatus(STATUS_PENDING);
        recharge.setSubmitTime(new Date());
        recharge.setCreateTime(new Date());
        recharge.setUpdateTime(new Date());
        if (StringUtils.isBlank(recharge.getOrderNo()))
        {
            recharge.setOrderNo(generateOrderNo());
        }
        int rows = rechargeMapper.insertRecharge(recharge);
        if (rows > 0)
        {
            businessNoticeService.insertRechargeNotice(recharge.getUserName(), formatAmount(recharge.getAmount()));
        }
        return rows;
    }

    @Override
    @Transactional
    public int reviewRecharge(SysUserRecharge recharge)
    {
        if (recharge == null || recharge.getRechargeId() == null)
        {
            return 0;
        }

        SysUserRecharge existing = rechargeMapper.selectRechargeById(recharge.getRechargeId());
        if (existing == null)
        {
            return 0;
        }
        if (existing.getStatus() != null && existing.getStatus() != STATUS_PENDING)
        {
            throw new ServiceException("Current recharge order has already been processed.");
        }

        SysUserRecharge target = new SysUserRecharge();
        target.setRechargeId(existing.getRechargeId());
        target.setOrderNo(existing.getOrderNo());
        target.setUserId(existing.getUserId());
        target.setUserName(existing.getUserName());
        target.setCurrencyType(existing.getCurrencyType());
        target.setRechargeMethod(existing.getRechargeMethod());
        target.setAmount(existing.getAmount());
        target.setWalletId(existing.getWalletId());
        target.setStatus(recharge.getStatus());
        target.setRejectReason(StringUtils.isNotBlank(recharge.getRejectReason()) ? recharge.getRejectReason() : existing.getRejectReason());
        target.setSubmitTime(existing.getSubmitTime());
        target.setReviewTime(recharge.getReviewTime());
        target.setReviewUserId(recharge.getReviewUserId());
        target.setReviewUserName(recharge.getReviewUserName());
        target.setRemark(StringUtils.isNotBlank(recharge.getRemark()) ? recharge.getRemark() : existing.getRemark());
        target.setCreateTime(existing.getCreateTime());
        target.setUpdateTime(new Date());

        normalizeRecharge(target, false);
        if (STATUS_REJECTED == target.getStatus() && StringUtils.isBlank(target.getRejectReason()))
        {
            throw new ServiceException("Reject reason is required when rejecting a recharge order.");
        }

        int rows = rechargeMapper.updateRecharge(target);
        if (rows <= 0)
        {
            return rows;
        }

        if (STATUS_APPROVED == target.getStatus())
        {
            SysUserWallet wallet = applyRechargeToWallet(target);
            target.setWalletId(wallet.getWalletId());
            target.setUpdateTime(new Date());
            rechargeMapper.updateRecharge(target);
            syncUserTotalsAndLevel(target);
            businessNoticeService.insertBusinessNotice(
                "充值审核通过",
                String.format(
                    "用户 %s 的充值订单 %s 已通过审核。金额 %s %s 已到账。",
                    target.getUserName(),
                    target.getOrderNo(),
                    formatAmount(target.getAmount()),
                    getCurrencyLabel(target.getCurrencyType()))
            );
        }
        else if (STATUS_REJECTED == target.getStatus())
        {
            businessNoticeService.insertBusinessNotice(
                "充值审核拒绝",
                String.format(
                    "用户 %s 的充值订单 %s 已被拒绝。金额 %s %s。",
                    target.getUserName(),
                    target.getOrderNo(),
                    formatAmount(target.getAmount()),
                    getCurrencyLabel(target.getCurrencyType()))
            );
        }

        return rows;
    }

    @Override
    public int deleteRechargeById(Long rechargeId)
    {
        return rechargeMapper.deleteRechargeById(rechargeId);
    }

    @Override
    public int deleteRechargeByIds(Long[] rechargeIds)
    {
        return rechargeMapper.deleteRechargeByIds(rechargeIds);
    }

    private SysUserWallet applyRechargeToWallet(SysUserRecharge recharge)
    {
        String currencyType = normalizeCurrencyType(recharge.getCurrencyType());
        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyType(recharge.getUserId(), currencyType);
        if (wallet == null)
        {
            wallet = new SysUserWallet();
            wallet.setUserId(recharge.getUserId());
            wallet.setUserName(recharge.getUserName());
            wallet.setCurrencyType(currencyType);
            wallet.setTotalInvest(0D);
            wallet.setAvailableBalance(0D);
            wallet.setUsdExchangeQuota(0D);
            wallet.setFrozenAmount(0D);
            wallet.setProfitAmount(0D);
            wallet.setPendingAmount(0D);
            wallet.setTotalRecharge(0D);
            wallet.setTotalWithdraw(0D);
            wallet.setCreateTime(new Date());
            wallet.setUpdateTime(new Date());
            walletService.insertWallet(wallet);
            wallet = walletService.selectWalletByUserIdAndCurrencyType(recharge.getUserId(), currencyType);
        }
        if (wallet == null)
        {
            throw new ServiceException("User wallet does not exist.");
        }

        double amount = recharge.getAmount() == null ? 0D : recharge.getAmount();
        double balanceBefore = wallet.getAvailableBalance() == null ? 0D : wallet.getAvailableBalance();
        double totalRecharge = wallet.getTotalRecharge() == null ? 0D : wallet.getTotalRecharge();
        wallet.setAvailableBalance(balanceBefore + amount);
        wallet.setTotalRecharge(totalRecharge + amount);
        wallet.setUpdateTime(new Date());
        walletService.updateWallet(wallet);

        SysUserWalletLog log = new SysUserWalletLog();
        log.setUserId(wallet.getUserId());
        log.setWalletId(wallet.getWalletId());
        log.setCurrencyType(currencyType);
        log.setAmount(amount);
        log.setType("recharge");
        log.setStatus("success");
        log.setBalanceBefore(balanceBefore);
        log.setBalanceAfter(wallet.getAvailableBalance());
        log.setOrderNo(recharge.getOrderNo());
        log.setOperatorName(recharge.getReviewUserName());
        log.setRemark("Recharge approved");
        log.setCreateTime(new Date());
        log.setUpdateTime(new Date());
        walletLogService.insertLog(log);
        return wallet;
    }

    private void syncUserTotalsAndLevel(SysUserRecharge recharge)
    {
        if (recharge == null || recharge.getUserId() == null)
        {
            return;
        }
        BigDecimal amountCny = toCnyAmount(recharge.getAmount(), recharge.getCurrencyType());
        if (amountCny.compareTo(BigDecimal.ZERO) <= 0)
        {
            return;
        }

        userMapper.addUserTotalAmounts(recharge.getUserId(), BigDecimal.ZERO, amountCny);
    }

    private void refreshUserLevel(Long userId)
    {
        SysUser user = userMapper.selectUserBaseById(userId);
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

    private BigDecimal toCnyAmount(Double amount, String currencyType)
    {
        BigDecimal money = moneyOf(amount);
        if (money.compareTo(BigDecimal.ZERO) <= 0)
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
            return money.multiply(rate).setScale(2, RoundingMode.HALF_UP);
        }
        return money.setScale(2, RoundingMode.HALF_UP);
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

    private void normalizeRecharge(SysUserRecharge recharge, boolean submitPhase)
    {
        if (recharge == null)
        {
            throw new ServiceException("Recharge data cannot be empty.");
        }
        if (recharge.getAmount() == null || recharge.getAmount() <= 0)
        {
            throw new ServiceException("Recharge amount must be greater than zero.");
        }

        int investMode = Convert.toInt(configService.selectConfigByKey("app.currency.investMode"), 1);
        String currencyType = normalizeCurrencyType(recharge.getCurrencyType());
        String method = normalizeRechargeMethod(recharge.getRechargeMethod(), currencyType);
        if (investMode == 1)
        {
            currencyType = "CNY";
            method = "RMB";
        }
        recharge.setCurrencyType(currencyType);
        recharge.setRechargeMethod(method);

        if (!submitPhase && recharge.getStatus() != null)
        {
            if (recharge.getStatus() != STATUS_APPROVED && recharge.getStatus() != STATUS_REJECTED)
            {
                throw new ServiceException("Invalid review status.");
            }
        }
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

    private String normalizeRechargeMethod(String rechargeMethod, String currencyType)
    {
        if ("USD".equalsIgnoreCase(currencyType))
        {
            return "USDT";
        }
        if (StringUtils.isBlank(rechargeMethod))
        {
            return "RMB";
        }
        String normalized = rechargeMethod.trim().toUpperCase();
        if ("USDT".equals(normalized) || "USD".equals(normalized))
        {
            return "USDT";
        }
        return "RMB";
    }

    private String getCurrencyLabel(String currencyType)
    {
        return "USD".equalsIgnoreCase(currencyType) ? "USD" : "CNY";
    }

    private String formatAmount(Double amount)
    {
        return String.format("%.2f", amount == null ? 0D : amount);
    }

    private String generateOrderNo()
    {
        return "RC" + DateUtils.dateTimeNow() + IdUtils.fastSimpleUUID().substring(0, 8).toUpperCase();
    }
}
