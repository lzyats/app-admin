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
import com.ruoyi.system.domain.SysUserLevel;
import com.ruoyi.system.domain.SysUserBankCard;
import com.ruoyi.system.domain.SysUserWithdraw;
import com.ruoyi.system.mapper.SysUserLevelMapper;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.mapper.SysUserWithdrawMapper;
import com.ruoyi.system.service.ISysBusinessNoticeService;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysUserBankCardService;
import com.ruoyi.system.service.ISysUserService;
import com.ruoyi.system.service.ISysUserWalletLogService;
import com.ruoyi.system.service.ISysUserWalletService;
import com.ruoyi.system.service.ISysUserWithdrawService;

/**
 * 用户提现服务实现类。
 */
@Service
public class SysUserWithdrawServiceImpl implements ISysUserWithdrawService
{
    private static final int STATUS_PENDING = 0;
    private static final int STATUS_APPROVED = 1;
    private static final int STATUS_REJECTED = 2;
    private static final int REAL_NAME_APPROVED = 3;

    @Autowired
    private SysUserWithdrawMapper withdrawMapper;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private SysUserLevelMapper userLevelMapper;

    @Autowired
    private ISysUserBankCardService bankCardService;

    @Autowired
    private ISysUserWalletService walletService;

    @Autowired
    private ISysUserWalletLogService walletLogService;

    @Autowired
    private ISysBusinessNoticeService businessNoticeService;

    @Override
    public SysUserWithdraw selectWithdrawById(Long withdrawId)
    {
        return withdrawMapper.selectWithdrawById(withdrawId);
    }

    @Override
    public List<SysUserWithdraw> selectWithdrawList(SysUserWithdraw withdraw)
    {
        return withdrawMapper.selectWithdrawList(withdraw);
    }

    @Override
    @Transactional
    public int insertWithdraw(SysUserWithdraw withdraw)
    {
        normalizeWithdraw(withdraw);
        if (StringUtils.isBlank(withdraw.getRequestNo()))
        {
            throw new ServiceException("Request number cannot be empty.");
        }
        if (StringUtils.isBlank(withdraw.getOrderNo()))
        {
            withdraw.setOrderNo(generateOrderNo());
        }
        String currencyType = normalizeCurrencyType(withdraw.getCurrencyType());
        SysUserWallet lockedWallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(withdraw.getUserId(), currencyType);
        if (lockedWallet == null)
        {
            throw new ServiceException("用户钱包不存在。");
        }
        SysUserWithdraw existing = withdrawMapper.selectWithdrawByRequestNo(withdraw.getRequestNo());
        if (existing != null)
        {
            return 1;
        }
        resolveWithdrawalSnapshot(withdraw, lockedWallet);
        freezeWithdrawAmount(withdraw, lockedWallet);
        withdraw.setStatus(STATUS_PENDING);
        withdraw.setSubmitTime(new Date());
        withdraw.setCreateTime(new Date());
        withdraw.setUpdateTime(new Date());
        int rows = withdrawMapper.insertWithdraw(withdraw);
        if (rows > 0)
        {
            businessNoticeService.insertWithdrawNotice(
                withdraw.getUserName(),
                formatAmount(withdraw.getAmount()) + " " + getCurrencyLabelCn(withdraw.getCurrencyType()));
        }
        return rows;
    }

    @Override
    @Transactional
    public int reviewWithdraw(SysUserWithdraw withdraw)
    {
        if (withdraw == null || withdraw.getWithdrawId() == null)
        {
            return 0;
        }
        SysUserWithdraw existing = withdrawMapper.selectWithdrawById(withdraw.getWithdrawId());
        if (existing == null)
        {
            return 0;
        }
        if (existing.getStatus() != null && existing.getStatus() != STATUS_PENDING)
        {
            throw new ServiceException("当前提现订单已处理。");
        }

        SysUserWithdraw target = new SysUserWithdraw();
        target.setWithdrawId(existing.getWithdrawId());
        target.setOrderNo(existing.getOrderNo());
        target.setUserId(existing.getUserId());
        target.setUserName(existing.getUserName());
        target.setCurrencyType(existing.getCurrencyType());
        target.setWithdrawMethod(existing.getWithdrawMethod());
        target.setBankCardId(existing.getBankCardId());
        target.setBankName(existing.getBankName());
        target.setAccountNo(existing.getAccountNo());
        target.setAccountName(existing.getAccountName());
        target.setWalletAddress(existing.getWalletAddress());
        target.setAmount(existing.getAmount());
        target.setWalletId(existing.getWalletId());
        target.setStatus(withdraw.getStatus());
        target.setRejectReason(StringUtils.isNotBlank(withdraw.getRejectReason()) ? withdraw.getRejectReason() : existing.getRejectReason());
        target.setSubmitTime(existing.getSubmitTime());
        target.setReviewTime(withdraw.getReviewTime() != null ? withdraw.getReviewTime() : new Date());
        target.setReviewUserId(withdraw.getReviewUserId());
        target.setReviewUserName(withdraw.getReviewUserName());
        target.setRemark(StringUtils.isNotBlank(withdraw.getRemark()) ? withdraw.getRemark() : existing.getRemark());
        target.setCreateTime(existing.getCreateTime());
        target.setUpdateTime(new Date());

        if (target.getStatus() != STATUS_APPROVED && target.getStatus() != STATUS_REJECTED)
        {
            throw new ServiceException("无效的审核状态。");
        }
        if (target.getStatus() == STATUS_REJECTED && StringUtils.isBlank(target.getRejectReason()))
        {
            throw new ServiceException("提现拒绝时必须填写拒绝原因。");
        }

        int rows = withdrawMapper.updateWithdraw(target);
        if (rows <= 0)
        {
            return rows;
        }

        if (STATUS_APPROVED == target.getStatus())
        {
            approveWithdrawAmount(target);
            businessNoticeService.insertBusinessNotice(
                "提现审核通过",
                String.format("用户 %s 的提现订单 %s 已审核通过，金额 %s %s 已完成处理。",
                    target.getUserName(),
                    target.getOrderNo(),
                    formatAmount(target.getAmount()),
                    getCurrencyLabelCn(target.getCurrencyType()))
            );
        }
        else
        {
            rejectWithdrawAmount(target);
            businessNoticeService.insertBusinessNotice(
                "提现审核拒绝",
                String.format("用户 %s 的提现订单 %s 已审核拒绝，金额 %s %s 已解冻返还。",
                    target.getUserName(),
                    target.getOrderNo(),
                    formatAmount(target.getAmount()),
                    getCurrencyLabelCn(target.getCurrencyType()))
            );
        }

        return rows;
    }

    @Override
    public int deleteWithdrawById(Long withdrawId)
    {
        return withdrawMapper.deleteWithdrawById(withdrawId);
    }

    @Override
    public int deleteWithdrawByIds(Long[] withdrawIds)
    {
        return withdrawMapper.deleteWithdrawByIds(withdrawIds);
    }

    private void normalizeWithdraw(SysUserWithdraw withdraw)
    {
        if (withdraw == null)
        {
            throw new ServiceException("提现数据不能为空。");
        }
        if (withdraw.getUserId() == null || withdraw.getUserId() <= 0)
        {
            throw new ServiceException("用户ID不能为空。");
        }
        if (withdraw.getAmount() == null || withdraw.getAmount() <= 0)
        {
            throw new ServiceException("提现金额必须大于0。");
        }

        int investMode = Convert.toInt(configService.selectConfigByKey("app.currency.investMode"), 1);
        String currencyType = normalizeCurrencyType(withdraw.getCurrencyType());
        String withdrawMethod = normalizeWithdrawMethod(withdraw.getWithdrawMethod(), currencyType);
        if (investMode == 1)
        {
            currencyType = "CNY";
            withdrawMethod = "BANK";
        }
        withdraw.setCurrencyType(currencyType);
        withdraw.setWithdrawMethod(withdrawMethod);

        SysUser user = userService.selectUserById(withdraw.getUserId());
        if (user == null)
        {
            throw new ServiceException("用户不存在。");
        }
        if ("CNY".equals(currencyType) && (user.getRealNameStatus() == null || user.getRealNameStatus() != REAL_NAME_APPROVED))
        {
            throw new ServiceException("人民币提现前必须先完成实名认证。");
        }
        withdraw.setUserName(StringUtils.isNotBlank(withdraw.getUserName()) ? withdraw.getUserName() : user.getUserName());

        // 余额校验在行锁内完成，避免并发重复冻结。
    }

    private void resolveWithdrawalSnapshot(SysUserWithdraw withdraw, SysUserWallet wallet)
    {
        String currencyType = normalizeCurrencyType(withdraw.getCurrencyType());
        withdraw.setWalletId(wallet.getWalletId());

        SysUserBankCard bankCard = resolveBankCard(withdraw.getUserId(), currencyType, withdraw.getBankCardId());
        withdraw.setBankCardId(bankCard.getBankCardId());
        if ("USD".equals(currencyType))
        {
            withdraw.setWalletAddress(bankCard.getWalletAddress());
            withdraw.setBankName(null);
            withdraw.setAccountNo(null);
            withdraw.setAccountName(null);
        }
        else
        {
            withdraw.setBankName(bankCard.getBankName());
            withdraw.setAccountNo(bankCard.getAccountNo());
            withdraw.setAccountName(bankCard.getAccountName());
            withdraw.setWalletAddress(null);
        }
    }

    private void freezeWithdrawAmount(SysUserWithdraw withdraw, SysUserWallet wallet)
    {
        String currencyType = normalizeCurrencyType(withdraw.getCurrencyType());
        double amount = withdraw.getAmount() == null ? 0D : withdraw.getAmount();
        double availableBefore = wallet.getAvailableBalance() == null ? 0D : wallet.getAvailableBalance();
        double frozenBefore = wallet.getFrozenAmount() == null ? 0D : wallet.getFrozenAmount();
        if (availableBefore < amount)
        {
            throw new ServiceException("可用余额不足。");
        }

        wallet.setAvailableBalance(availableBefore - amount);
        wallet.setFrozenAmount(frozenBefore + amount);
        wallet.setUpdateTime(new Date());
        walletService.updateWallet(wallet);

        SysUserWalletLog log = new SysUserWalletLog();
        log.setUserId(wallet.getUserId());
        log.setWalletId(wallet.getWalletId());
        log.setCurrencyType(currencyType);
        log.setAmount(-amount);
        log.setType("frozen");
        log.setStatus("pending");
        log.setBalanceBefore(availableBefore);
        log.setBalanceAfter(wallet.getAvailableBalance());
        log.setOrderNo(withdraw.getOrderNo());
        log.setOperatorName(withdraw.getUserName());
        log.setRemark("提现提交并冻结金额");
        log.setCreateTime(new Date());
        log.setUpdateTime(new Date());
        walletLogService.insertLog(log);
    }

    private void approveWithdrawAmount(SysUserWithdraw withdraw)
    {
        String currencyType = normalizeCurrencyType(withdraw.getCurrencyType());
        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(withdraw.getUserId(), currencyType);
        if (wallet == null)
        {
            throw new ServiceException("用户钱包不存在。");
        }

        double amount = withdraw.getAmount() == null ? 0D : withdraw.getAmount();
        double frozenBefore = wallet.getFrozenAmount() == null ? 0D : wallet.getFrozenAmount();
        if (frozenBefore < amount)
        {
            throw new ServiceException("冻结金额不足。");
        }

        double availableBalance = wallet.getAvailableBalance() == null ? 0D : wallet.getAvailableBalance();
        double totalWithdraw = wallet.getTotalWithdraw() == null ? 0D : wallet.getTotalWithdraw();
        wallet.setFrozenAmount(frozenBefore - amount);
        wallet.setTotalWithdraw(totalWithdraw + amount);
        wallet.setUpdateTime(new Date());
        walletService.updateWallet(wallet);

        SysUserWalletLog log = new SysUserWalletLog();
        log.setUserId(wallet.getUserId());
        log.setWalletId(wallet.getWalletId());
        log.setCurrencyType(currencyType);
        log.setAmount(0D);
        log.setType("withdraw");
        log.setStatus("success");
        log.setBalanceBefore(availableBalance);
        log.setBalanceAfter(availableBalance);
        log.setOrderNo(withdraw.getOrderNo());
        log.setOperatorName(withdraw.getReviewUserName());
        log.setRemark("提现审核通过，冻结金额已扣除");
        log.setCreateTime(new Date());
        log.setUpdateTime(new Date());
        walletLogService.insertLog(log);

        syncUserTotalsAndLevel(withdraw);
    }

    private void syncUserTotalsAndLevel(SysUserWithdraw withdraw)
    {
        if (withdraw == null || withdraw.getUserId() == null)
        {
            return;
        }
        BigDecimal amountCny = toCnyAmount(withdraw.getAmount(), withdraw.getCurrencyType());
        if (amountCny.compareTo(BigDecimal.ZERO) <= 0)
        {
            return;
        }
        userMapper.addUserTotalAmounts(withdraw.getUserId(), amountCny.negate(), BigDecimal.ZERO);
        refreshUserLevel(withdraw.getUserId());
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

    private void rejectWithdrawAmount(SysUserWithdraw withdraw)
    {
        String currencyType = normalizeCurrencyType(withdraw.getCurrencyType());
        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(withdraw.getUserId(), currencyType);
        if (wallet == null)
        {
            throw new ServiceException("用户钱包不存在。");
        }

        double amount = withdraw.getAmount() == null ? 0D : withdraw.getAmount();
        double frozenBefore = wallet.getFrozenAmount() == null ? 0D : wallet.getFrozenAmount();
        if (frozenBefore < amount)
        {
            throw new ServiceException("冻结金额不足。");
        }

        double availableBefore = wallet.getAvailableBalance() == null ? 0D : wallet.getAvailableBalance();
        wallet.setFrozenAmount(frozenBefore - amount);
        wallet.setAvailableBalance(availableBefore + amount);
        wallet.setUpdateTime(new Date());
        walletService.updateWallet(wallet);

        SysUserWalletLog log = new SysUserWalletLog();
        log.setUserId(wallet.getUserId());
        log.setWalletId(wallet.getWalletId());
        log.setCurrencyType(currencyType);
        log.setAmount(amount);
        log.setType("unfrozen");
        log.setStatus("success");
        log.setBalanceBefore(availableBefore);
        log.setBalanceAfter(wallet.getAvailableBalance());
        log.setOrderNo(withdraw.getOrderNo());
        log.setOperatorName(withdraw.getReviewUserName());
        log.setRemark("提现审核拒绝，冻结金额已解冻");
        log.setCreateTime(new Date());
        log.setUpdateTime(new Date());
        walletLogService.insertLog(log);
    }

    private SysUserBankCard resolveBankCard(Long userId, String currencyType, Long bankCardId)
    {
        SysUserBankCard query = new SysUserBankCard();
        query.setUserId(userId);
        query.setCurrencyType(currencyType);
        List<SysUserBankCard> cards = bankCardService.selectBankCardList(query);
        if (cards == null || cards.isEmpty())
        {
            throw new ServiceException("请先绑定对应币种的收款账户。");
        }
        if (bankCardId != null && bankCardId > 0)
        {
            for (SysUserBankCard card : cards)
            {
                if (bankCardId.equals(card.getBankCardId()))
                {
                    return card;
                }
            }
            throw new ServiceException("所选收款账户无效。");
        }
        return cards.get(0);
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

    private String normalizeWithdrawMethod(String withdrawMethod, String currencyType)
    {
        if ("USD".equalsIgnoreCase(currencyType))
        {
            return "USDT";
        }
        if (StringUtils.isBlank(withdrawMethod))
        {
            return "BANK";
        }
        String normalized = withdrawMethod.trim().toUpperCase();
        if ("USDT".equals(normalized))
        {
            return "USDT";
        }
        return "BANK";
    }

    private String getCurrencyLabelCn(String currencyType)
    {
        return "USD".equalsIgnoreCase(currencyType) ? "USDT" : "人民币";
    }

    private String formatAmount(Double amount)
    {
        return String.format("%.2f", amount == null ? 0D : amount);
    }

    private String generateOrderNo()
    {
        return "WD" + DateUtils.dateTimeNow() + IdUtils.fastSimpleUUID().substring(0, 8).toUpperCase();
    }
}
