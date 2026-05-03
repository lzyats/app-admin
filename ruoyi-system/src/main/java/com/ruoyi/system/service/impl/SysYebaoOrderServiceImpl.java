package com.ruoyi.system.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;
import com.ruoyi.common.core.domain.entity.SysUserWallet;
import com.ruoyi.common.core.domain.entity.SysUserWalletLog;
import com.ruoyi.common.core.text.Convert;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysYebaoConfig;
import com.ruoyi.system.domain.SysYebaoIncomeLog;
import com.ruoyi.system.domain.SysYebaoOrder;
import com.ruoyi.system.domain.SysUserLevel;
import com.ruoyi.system.mapper.SysYebaoIncomeLogMapper;
import com.ruoyi.system.mapper.SysYebaoOrderMapper;
import com.ruoyi.system.mapper.SysUserLevelMapper;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.service.ISysUserWalletLogService;
import com.ruoyi.system.service.ISysUserWalletService;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysYebaoConfigService;
import com.ruoyi.system.service.ISysYebaoIncomeLogService;
import com.ruoyi.system.service.ISysYebaoOrderService;
import com.ruoyi.system.service.ISysGrowthValueService;

@Service
public class SysYebaoOrderServiceImpl implements ISysYebaoOrderService
{
    private static final Logger logger = LoggerFactory.getLogger(SysYebaoOrderServiceImpl.class);
    private static final long MILLIS_PER_DAY = 24L * 60L * 60L * 1000L;
    private static final String KEY_YEBAO_LEVEL_BONUS_ENABLED = "app.yebao.levelBonusEnabled";

    @Autowired
    private SysYebaoOrderMapper orderMapper;

    @Autowired
    private SysYebaoIncomeLogMapper incomeLogMapper;

    @Autowired
    private ISysYebaoConfigService yebaoConfigService;

    @Autowired
    private ISysUserWalletService walletService;

    @Autowired
    private ISysUserWalletLogService walletLogService;

    @Autowired
    private ISysYebaoIncomeLogService incomeLogService;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private SysUserLevelMapper userLevelMapper;

    @Autowired
    private ISysGrowthValueService growthValueService; // 注入成长值服务

    @Autowired
    private PlatformTransactionManager transactionManager;

    @Override
    public List<SysYebaoOrder> selectYebaoOrderList(SysYebaoOrder order)
    {
        try
        {
            return orderMapper.selectYebaoOrderList(order);
        }
        catch (Exception e)
        {
            logger.warn("Select yebao order list failed, return empty list: {}", e.getMessage());
            return new ArrayList<>();
        }
    }

    @Override
    public List<SysYebaoOrder> selectAppYebaoOrderList(Long userId)
    {
        try
        {
            return orderMapper.selectAppYebaoOrderList(userId);
        }
        catch (Exception e)
        {
            logger.warn("Select app yebao order list failed, return empty list: {}", e.getMessage());
            return new ArrayList<>();
        }
    }

    @Override
    public List<SysYebaoIncomeLog> selectAppYebaoIncomeLogList(Long userId)
    {
        try
        {
            return incomeLogService.selectAppYebaoIncomeLogList(userId);
        }
        catch (Exception e)
        {
            logger.warn("Select app yebao income list failed, return empty list: {}", e.getMessage());
            return new ArrayList<>();
        }
    }

    @Override
    public List<SysYebaoOrder> selectDueYebaoOrderList()
    {
        try
        {
            return orderMapper.selectDueYebaoOrderList(new Date());
        }
        catch (Exception e)
        {
            logger.warn("Select due yebao order list failed, return empty list: {}", e.getMessage());
            return new ArrayList<>();
        }
    }

    @Override
    public SysYebaoOrder selectYebaoOrderById(Long orderId)
    {
        try
        {
            return orderMapper.selectYebaoOrderById(orderId);
        }
        catch (Exception e)
        {
            logger.warn("Select yebao order by id failed, return null: {}", e.getMessage());
            return null;
        }
    }

    @Override
    public Map<String, Object> selectAppYebaoDetail(Long userId)
    {
        Map<String, Object> result = new LinkedHashMap<>();
        SysYebaoConfig config = yebaoConfigService.selectCurrentYebaoConfig();
        double totalPrincipal = 0D;
        double totalIncome = 0D;
        double todayIncome = 0D;
        Integer orderCountValue = 0;
        try
        {
            totalPrincipal = nullSafe(orderMapper.selectUserPrincipalTotal(userId));
            totalIncome = nullSafe(orderMapper.selectUserSettledIncomeTotal(userId));
            todayIncome = nullSafe(orderMapper.selectUserTodayIncomeTotal(userId));
            Integer queryOrderCount = orderMapper.selectUserOrderCount(userId);
            orderCountValue = queryOrderCount == null ? 0 : queryOrderCount;
        }
        catch (Exception e)
        {
            logger.warn("Select yebao aggregate failed, use defaults: {}", e.getMessage());
        }
        int orderCount = orderCountValue == null ? 0 : orderCountValue;

        result.put("config", config);
        result.put("totalPrincipal", scale2(totalPrincipal));
        result.put("totalIncome", scale2(totalIncome));
        result.put("todayIncome", scale2(todayIncome));
        result.put("orderCount", orderCount);
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int purchase(Long userId, Integer shares, String remark)
    {
        if (userId == null || userId <= 0)
        {
            throw new ServiceException("User ID cannot be empty");
        }
        if (shares == null || shares <= 0)
        {
            throw new ServiceException("Shares must be greater than 0");
        }
        SysYebaoConfig config = yebaoConfigService.selectCurrentYebaoConfig();
        if (config == null)
        {
            throw new ServiceException("Yebao config not found");
        }
        BigDecimal unitAmount = bd(config.getUnitAmount() == null ? 100D : config.getUnitAmount());
        BigDecimal principal = unitAmount.multiply(BigDecimal.valueOf(shares.longValue())).setScale(2, RoundingMode.DOWN);
        if (principal.compareTo(BigDecimal.ZERO) <= 0)
        {
            throw new ServiceException("Purchase amount must be greater than 0");
        }

        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(userId, "CNY");
        if (wallet == null)
        {
            throw new ServiceException("CNY wallet not found");
        }
        BigDecimal balanceBefore = bd(wallet.getAvailableBalance());
        if (balanceBefore.compareTo(principal) < 0)
        {
            throw new ServiceException("Insufficient balance");
        }

        BigDecimal balanceAfter = balanceBefore.subtract(principal).setScale(2, RoundingMode.DOWN);
        wallet.setAvailableBalance(balanceAfter.doubleValue());
        wallet.setTotalInvest(scale2(bd(wallet.getTotalInvest()).add(principal).doubleValue()));
        wallet.setUpdateTime(new Date());
        walletService.updateWallet(wallet);

        String orderNo = buildNo("YB");
        Date now = new Date();
        SysYebaoOrder order = new SysYebaoOrder();
        order.setOrderNo(orderNo);
        order.setUserId(userId);
        order.setUserName(SecurityUtils.getUsername());
        order.setShares(shares);
        order.setUnitAmount(scale2(unitAmount.doubleValue()));
        order.setPrincipalAmount(scale2(principal.doubleValue()));
        order.setAnnualRate(config.getAnnualRate() == null ? 0D : config.getAnnualRate());
        order.setSettledIncome(0D);
        order.setInvestTime(now);
        order.setLastSettleTime(now);
        order.setNextSettleTime(new Date(now.getTime() + MILLIS_PER_DAY));
        order.setStatus("0");
        order.setCreateBy(SecurityUtils.getUsername());
        order.setCreateTime(now);
        order.setRemark(StringUtils.isNotBlank(remark) ? remark.trim() : "Yebao purchase");
        int rows = orderMapper.insertYebaoOrder(order);

        SysUserWalletLog log = new SysUserWalletLog();
        log.setUserId(userId);
        log.setWalletId(wallet.getWalletId());
        log.setCurrencyType("CNY");
        log.setAmount(scale2(principal.doubleValue()));
        log.setType("invest");
        log.setStatus("success");
        log.setBalanceBefore(scale2(balanceBefore.doubleValue()));
        log.setBalanceAfter(scale2(balanceAfter.doubleValue()));
        log.setOrderNo(orderNo);
        log.setOperatorName(SecurityUtils.getUsername());
        log.setRemark(StringUtils.isNotBlank(remark) ? remark.trim() : "Yebao purchase");
        log.setCreateTime(now);
        walletLogService.insertLog(log);
        return rows;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int redeem(Long userId, Long orderId)
    {
        if (userId == null || userId <= 0)
        {
            throw new ServiceException("User ID cannot be empty");
        }
        if (orderId == null || orderId <= 0)
        {
            throw new ServiceException("Order ID cannot be empty");
        }

        SysYebaoOrder order = orderMapper.selectYebaoOrderByIdForUpdate(orderId);
        if (order == null)
        {
            throw new ServiceException("Yebao order not found");
        }
        if (!userId.equals(order.getUserId()))
        {
            throw new ServiceException("No permission to redeem this order");
        }
        if (!"0".equals(order.getStatus()))
        {
            throw new ServiceException("This order has already been redeemed");
        }
        if (isRedeemAfter24hRequired() && order.getNextSettleTime() != null && new Date().before(order.getNextSettleTime()))
        {
            throw new ServiceException("余额宝必须持有24小时后才能赎回");
        }

        settleOneOrderInternal(order);

        BigDecimal principal = bd(order.getPrincipalAmount());
        BigDecimal settledIncome = bd(order.getSettledIncome());
        BigDecimal redeemAmount = principal.add(settledIncome).setScale(2, RoundingMode.DOWN);

        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(userId, "CNY");
        if (wallet == null)
        {
            throw new ServiceException("CNY wallet not found");
        }

        BigDecimal balanceBefore = bd(wallet.getAvailableBalance());
        BigDecimal balanceAfter = balanceBefore.add(redeemAmount).setScale(2, RoundingMode.DOWN);
        BigDecimal totalInvestBefore = bd(wallet.getTotalInvest());
        BigDecimal totalInvestAfter = totalInvestBefore.subtract(principal).setScale(2, RoundingMode.DOWN);
        if (totalInvestAfter.compareTo(BigDecimal.ZERO) < 0)
        {
            totalInvestAfter = BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }

        wallet.setAvailableBalance(balanceAfter.doubleValue());
        wallet.setTotalInvest(totalInvestAfter.doubleValue());
        wallet.setUpdateTime(new Date());
        walletService.updateWallet(wallet);

        order.setStatus("1");
        order.setUpdateBy(SecurityUtils.getUsername());
        order.setUpdateTime(new Date());
        orderMapper.updateYebaoOrder(order);

        SysUserWalletLog log = new SysUserWalletLog();
        log.setUserId(userId);
        log.setWalletId(wallet.getWalletId());
        log.setCurrencyType("CNY");
        log.setAmount(scale2(redeemAmount.doubleValue()));
        log.setType("redeem");
        log.setStatus("success");
        log.setBalanceBefore(scale2(balanceBefore.doubleValue()));
        log.setBalanceAfter(scale2(balanceAfter.doubleValue()));
        log.setOrderNo(order.getOrderNo());
        log.setOperatorName(SecurityUtils.getUsername());
        log.setRemark("Yebao redeem");
        log.setCreateTime(new Date());
        walletLogService.insertLog(log);
        return 1;
    }

    private boolean isRedeemAfter24hRequired()
    {
        try
        {
            String raw = configService.selectConfigByKey("app.yebao.redeemAfter24h");
            if (StringUtils.isBlank(raw))
            {
                return true;
            }
            return "true".equalsIgnoreCase(raw) || "1".equals(raw);
        }
        catch (Exception e)
        {
            logger.warn("Read yebao redeem-after-24h config failed, use default true: {}", e.getMessage());
            return true;
        }
    }

    @Override
    public int settleDueIncome()
    {
        List<SysYebaoOrder> dueOrders = orderMapper.selectDueYebaoOrderList(new Date());
        AtomicInteger settled = new AtomicInteger(0);
        TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager);
        for (SysYebaoOrder order : dueOrders)
        {
            try
            {
                transactionTemplate.executeWithoutResult(status -> settled.addAndGet(settleOneOrderInternal(order)));
            }
            catch (Exception e)
            {
                logger.warn("Yebao settlement failed, orderNo={}, msg={}", order == null ? null : order.getOrderNo(), e.getMessage());
            }
        }
        return settled.get();
    }

    protected int settleOneOrderInternal(SysYebaoOrder order)
    {
        if (order == null || order.getOrderId() == null)
        {
            return 0;
        }
        Date now = new Date();
        Date lastSettleTime = order.getLastSettleTime() == null ? order.getInvestTime() : order.getLastSettleTime();
        if (lastSettleTime == null)
        {
            lastSettleTime = order.getCreateTime() == null ? now : order.getCreateTime();
        }
        long diffMillis = now.getTime() - lastSettleTime.getTime();
        long settleDays = diffMillis / MILLIS_PER_DAY;
        if (settleDays <= 0)
        {
            return 0;
        }

        BigDecimal principal = bd(order.getPrincipalAmount());
        BigDecimal annualRate = bd(order.getAnnualRate());
        BigDecimal income = principal
                .multiply(annualRate)
                .divide(BigDecimal.valueOf(100), 8, RoundingMode.DOWN)
                .multiply(BigDecimal.valueOf(settleDays))
                .divide(BigDecimal.valueOf(365), 2, RoundingMode.DOWN);
        if (isYebaoLevelBonusEnabled())
        {
            BigDecimal bonusPercent = resolveInvestBonusPercent(order.getUserId());
            if (bonusPercent.compareTo(BigDecimal.ZERO) > 0)
            {
                BigDecimal multiplier = BigDecimal.ONE.add(bonusPercent.divide(BigDecimal.valueOf(100), 8, RoundingMode.DOWN));
                income = income.multiply(multiplier).setScale(2, RoundingMode.DOWN);
            }
        }

        // 获取余额宝配置，用于获取每份成长值（支持小数，如 0.1）
        SysYebaoConfig yebaoConfig = yebaoConfigService.selectCurrentYebaoConfig();
        if (yebaoConfig != null && yebaoConfig.getGrowthValuePerUnit() != null
                && yebaoConfig.getGrowthValuePerUnit().compareTo(BigDecimal.ZERO) > 0)
        {
            // 计算本次结算应增加的成长值（成长值总账仍为整数，按向下取整入账）
            Long growthValueToAdd = yebaoConfig.getGrowthValuePerUnit()
                    .multiply(BigDecimal.valueOf(order.getShares()))
                    .setScale(0, RoundingMode.DOWN)
                    .longValue();
            if (growthValueToAdd > 0) {
                // 调用成长值服务增加用户成长值
                growthValueService.increaseGrowthValue(
                        order.getUserId(),
                        growthValueToAdd,
                        "yebao_settlement", // 来源类型
                        order.getOrderId(),  // 来源ID
                        order.getOrderNo(),  // 来源单号
                        "余额宝结算增加成长值" // 备注
                );
            }
        }

        Date periodEndTime = new Date(lastSettleTime.getTime() + settleDays * MILLIS_PER_DAY);
        order.setSettledIncome(scale2(bd(order.getSettledIncome()).add(income).doubleValue()));
        order.setLastSettleTime(periodEndTime);
        order.setNextSettleTime(new Date(periodEndTime.getTime() + MILLIS_PER_DAY));
        order.setUpdateBy("system");
        orderMapper.updateYebaoOrder(order);

        SysYebaoIncomeLog log = new SysYebaoIncomeLog();
        log.setIncomeNo(buildNo("YI"));
        log.setOrderId(order.getOrderId());
        log.setOrderNo(order.getOrderNo());
        log.setUserId(order.getUserId());
        log.setUserName(order.getUserName());
        log.setShares(order.getShares());
        log.setPrincipalAmount(scale2(principal.doubleValue()));
        log.setAnnualRate(scale2(annualRate.doubleValue()));
        log.setSettleDays((int) settleDays);
        log.setIncomeAmount(scale2(income.doubleValue()));
        log.setPeriodStartTime(lastSettleTime);
        log.setPeriodEndTime(periodEndTime);
        log.setSettleTime(now);
        log.setStatus("0");
        log.setCreateBy("system");
        log.setCreateTime(now);
        log.setRemark("Yebao daily settlement");
        incomeLogMapper.insertYebaoIncomeLog(log);
        return 1;
    }

    private boolean isYebaoLevelBonusEnabled()
    {
        try
        {
            return Convert.toBool(configService.selectConfigByKey(KEY_YEBAO_LEVEL_BONUS_ENABLED), false);
        }
        catch (Exception e)
        {
            logger.warn("Read yebao level bonus config failed, use default false: {}", e.getMessage());
            return false;
        }
    }

    private BigDecimal resolveInvestBonusPercent(Long userId)
    {
        if (userId == null || userId <= 0)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        com.ruoyi.common.core.domain.entity.SysUser user = userMapper.selectUserBaseById(userId);
        if (user == null || user.getLevel() == null)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        SysUserLevel query = new SysUserLevel();
        query.setLevel(user.getLevel());
        query.setStatus("0");
        List<SysUserLevel> list = userLevelMapper.selectUserLevelList(query);
        if (list == null || list.isEmpty())
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        BigDecimal bonus = list.get(0).getInvestBonus();
        if (bonus == null || bonus.compareTo(BigDecimal.ZERO) <= 0)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        return bonus.setScale(2, RoundingMode.DOWN);
    }

    @Override
    public int insertYebaoOrder(SysYebaoOrder order)
    {
        return orderMapper.insertYebaoOrder(order);
    }

    @Override
    public int updateYebaoOrder(SysYebaoOrder order)
    {
        return orderMapper.updateYebaoOrder(order);
    }

    @Override
    public int deleteYebaoOrderById(Long orderId)
    {
        return orderMapper.deleteYebaoOrderById(orderId);
    }

    @Override
    public int deleteYebaoOrderByIds(Long[] orderIds)
    {
        return orderMapper.deleteYebaoOrderByIds(orderIds);
    }

    private static BigDecimal bd(Double value)
    {
        return BigDecimal.valueOf(value == null ? 0D : value);
    }

    private static double scale2(double value)
    {
        return BigDecimal.valueOf(value).setScale(2, RoundingMode.DOWN).doubleValue();
    }

    private static double nullSafe(Double value)
    {
        return value == null ? 0D : value;
    }

    private static String buildNo(String prefix)
    {
        return prefix + System.currentTimeMillis() + UUID.randomUUID().toString().replace("-", "").substring(0, 8);
    }
}
