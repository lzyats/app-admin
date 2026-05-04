package com.ruoyi.system.service;

import java.util.Date;
import java.util.List;
import java.math.BigDecimal;
import com.ruoyi.system.domain.SysTeamStatEvent;
import com.ruoyi.system.domain.SysTeamStatUser;

public interface ISysTeamStatService
{
    /**
     * 夜间重算团队统计（按天幂等覆盖）
     *
     * @param statDate 统计日期
     */
    void rebuildDailyStats(Date statDate);

    /**
     * 查询团队汇总
     *
     * @param query 查询条件
     * @return 汇总列表
     */
    List<SysTeamStatUser> selectTeamStatUserList(SysTeamStatUser query);

    /**
     * 查询事件流水
     *
     * @param query 查询条件
     * @return 事件列表
     */
    List<SysTeamStatEvent> selectTeamStatEventList(SysTeamStatEvent query);

    /**
     * 投资订单成功后写入团队统计事件（用于当日增量与夜间重算口径对齐）
     *
     * @param memberUserId 投资用户ID
     * @param orderId 投资订单ID
     * @param investAmount 投资本金
     * @param eventTime 事件时间
     */
    void recordInvestOrderEvent(Long memberUserId, Long orderId, BigDecimal investAmount, Date eventTime);

    /**
     * 后台赎回后撤销投资订单团队事件
     *
     * @param orderId 投资订单ID
     */
    void revokeInvestOrderEvent(Long orderId);

    /**
     * 获取统计层级配置
     *
     * @return 统计层级
     */
    Integer getCalcDepth();
}
