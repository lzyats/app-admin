package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.common.core.domain.entity.SysUserGrowthLog;

/**
 * 用户成长值日志服务
 */
public interface ISysUserGrowthLogService
{
    public List<SysUserGrowthLog> selectGrowthLogList(SysUserGrowthLog growthLog);

    public int insertGrowthLog(SysUserGrowthLog growthLog);
}
