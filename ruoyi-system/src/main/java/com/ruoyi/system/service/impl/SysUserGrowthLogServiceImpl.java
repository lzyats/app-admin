package com.ruoyi.system.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.core.domain.entity.SysUserGrowthLog;
import com.ruoyi.system.mapper.SysUserGrowthLogMapper;
import com.ruoyi.system.service.ISysUserGrowthLogService;

/**
 * 用户成长值日志服务实现
 */
@Service
public class SysUserGrowthLogServiceImpl implements ISysUserGrowthLogService
{
    @Autowired
    private SysUserGrowthLogMapper growthLogMapper;

    @Override
    public List<SysUserGrowthLog> selectGrowthLogList(SysUserGrowthLog growthLog)
    {
        return growthLogMapper.selectGrowthLogList(growthLog);
    }

    @Override
    public int insertGrowthLog(SysUserGrowthLog growthLog)
    {
        return growthLogMapper.insertGrowthLog(growthLog);
    }
}
