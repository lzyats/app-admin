package com.ruoyi.system.service;

import java.util.List;
import java.util.Map;

public interface ISysInvestOrderService
{
    List<Map<String, Object>> selectAdminOrderList(String orderNo, Long userId, String userName, String productName, String status);

    Map<String, Object> selectAdminOrderById(Long orderId);

    Map<String, Object> selectAdminOrderDetail(Long orderId);

    int redeemByAdmin(Long orderId, String confirmText, String operatorName);

    int settleByAdmin(Long orderId, String confirmText, String operatorName);

    int settleDuePlans();
}
