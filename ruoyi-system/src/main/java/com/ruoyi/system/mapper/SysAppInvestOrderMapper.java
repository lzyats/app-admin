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
        @Param("expectedIncome") java.math.BigDecimal expectedIncome,
        @Param("contractNo") String contractNo,
        @Param("createBy") String createBy,
        @Param("remark") String remark
    );

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
