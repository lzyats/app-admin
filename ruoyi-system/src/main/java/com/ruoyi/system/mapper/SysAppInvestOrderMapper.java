package com.ruoyi.system.mapper;

import java.util.Date;
import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface SysAppInvestOrderMapper
{
    int insertInvestOrder(
        @Param("orderNo") String orderNo,
        @Param("clientReqNo") String clientReqNo,
        @Param("userId") Long userId,
        @Param("userName") String userName,
        @Param("productId") Long productId,
        @Param("productName") String productName,
        @Param("currency") String currency,
        @Param("groupMode") String groupMode,
        @Param("investAmount") java.math.BigDecimal investAmount,
        @Param("singleRate") java.math.BigDecimal singleRate,
        @Param("groupRate") java.math.BigDecimal groupRate,
        @Param("effectiveRate") java.math.BigDecimal effectiveRate,
        @Param("cycleDays") Integer cycleDays,
        @Param("investShares") Long investShares,
        @Param("expectedIncome") java.math.BigDecimal expectedIncome,
        @Param("userLevelSnapshot") Integer userLevelSnapshot,
        @Param("couponId") Long couponId,
        @Param("userCouponId") Long userCouponId,
        @Param("couponName") String couponName,
        @Param("couponType") String couponType,
        @Param("couponDiscountAmount") java.math.BigDecimal couponDiscountAmount,
        @Param("payAmount") java.math.BigDecimal payAmount,
        @Param("contractNo") String contractNo,
        @Param("groupId") Long groupId,
        @Param("groupNo") String groupNo,
        @Param("groupStatus") String groupStatus,
        @Param("groupDeadlineTime") Date groupDeadlineTime,
        @Param("createBy") String createBy,
        @Param("remark") String remark
    );

    int insertInvestGroup(
        @Param("groupNo") String groupNo,
        @Param("productId") Long productId,
        @Param("productName") String productName,
        @Param("currency") String currency,
        @Param("initiatorUserId") Long initiatorUserId,
        @Param("targetSize") Integer targetSize,
        @Param("deadlineTime") Date deadlineTime,
        @Param("createBy") String createBy,
        @Param("remark") String remark
    );

    Long selectInvestGroupIdByNo(@Param("groupNo") String groupNo);

    Map<String, Object> selectInvestGroupByNoForUpdate(@Param("groupNo") String groupNo);

    Map<String, Object> selectInvestGroupByIdForUpdate(@Param("groupId") Long groupId);

    Map<String, Object> selectAutoJoinableGroupForUpdate(
        @Param("productId") Long productId,
        @Param("excludeUserId") Long excludeUserId,
        @Param("now") Date now
    );

    int updateInvestGroupAddMember(
        @Param("groupId") Long groupId,
        @Param("amountDelta") java.math.BigDecimal amountDelta,
        @Param("targetSize") Integer targetSize
    );

    int updateInvestGroupStatus(
        @Param("groupId") Long groupId,
        @Param("status") String status,
        @Param("remark") String remark
    );

    int updateInvestOrderGroupStatusByGroupId(
        @Param("groupId") Long groupId,
        @Param("groupStatus") String groupStatus,
        @Param("remark") String remark
    );

    List<Map<String, Object>> selectExpiredGroups(@Param("now") Date now);

    List<Map<String, Object>> selectRunningOrdersByGroupIdForUpdate(@Param("groupId") Long groupId);

    int insertContractSign(
        @Param("contractNo") String contractNo,
        @Param("orderNo") String orderNo,
        @Param("userId") Long userId,
        @Param("productId") Long productId,
        @Param("contractText") String contractText,
        @Param("signatureData") String signatureData,
        @Param("agreed") String agreed,
        @Param("signTime") Date signTime,
        @Param("createBy") String createBy
    );

    int insertOrderPlan(
        @Param("orderId") Long orderId,
        @Param("productId") Long productId,
        @Param("userId") Long userId,
        @Param("planType") String planType,
        @Param("stageNo") Integer stageNo,
        @Param("planTime") Date planTime,
        @Param("planRate") java.math.BigDecimal planRate,
        @Param("planAmount") java.math.BigDecimal planAmount,
        @Param("remark") String remark
    );

    Long selectInvestOrderIdByOrderNo(@Param("orderNo") String orderNo);

    int countUserInvestOrderByProduct(@Param("userId") Long userId, @Param("productId") Long productId);

    java.util.Map<String, Object> selectOrderByUserAndClientReqNo(
        @Param("userId") Long userId,
        @Param("clientReqNo") String clientReqNo
    );

    java.util.Map<String, Object> selectLatestValidContractSign(
        @Param("userId") Long userId,
        @Param("productId") Long productId
    );

    List<Map<String, Object>> selectAppInvestOrderList(
        @Param("userId") Long userId,
        @Param("tab") String tab
    );

    Map<String, Object> selectAppInvestOrderStat(@Param("userId") Long userId);

    List<Map<String, Object>> selectAppInvestIncomeLogs(@Param("userId") Long userId);

    Map<String, Object> selectAppInvestIncomeSummary(@Param("userId") Long userId);

    List<Map<String, Object>> selectAppInvestIncomeSummaryByCurrency(@Param("userId") Long userId);

    List<Map<String, Object>> selectAdminInvestOrderList(
        @Param("orderNo") String orderNo,
        @Param("userId") Long userId,
        @Param("userName") String userName,
        @Param("productName") String productName,
        @Param("status") String status
    );

    Map<String, Object> selectAdminInvestOrderById(@Param("orderId") Long orderId);

    List<Map<String, Object>> selectOrderPlansByOrderId(@Param("orderId") Long orderId);

    Map<String, Object> selectInvestOrderById(@Param("orderId") Long orderId);

    Map<String, Object> selectInvestOrderByIdForUpdate(@Param("orderId") Long orderId);

    List<Map<String, Object>> selectPendingPlansByOrderId(@Param("orderId") Long orderId);

    int cancelPendingPlansByOrderId(@Param("orderId") Long orderId, @Param("remark") String remark);

    int updateInvestOrderStatus(
        @Param("orderId") Long orderId,
        @Param("status") String status,
        @Param("updateBy") String updateBy,
        @Param("remark") String remark
    );

    int updatePlanStatus(
        @Param("planId") Long planId,
        @Param("status") String status,
        @Param("execTime") Date execTime,
        @Param("remark") String remark
    );

    int countPendingPlanByOrderId(@Param("orderId") Long orderId);

    List<Map<String, Object>> selectDuePlans(@Param("now") Date now);

    Map<String, Object> selectPlanByIdForUpdate(@Param("planId") Long planId);
}
