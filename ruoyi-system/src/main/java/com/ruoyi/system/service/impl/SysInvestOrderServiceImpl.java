package com.ruoyi.system.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.entity.SysUserWallet;
import com.ruoyi.common.core.domain.entity.SysUserWalletLog;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysInvestProduct;
import com.ruoyi.system.domain.SysTeamLevel;
import com.ruoyi.system.domain.SysUserLevel;
import com.ruoyi.system.mapper.SysAppInvestOrderMapper;
import com.ruoyi.system.mapper.SysInvestProductMapper;
import com.ruoyi.system.mapper.SysTeamLevelMapper;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.mapper.SysUserLevelMapper;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysGrowthValueService;
import com.ruoyi.system.service.ISysInvestOrderService;
import com.ruoyi.system.service.ISysTeamStatService;
import com.ruoyi.system.service.ISysUserPointService;
import com.ruoyi.system.service.ISysUserWalletLogService;
import com.ruoyi.system.service.ISysUserWalletService;

@Service
public class SysInvestOrderServiceImpl implements ISysInvestOrderService
{
    private static final Logger log = LoggerFactory.getLogger(SysInvestOrderServiceImpl.class);
    private static final String REDEEM_CONFIRM_TEXT = "确认赎回";
    private static final String SETTLE_CONFIRM_TEXT = "确认结算";

    @Autowired
    private SysAppInvestOrderMapper appInvestOrderMapper;

    @Autowired
    private SysInvestProductMapper investProductMapper;

    @Autowired
    private ISysUserWalletService walletService;

    @Autowired
    private ISysUserWalletLogService walletLogService;

    @Autowired
    private ISysUserPointService userPointService;

    @Autowired
    private ISysGrowthValueService growthValueService;

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private SysUserLevelMapper userLevelMapper;

    @Autowired
    private SysTeamLevelMapper teamLevelMapper;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ISysTeamStatService teamStatService;

    @Autowired
    private PlatformTransactionManager transactionManager;

    @Override
    public List<Map<String, Object>> selectAdminOrderList(String orderNo, Long userId, String userName, String productName, String status)
    {
        return appInvestOrderMapper.selectAdminInvestOrderList(
            StringUtils.trim(orderNo),
            userId,
            StringUtils.trim(userName),
            StringUtils.trim(productName),
            StringUtils.trim(status));
    }

    @Override
    public Map<String, Object> selectAdminOrderById(Long orderId)
    {
        return appInvestOrderMapper.selectAdminInvestOrderById(orderId);
    }

    @Override
    public Map<String, Object> selectAdminOrderDetail(Long orderId)
    {
        Map<String, Object> order = appInvestOrderMapper.selectAdminInvestOrderById(orderId);
        if (order == null || order.isEmpty())
        {
            return null;
        }
        List<Map<String, Object>> plans = appInvestOrderMapper.selectOrderPlansByOrderId(orderId);
        BigDecimal pendingPrincipal = BigDecimal.ZERO;
        BigDecimal pendingInterest = BigDecimal.ZERO;
        BigDecimal settledPrincipal = BigDecimal.ZERO;
        BigDecimal settledInterest = BigDecimal.ZERO;
        for (Map<String, Object> plan : plans)
        {
            String planType = String.valueOf(plan.get("planType"));
            String status = String.valueOf(plan.get("status"));
            BigDecimal planAmount = parseDecimal(plan.get("planAmount"), BigDecimal.ZERO);
            boolean settled = "1".equals(status);
            if ("PRINCIPAL".equalsIgnoreCase(planType))
            {
                if (settled)
                {
                    settledPrincipal = settledPrincipal.add(planAmount);
                }
                else if ("0".equals(status))
                {
                    pendingPrincipal = pendingPrincipal.add(planAmount);
                }
            }
            else if ("INTEREST".equalsIgnoreCase(planType))
            {
                if (settled)
                {
                    settledInterest = settledInterest.add(planAmount);
                }
                else if ("0".equals(status))
                {
                    pendingInterest = pendingInterest.add(planAmount);
                }
            }
        }
        Map<String, Object> detail = new HashMap<String, Object>();
        detail.put("order", order);
        detail.put("plans", plans == null ? new ArrayList<Map<String, Object>>() : plans);
        detail.put("pendingPrincipal", pendingPrincipal.setScale(2, RoundingMode.DOWN));
        detail.put("pendingInterest", pendingInterest.setScale(2, RoundingMode.DOWN));
        detail.put("settledPrincipal", settledPrincipal.setScale(2, RoundingMode.DOWN));
        detail.put("settledInterest", settledInterest.setScale(2, RoundingMode.DOWN));
        return detail;
    }

    @Override
    public int redeemByAdmin(Long orderId, String confirmText, String operatorName)
    {
        if (orderId == null || orderId <= 0L)
        {
            throw new ServiceException("订单ID不能为空");
        }
        if (!REDEEM_CONFIRM_TEXT.equals(StringUtils.trim(confirmText)))
        {
            throw new ServiceException("请输入“确认赎回”后再提交");
        }
        TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager);
        return transactionTemplate.execute(status -> doRedeemByAdmin(orderId, operatorName));
    }

    @Override
    public int settleByAdmin(Long orderId, String confirmText, String operatorName)
    {
        if (orderId == null || orderId <= 0L)
        {
            throw new ServiceException("订单ID不能为空");
        }
        if (!SETTLE_CONFIRM_TEXT.equals(StringUtils.trim(confirmText)))
        {
            throw new ServiceException("请输入“确认结算”后再提交");
        }
        TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager);
        return transactionTemplate.execute(status -> doSettleByAdmin(orderId, operatorName));
    }

    @Override
    public int settleDuePlans()
    {
        List<Map<String, Object>> duePlans = appInvestOrderMapper.selectDuePlans(new Date());
        if (duePlans == null || duePlans.isEmpty())
        {
            return 0;
        }
        AtomicInteger settled = new AtomicInteger(0);
        TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager);
        for (Map<String, Object> plan : duePlans)
        {
            Long planId = parseLong(plan.get("planId"), 0L);
            if (planId == null || planId <= 0L)
            {
                continue;
            }
            try
            {
                Integer rows = transactionTemplate.execute(status -> settleOnePlan(planId));
                if (rows != null && rows > 0)
                {
                    settled.addAndGet(rows);
                }
            }
            catch (Exception ignored)
            {
            }
        }
        return settled.get();
    }

    @Override
    public int processExpiredGroups()
    {
        List<Map<String, Object>> groups = appInvestOrderMapper.selectExpiredGroups(new Date());
        if (groups == null || groups.isEmpty())
        {
            return 0;
        }
        AtomicInteger processed = new AtomicInteger(0);
        TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager);
        for (Map<String, Object> group : groups)
        {
            Long groupId = parseLong(group.get("groupId"), 0L);
            if (groupId == null || groupId <= 0L)
            {
                continue;
            }
            try
            {
                Integer rows = transactionTemplate.execute(status -> failExpiredGroup(groupId));
                if (rows != null && rows > 0)
                {
                    processed.addAndGet(rows);
                }
            }
            catch (Exception e)
            {
                log.warn("process expired invest group failed, groupId={}", groupId, e);
            }
        }
        return processed.get();
    }

    private int failExpiredGroup(Long groupId)
    {
        Map<String, Object> group = appInvestOrderMapper.selectInvestGroupByIdForUpdate(groupId);
        if (group == null || group.isEmpty())
        {
            return 0;
        }
        if (!"0".equals(String.valueOf(group.get("status"))))
        {
            return 0;
        }
        Date deadline = (Date) group.get("deadline_time");
        Date now = new Date();
        if (deadline != null && now.before(deadline))
        {
            return 0;
        }
        Integer memberCount = parseInt(group.get("member_count"), 0);
        Integer targetSize = parseInt(group.get("target_size"), 0);
        if (memberCount != null && targetSize != null && memberCount.intValue() >= targetSize.intValue() && targetSize.intValue() > 0)
        {
            appInvestOrderMapper.updateInvestGroupStatus(groupId, "1", "拼团超时前已成团");
            appInvestOrderMapper.updateInvestOrderGroupStatusByGroupId(groupId, "1", "拼团已成团");
            return 1;
        }

        List<Map<String, Object>> orderList = appInvestOrderMapper.selectRunningOrdersByGroupIdForUpdate(groupId);
        if (orderList != null)
        {
            for (Map<String, Object> order : orderList)
            {
                refundGroupFailedOrder(order);
            }
        }
        appInvestOrderMapper.updateInvestGroupStatus(groupId, "2", "拼团失败，系统自动退款");
        appInvestOrderMapper.updateInvestOrderGroupStatusByGroupId(groupId, "2", "拼团失败，系统自动退款");
        return 1;
    }

    private void refundGroupFailedOrder(Map<String, Object> order)
    {
        Long orderId = parseLong(order.get("order_id"), 0L);
        Long userId = parseLong(order.get("user_id"), 0L);
        Long productId = parseLong(order.get("product_id"), 0L);
        if (orderId == null || orderId <= 0L || userId == null || userId <= 0L)
        {
            return;
        }
        String status = String.valueOf(order.get("status"));
        if (!"0".equals(status))
        {
            return;
        }
        String currency = normalizeWalletCurrency(String.valueOf(order.get("currency")));
        BigDecimal amount = parseDecimal(order.get("invest_amount"), BigDecimal.ZERO).setScale(2, RoundingMode.DOWN);
        if (amount.compareTo(BigDecimal.ZERO) <= 0)
        {
            return;
        }
        Long investShares = parseLong(order.get("invest_shares"), 0L);
        if (investShares == null || investShares < 0L)
        {
            investShares = 0L;
        }

        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(userId, currency);
        if (wallet == null)
        {
            throw new ServiceException(currency + "钱包不存在");
        }
        BigDecimal balanceBefore = parseDecimal(wallet.getAvailableBalance(), BigDecimal.ZERO);
        BigDecimal balanceAfter = balanceBefore.add(amount).setScale(2, RoundingMode.DOWN);
        BigDecimal totalInvestBefore = parseDecimal(wallet.getTotalInvest(), BigDecimal.ZERO);
        BigDecimal totalInvestAfter = totalInvestBefore.subtract(amount).setScale(2, RoundingMode.DOWN);
        if (totalInvestAfter.compareTo(BigDecimal.ZERO) < 0)
        {
            totalInvestAfter = BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        wallet.setAvailableBalance(balanceAfter.doubleValue());
        wallet.setTotalInvest(totalInvestAfter.doubleValue());
        wallet.setUpdateTime(new Date());
        walletService.updateWallet(wallet);

        appInvestOrderMapper.cancelPendingPlansByOrderId(orderId, "拼团失败取消收益计划");
        appInvestOrderMapper.updateInvestOrderStatus(orderId, "2", "system", "拼团失败自动退款");
        teamStatService.revokeInvestOrderEvent(orderId);
        if (productId != null && productId > 0L)
        {
            investProductMapper.decreaseSoldShares(productId, investShares, amount);
        }
        BigDecimal investDeltaCny = toCnyAmount(currency, amount).negate();
        userMapper.addUserTotalAmounts(userId, investDeltaCny, BigDecimal.ZERO);
        insertWalletLog(
            userId,
            wallet.getWalletId(),
            currency,
            amount,
            "invest_group_refund",
            balanceBefore,
            balanceAfter,
            String.valueOf(order.get("order_no")),
            "system",
            "拼团失败退款"
        );
    }

    private int doRedeemByAdmin(Long orderId, String operatorName)
    {
        Map<String, Object> order = appInvestOrderMapper.selectInvestOrderByIdForUpdate(orderId);
        if (order == null || order.isEmpty())
        {
            throw new ServiceException("投资订单不存在");
        }
        String status = String.valueOf(order.get("status"));
        if (!"0".equals(status))
        {
            throw new ServiceException("仅持有中的订单支持赎回");
        }

        Long userId = parseLong(order.get("user_id"), 0L);
        String currency = normalizeWalletCurrency(String.valueOf(order.get("currency")));
        BigDecimal principal = parseDecimal(order.get("invest_amount"), BigDecimal.ZERO).setScale(2, RoundingMode.DOWN);
        if (principal.compareTo(BigDecimal.ZERO) <= 0)
        {
            throw new ServiceException("订单本金异常，无法赎回");
        }

        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(userId, currency);
        if (wallet == null)
        {
            throw new ServiceException(currency + "钱包不存在");
        }

        BigDecimal balanceBefore = parseDecimal(wallet.getAvailableBalance(), BigDecimal.ZERO);
        BigDecimal balanceAfter = balanceBefore.add(principal).setScale(2, RoundingMode.DOWN);
        BigDecimal totalInvestBefore = parseDecimal(wallet.getTotalInvest(), BigDecimal.ZERO);
        BigDecimal totalInvestAfter = totalInvestBefore.subtract(principal).setScale(2, RoundingMode.DOWN);
        if (totalInvestAfter.compareTo(BigDecimal.ZERO) < 0)
        {
            totalInvestAfter = BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        wallet.setAvailableBalance(balanceAfter.doubleValue());
        wallet.setTotalInvest(totalInvestAfter.doubleValue());
        wallet.setUpdateTime(new Date());
        walletService.updateWallet(wallet);

        appInvestOrderMapper.cancelPendingPlansByOrderId(orderId, "后台赎回取消未执行收益计划");
        appInvestOrderMapper.updateInvestOrderStatus(orderId, "2", operatorName, "后台赎回，仅退还本金");
        teamStatService.revokeInvestOrderEvent(orderId);

        SysUserWalletLog log = new SysUserWalletLog();
        log.setUserId(userId);
        log.setWalletId(wallet.getWalletId());
        log.setCurrencyType(currency);
        log.setAmount(principal.doubleValue());
        log.setType("redeem");
        log.setStatus("success");
        log.setBalanceBefore(balanceBefore.doubleValue());
        log.setBalanceAfter(balanceAfter.doubleValue());
        log.setOrderNo(String.valueOf(order.get("order_no")));
        log.setOperatorName(StringUtils.defaultIfBlank(operatorName, "system"));
        log.setRemark("后台赎回，仅退还本金");
        log.setCreateTime(new Date());
        walletLogService.insertLog(log);

        // 赎回后回退用户累计投资（按币种折算为CNY口径）
        BigDecimal investDeltaCny = toCnyAmount(currency, principal).negate();
        userMapper.addUserTotalAmounts(userId, investDeltaCny, BigDecimal.ZERO);

        return 1;
    }

    private int settleOnePlan(Long planId)
    {
        Map<String, Object> plan = appInvestOrderMapper.selectPlanByIdForUpdate(planId);
        if (plan == null || plan.isEmpty())
        {
            return 0;
        }
        if (!"0".equals(String.valueOf(plan.get("status"))))
        {
            return 0;
        }
        Date now = new Date();
        Date planTime = (Date) plan.get("plan_time");
        if (planTime != null && now.before(planTime))
        {
            return 0;
        }
        Long orderId = parseLong(plan.get("order_id"), 0L);
        Map<String, Object> order = appInvestOrderMapper.selectInvestOrderByIdForUpdate(orderId);
        if (order == null || order.isEmpty() || !"0".equals(String.valueOf(order.get("status"))))
        {
            appInvestOrderMapper.updatePlanStatus(planId, "2", now, "订单非持有中，计划取消");
            return 0;
        }

        Long userId = parseLong(order.get("user_id"), 0L);
        String currency = normalizeWalletCurrency(String.valueOf(order.get("currency")));
        String planType = String.valueOf(plan.get("plan_type"));
        BigDecimal planAmount = parseDecimal(plan.get("plan_amount"), BigDecimal.ZERO).setScale(2, RoundingMode.DOWN);
        if (planAmount.compareTo(BigDecimal.ZERO) <= 0)
        {
            appInvestOrderMapper.updatePlanStatus(planId, "1", now, "计划金额为0，自动跳过");
            return 1;
        }

        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(userId, currency);
        if (wallet == null)
        {
            throw new ServiceException(currency + "钱包不存在");
        }

        BigDecimal balanceBefore = parseDecimal(wallet.getAvailableBalance(), BigDecimal.ZERO);
        BigDecimal balanceAfter = balanceBefore.add(planAmount).setScale(2, RoundingMode.DOWN);
        wallet.setAvailableBalance(balanceAfter.doubleValue());

        if ("INTEREST".equalsIgnoreCase(planType))
        {
            BigDecimal profitAfter = parseDecimal(wallet.getProfitAmount(), BigDecimal.ZERO).add(planAmount).setScale(2, RoundingMode.DOWN);
            wallet.setProfitAmount(profitAfter.doubleValue());
        }
        else if ("PRINCIPAL".equalsIgnoreCase(planType))
        {
            BigDecimal totalInvestAfter = parseDecimal(wallet.getTotalInvest(), BigDecimal.ZERO).subtract(planAmount).setScale(2, RoundingMode.DOWN);
            if (totalInvestAfter.compareTo(BigDecimal.ZERO) < 0)
            {
                totalInvestAfter = BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
            }
            wallet.setTotalInvest(totalInvestAfter.doubleValue());
        }
        wallet.setUpdateTime(now);
        walletService.updateWallet(wallet);

        appInvestOrderMapper.updatePlanStatus(planId, "1", now, "定时结算执行");
        int pendingCount = appInvestOrderMapper.countPendingPlanByOrderId(orderId);
        if (pendingCount <= 0)
        {
            appInvestOrderMapper.updateInvestOrderStatus(orderId, "1", "system", "订单收益计划已全部结清");
            grantCompletionReward(order);
        }

        SysUserWalletLog log = new SysUserWalletLog();
        log.setUserId(userId);
        log.setWalletId(wallet.getWalletId());
        log.setCurrencyType(currency);
        log.setAmount(planAmount.doubleValue());
        log.setType("INTEREST".equalsIgnoreCase(planType) ? "profit" : "redeem");
        log.setStatus("success");
        log.setBalanceBefore(balanceBefore.doubleValue());
        log.setBalanceAfter(balanceAfter.doubleValue());
        log.setOrderNo(String.valueOf(order.get("order_no")));
        log.setOperatorName("system");
        log.setRemark("INTEREST".equalsIgnoreCase(planType) ? "投资收益结算入账" : "投资本金返还入账");
        log.setCreateTime(now);
        walletLogService.insertLog(log);
        return 1;
    }

    private int doSettleByAdmin(Long orderId, String operatorName)
    {
        Map<String, Object> order = appInvestOrderMapper.selectInvestOrderByIdForUpdate(orderId);
        if (order == null || order.isEmpty())
        {
            throw new ServiceException("投资订单不存在");
        }
        String orderStatus = String.valueOf(order.get("status"));
        if (!"0".equals(orderStatus))
        {
            throw new ServiceException("仅持有中的订单支持结算");
        }

        Long userId = parseLong(order.get("user_id"), 0L);
        if (userId == null || userId <= 0L)
        {
            throw new ServiceException("订单用户信息异常");
        }
        String currency = normalizeWalletCurrency(String.valueOf(order.get("currency")));
        String orderNo = String.valueOf(order.get("order_no"));
        BigDecimal orderPrincipal = parseDecimal(order.get("invest_amount"), BigDecimal.ZERO).setScale(2, RoundingMode.DOWN);
        if (orderPrincipal.compareTo(BigDecimal.ZERO) <= 0)
        {
            throw new ServiceException("订单本金异常，无法结算");
        }

        List<Map<String, Object>> pendingPlans = appInvestOrderMapper.selectPendingPlansByOrderId(orderId);
        BigDecimal pendingPrincipal = BigDecimal.ZERO;
        BigDecimal pendingInterest = BigDecimal.ZERO;
        Date now = new Date();
        for (Map<String, Object> plan : pendingPlans)
        {
            String planType = String.valueOf(plan.get("plan_type"));
            BigDecimal planAmount = parseDecimal(plan.get("plan_amount"), BigDecimal.ZERO).setScale(2, RoundingMode.DOWN);
            if (planAmount.compareTo(BigDecimal.ZERO) <= 0)
            {
                continue;
            }
            if ("PRINCIPAL".equalsIgnoreCase(planType))
            {
                pendingPrincipal = pendingPrincipal.add(planAmount);
            }
            else if ("INTEREST".equalsIgnoreCase(planType))
            {
                pendingInterest = pendingInterest.add(planAmount);
            }
        }

        SysUserWallet userWallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(userId, currency);
        if (userWallet == null)
        {
            throw new ServiceException(currency + "钱包不存在");
        }
        BigDecimal balanceBefore = parseDecimal(userWallet.getAvailableBalance(), BigDecimal.ZERO);
        BigDecimal profitBefore = parseDecimal(userWallet.getProfitAmount(), BigDecimal.ZERO);
        BigDecimal totalInvestBefore = parseDecimal(userWallet.getTotalInvest(), BigDecimal.ZERO);

        BigDecimal creditPrincipal = pendingPrincipal.compareTo(BigDecimal.ZERO) > 0 ? pendingPrincipal : BigDecimal.ZERO;
        BigDecimal creditInterest = pendingInterest.compareTo(BigDecimal.ZERO) > 0 ? pendingInterest : BigDecimal.ZERO;
        BigDecimal creditRedPacket = computeProductRedPacket(order);
        BigDecimal creditLevelBonus = computeLevelBonus(orderPrincipal, userId);
        BigDecimal creditTeamBonus = creditTeamBonusToDirectParent(orderPrincipal, userId, currency, orderNo, operatorName);

        BigDecimal totalCredit = creditPrincipal.add(creditInterest).add(creditRedPacket).add(creditLevelBonus);
        BigDecimal balanceAfter = balanceBefore.add(totalCredit).setScale(2, RoundingMode.DOWN);
        BigDecimal profitAfter = profitBefore.add(creditInterest).add(creditRedPacket).add(creditLevelBonus).setScale(2, RoundingMode.DOWN);

        BigDecimal totalInvestAfter = totalInvestBefore.subtract(creditPrincipal).setScale(2, RoundingMode.DOWN);
        if (totalInvestAfter.compareTo(BigDecimal.ZERO) < 0)
        {
            totalInvestAfter = BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        userWallet.setAvailableBalance(balanceAfter.doubleValue());
        userWallet.setProfitAmount(profitAfter.doubleValue());
        userWallet.setTotalInvest(totalInvestAfter.doubleValue());
        userWallet.setUpdateTime(now);
        walletService.updateWallet(userWallet);

        if (pendingPlans != null && !pendingPlans.isEmpty())
        {
            for (Map<String, Object> plan : pendingPlans)
            {
                Long planId = parseLong(plan.get("plan_id"), 0L);
                if (planId != null && planId > 0L)
                {
                    appInvestOrderMapper.updatePlanStatus(planId, "1", now, "后台强制结算执行");
                }
            }
        }
        appInvestOrderMapper.updateInvestOrderStatus(orderId, "1", operatorName, "后台强制结算完成");
        grantCompletionReward(order);

        if (creditPrincipal.compareTo(BigDecimal.ZERO) > 0)
        {
            insertWalletLog(userId, userWallet.getWalletId(), currency, creditPrincipal, "redeem",
                balanceBefore, balanceBefore.add(creditPrincipal), orderNo,
                operatorName, "后台强制结算返还未结算本金");
            balanceBefore = balanceBefore.add(creditPrincipal).setScale(2, RoundingMode.DOWN);
        }
        if (creditInterest.compareTo(BigDecimal.ZERO) > 0)
        {
            insertWalletLog(userId, userWallet.getWalletId(), currency, creditInterest, "profit",
                balanceBefore, balanceBefore.add(creditInterest), orderNo,
                operatorName, "后台强制结算发放未结算收益");
            balanceBefore = balanceBefore.add(creditInterest).setScale(2, RoundingMode.DOWN);
        }
        if (creditRedPacket.compareTo(BigDecimal.ZERO) > 0)
        {
            insertWalletLog(userId, userWallet.getWalletId(), currency, creditRedPacket, "invest_red_packet",
                balanceBefore, balanceBefore.add(creditRedPacket), orderNo,
                operatorName, "后台强制结算发放产品红包");
            balanceBefore = balanceBefore.add(creditRedPacket).setScale(2, RoundingMode.DOWN);
        }
        if (creditLevelBonus.compareTo(BigDecimal.ZERO) > 0)
        {
            insertWalletLog(userId, userWallet.getWalletId(), currency, creditLevelBonus, "invest_level_bonus",
                balanceBefore, balanceBefore.add(creditLevelBonus), orderNo,
                operatorName, "后台强制结算发放等级加成");
        }

        log.info("invest order force settle success, orderId={}, orderNo={}, principal={}, interest={}, redPacket={}, levelBonus={}, teamBonus={}, operator={}",
            orderId, orderNo, creditPrincipal, creditInterest, creditRedPacket, creditLevelBonus, creditTeamBonus, operatorName);
        return 1;
    }

    private void grantCompletionReward(Map<String, Object> order)
    {
        Long orderId = parseLong(order.get("order_id"), 0L);
        Long productId = parseLong(order.get("product_id"), 0L);
        Long userId = parseLong(order.get("user_id"), 0L);
        if (orderId == null || orderId <= 0 || productId == null || productId <= 0 || userId == null || userId <= 0)
        {
            return;
        }
        SysInvestProduct product = investProductMapper.selectInvestProductById(productId);
        if (product == null)
        {
            return;
        }
        BigDecimal units = calcRewardUnits(parseDecimal(order.get("invest_amount"), BigDecimal.ZERO), product);
        if (units.compareTo(BigDecimal.ZERO) <= 0)
        {
            return;
        }
        String userName = String.valueOf(order.get("user_name"));
        String orderNo = String.valueOf(order.get("order_no"));

        BigDecimal pointPerUnit = parseDecimal(product.getPointPerUnit(), BigDecimal.ZERO);
        long points = units.multiply(pointPerUnit).setScale(0, RoundingMode.DOWN).longValue();
        if (points > 0L)
        {
            userPointService.grantInvestPoints(userId, userName, points, orderId, orderNo, "投资订单到期结算发放积分");
        }

        BigDecimal growthPerUnit = parseDecimal(product.getGrowthPerUnit(), BigDecimal.ZERO);
        long growth = units.multiply(growthPerUnit).setScale(0, RoundingMode.DOWN).longValue();
        if (growth > 0L)
        {
            growthValueService.increaseGrowthValue(userId, growth, "invest_settlement", orderId, orderNo, "投资订单到期结算发放成长值");
        }
    }

    private BigDecimal computeProductRedPacket(Map<String, Object> order)
    {
        Long productId = parseLong(order.get("product_id"), 0L);
        if (productId == null || productId <= 0L)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        SysInvestProduct product = investProductMapper.selectInvestProductById(productId);
        if (product == null)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        BigDecimal units = calcRewardUnits(parseDecimal(order.get("invest_amount"), BigDecimal.ZERO), product);
        BigDecimal redPacketPerUnit = parseDecimal(product.getRedPacketPerUnit(), BigDecimal.ZERO);
        if (units.compareTo(BigDecimal.ZERO) <= 0 || redPacketPerUnit.compareTo(BigDecimal.ZERO) <= 0)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        return units.multiply(redPacketPerUnit).setScale(2, RoundingMode.DOWN);
    }

    private BigDecimal computeLevelBonus(BigDecimal orderPrincipal, Long userId)
    {
        if (orderPrincipal == null || orderPrincipal.compareTo(BigDecimal.ZERO) <= 0 || userId == null || userId <= 0L)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        BigDecimal bonusPercent = resolveUserInvestBonusPercent(userId);
        if (bonusPercent.compareTo(BigDecimal.ZERO) <= 0)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        return orderPrincipal.multiply(bonusPercent).divide(new BigDecimal("100"), 2, RoundingMode.DOWN);
    }

    private BigDecimal creditTeamBonusToDirectParent(BigDecimal orderPrincipal, Long userId, String currency, String orderNo, String operatorName)
    {
        if (orderPrincipal == null || orderPrincipal.compareTo(BigDecimal.ZERO) <= 0 || userId == null || userId <= 0L)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        SysUser user = userMapper.selectUserBaseByIdForUpdate(userId);
        if (user == null)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        Long parentUserId = parseDirectParentUserId(user.getLevelDetail());
        if (parentUserId == null || parentUserId <= 0L)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        BigDecimal teamBonusRate = resolveTeamLeaderBonusRate(parentUserId);
        if (teamBonusRate.compareTo(BigDecimal.ZERO) <= 0)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        BigDecimal teamBonusAmount = orderPrincipal.multiply(teamBonusRate)
            .divide(new BigDecimal("100"), 2, RoundingMode.DOWN);
        if (teamBonusAmount.compareTo(BigDecimal.ZERO) <= 0)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        SysUserWallet parentWallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(parentUserId, currency);
        if (parentWallet == null)
        {
            throw new ServiceException("上级用户" + parentUserId + "的" + currency + "钱包不存在");
        }
        BigDecimal parentBalanceBefore = parseDecimal(parentWallet.getAvailableBalance(), BigDecimal.ZERO);
        BigDecimal parentProfitBefore = parseDecimal(parentWallet.getProfitAmount(), BigDecimal.ZERO);
        BigDecimal parentBalanceAfter = parentBalanceBefore.add(teamBonusAmount).setScale(2, RoundingMode.DOWN);
        BigDecimal parentProfitAfter = parentProfitBefore.add(teamBonusAmount).setScale(2, RoundingMode.DOWN);
        parentWallet.setAvailableBalance(parentBalanceAfter.doubleValue());
        parentWallet.setProfitAmount(parentProfitAfter.doubleValue());
        parentWallet.setUpdateTime(new Date());
        walletService.updateWallet(parentWallet);

        insertWalletLog(parentUserId, parentWallet.getWalletId(), currency, teamBonusAmount, "invest_team_bonus",
            parentBalanceBefore, parentBalanceAfter, orderNo, operatorName,
            "下级订单强制结算发放团队加成");
        return teamBonusAmount;
    }

    private BigDecimal resolveUserInvestBonusPercent(Long userId)
    {
        if (userId == null || userId <= 0)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        SysUser user = userMapper.selectUserBaseById(userId);
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

    private BigDecimal resolveTeamLeaderBonusRate(Long userId)
    {
        if (userId == null || userId <= 0L)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        SysUser parent = userMapper.selectUserBaseById(userId);
        if (parent == null || parent.getTeamLeaderLevel() == null || parent.getTeamLeaderLevel() <= 0)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        SysTeamLevel query = new SysTeamLevel();
        query.setTeamLevel(parent.getTeamLeaderLevel());
        query.setStatus("0");
        List<SysTeamLevel> list = teamLevelMapper.selectTeamLevelList(query);
        if (list == null || list.isEmpty())
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        BigDecimal rate = parseDecimal(list.get(0).getTeamBonusRate(), BigDecimal.ZERO);
        if (rate.compareTo(BigDecimal.ZERO) <= 0)
        {
            return BigDecimal.ZERO.setScale(2, RoundingMode.DOWN);
        }
        return rate.setScale(2, RoundingMode.DOWN);
    }

    private Long parseDirectParentUserId(String levelDetail)
    {
        if (StringUtils.isBlank(levelDetail))
        {
            return 0L;
        }
        String[] segments = StringUtils.split(levelDetail, ',');
        if (segments == null || segments.length == 0)
        {
            return 0L;
        }
        String last = StringUtils.trim(segments[segments.length - 1]);
        Long userId = parseLong(last, 0L);
        return userId == null ? 0L : userId;
    }

    private void insertWalletLog(Long userId, Long walletId, String currency, BigDecimal amount, String type,
        BigDecimal balanceBefore, BigDecimal balanceAfter, String orderNo, String operatorName, String remark)
    {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0)
        {
            return;
        }
        SysUserWalletLog log = new SysUserWalletLog();
        log.setUserId(userId);
        log.setWalletId(walletId);
        log.setCurrencyType(currency);
        log.setAmount(amount.setScale(2, RoundingMode.DOWN).doubleValue());
        log.setType(type);
        log.setStatus("success");
        log.setBalanceBefore(parseDecimal(balanceBefore, BigDecimal.ZERO).setScale(2, RoundingMode.DOWN).doubleValue());
        log.setBalanceAfter(parseDecimal(balanceAfter, BigDecimal.ZERO).setScale(2, RoundingMode.DOWN).doubleValue());
        log.setOrderNo(orderNo);
        log.setOperatorName(StringUtils.defaultIfBlank(operatorName, "system"));
        log.setRemark(remark);
        log.setCreateTime(new Date());
        walletLogService.insertLog(log);
    }

    private BigDecimal calcRewardUnits(BigDecimal investAmount, SysInvestProduct product)
    {
        if (investAmount == null || investAmount.compareTo(BigDecimal.ZERO) <= 0 || product == null)
        {
            return BigDecimal.ZERO;
        }
        String mode = StringUtils.upperCase(StringUtils.defaultIfBlank(product.getInvestMode(), "SHARE"));
        BigDecimal minAmount = parseDecimal(product.getMinInvestAmount(), BigDecimal.ZERO);
        if ("AMOUNT".equals(mode))
        {
            BigDecimal maxAmount = parseDecimal(product.getMaxInvestAmount(), BigDecimal.ZERO);
            BigDecimal totalAmount = parseDecimal(product.getTotalAmount(), BigDecimal.ZERO);
            if (minAmount.compareTo(BigDecimal.ZERO) <= 0 || maxAmount.compareTo(BigDecimal.ZERO) <= 0 || totalAmount.compareTo(BigDecimal.ZERO) <= 0)
            {
                return BigDecimal.ONE;
            }
            BigDecimal multiple = maxAmount.divide(minAmount, 0, RoundingMode.DOWN);
            if (multiple.compareTo(BigDecimal.ONE) < 0)
            {
                multiple = BigDecimal.ONE;
            }
            BigDecimal unitAmount = totalAmount.divide(multiple, 8, RoundingMode.DOWN);
            if (unitAmount.compareTo(BigDecimal.ZERO) <= 0)
            {
                return BigDecimal.ONE;
            }
            BigDecimal units = investAmount.divide(unitAmount, 0, RoundingMode.DOWN);
            return units.compareTo(BigDecimal.ONE) < 0 ? BigDecimal.ONE : units;
        }
        if (minAmount.compareTo(BigDecimal.ZERO) <= 0)
        {
            return BigDecimal.ONE;
        }
        BigDecimal units = investAmount.divide(minAmount, 0, RoundingMode.DOWN);
        return units.compareTo(BigDecimal.ONE) < 0 ? BigDecimal.ONE : units;
    }

    private String normalizeWalletCurrency(String currency)
    {
        String c = StringUtils.upperCase(StringUtils.defaultIfBlank(currency, "CNY"));
        if ("USDT".equals(c))
        {
            return "USD";
        }
        return "USD".equals(c) ? "USD" : "CNY";
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
        if (value instanceof Number)
        {
            return BigDecimal.valueOf(((Number) value).doubleValue());
        }
        try
        {
            return new BigDecimal(String.valueOf(value).trim());
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
            return Long.parseLong(String.valueOf(value).trim());
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
            return Integer.parseInt(String.valueOf(value).trim());
        }
        catch (Exception e)
        {
            return defaultValue;
        }
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
}
