package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.common.core.domain.entity.SysUserGrowthLog;

/**
 * 用户成长值日志 Mapper
 */
public interface SysUserGrowthLogMapper
{
    public List<SysUserGrowthLog> selectGrowthLogList(SysUserGrowthLog growthLog);

    public int insertGrowthLog(SysUserGrowthLog growthLog);
}
