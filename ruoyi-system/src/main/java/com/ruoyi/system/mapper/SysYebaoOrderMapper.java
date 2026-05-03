package com.ruoyi.system.mapper;

import java.util.Date;
import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysYebaoOrder;

public interface SysYebaoOrderMapper
{
    List<SysYebaoOrder> selectYebaoOrderList(SysYebaoOrder order);

    List<SysYebaoOrder> selectAppYebaoOrderList(@Param("userId") Long userId);

    List<SysYebaoOrder> selectDueYebaoOrderList(@Param("currentTime") Date currentTime);

    SysYebaoOrder selectYebaoOrderById(@Param("orderId") Long orderId);

    SysYebaoOrder selectYebaoOrderByIdForUpdate(@Param("orderId") Long orderId);

    int insertYebaoOrder(SysYebaoOrder order);

    int updateYebaoOrder(SysYebaoOrder order);

    int deleteYebaoOrderById(@Param("orderId") Long orderId);

    int deleteYebaoOrderByIds(Long[] orderIds);

    Double selectUserPrincipalTotal(@Param("userId") Long userId);

    Double selectUserSettledIncomeTotal(@Param("userId") Long userId);

    Double selectUserTodayIncomeTotal(@Param("userId") Long userId);

    Integer selectUserOrderCount(@Param("userId") Long userId);
}
