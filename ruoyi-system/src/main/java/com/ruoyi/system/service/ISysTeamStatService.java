package com.ruoyi.system.service;

import java.util.Date;
import java.util.List;
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
     * 获取统计层级配置
     *
     * @return 统计层级
     */
    Integer getCalcDepth();
}
