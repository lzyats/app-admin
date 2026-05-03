package com.ruoyi.system.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.core.domain.entity.SysUserPointLog;
import com.ruoyi.system.mapper.SysUserPointLogMapper;
import com.ruoyi.system.service.ISysUserPointLogService;

/**
 * 用户积分账变服务实现
 */
@Service
public class SysUserPointLogServiceImpl implements ISysUserPointLogService {
    @Autowired
    private SysUserPointLogMapper pointLogMapper;

    @Override
    public List<SysUserPointLog> selectPointLogByUserId(Long userId) {
        return pointLogMapper.selectPointLogByUserId(userId);
    }

    @Override
    public List<SysUserPointLog> selectPointLogByPointAccountId(Long pointAccountId) {
        return pointLogMapper.selectPointLogByPointAccountId(pointAccountId);
    }

    @Override
    public SysUserPointLog selectPointLogById(Long logId) {
        return pointLogMapper.selectPointLogById(logId);
    }

    @Override
    public List<SysUserPointLog> selectPointLogList(SysUserPointLog pointLog) {
        return pointLogMapper.selectPointLogList(pointLog);
    }

    @Override
    public int insertPointLog(SysUserPointLog pointLog) {
        return pointLogMapper.insertPointLog(pointLog);
    }

    @Override
    public int updatePointLog(SysUserPointLog pointLog) {
        return pointLogMapper.updatePointLog(pointLog);
    }

    @Override
    public int deletePointLogById(Long logId) {
        return pointLogMapper.deletePointLogById(logId);
    }

    @Override
    public int deletePointLogByIds(Long[] logIds) {
        return pointLogMapper.deletePointLogByIds(logIds);
    }
}
