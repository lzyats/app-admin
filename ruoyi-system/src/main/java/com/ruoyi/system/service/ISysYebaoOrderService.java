package com.ruoyi.system.service;

import java.util.List;
import java.util.Map;
import com.ruoyi.system.domain.SysYebaoOrder;

public interface ISysYebaoOrderService
{
    List<SysYebaoOrder> selectYebaoOrderList(SysYebaoOrder order);

    List<SysYebaoOrder> selectAppYebaoOrderList(Long userId);

    List<com.ruoyi.system.domain.SysYebaoIncomeLog> selectAppYebaoIncomeLogList(Long userId);

    List<SysYebaoOrder> selectDueYebaoOrderList();

    SysYebaoOrder selectYebaoOrderById(Long orderId);

    Map<String, Object> selectAppYebaoDetail(Long userId);

    int purchase(Long userId, Integer shares, String remark);

    int redeem(Long userId, Long orderId);

    int settleDueIncome();

    int insertYebaoOrder(SysYebaoOrder order);

    int updateYebaoOrder(SysYebaoOrder order);

    int deleteYebaoOrderById(Long orderId);

    int deleteYebaoOrderByIds(Long[] orderIds);
}
