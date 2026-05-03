package com.ruoyi.system.service.impl;

import com.ruoyi.common.core.domain.entity.SysUserWalletLog;
import com.ruoyi.system.mapper.SysUserWalletLogMapper;
import com.ruoyi.system.service.ISysUserWalletLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

/**
 * 用户账变服务实现类
 * 
 * @author ruoyi
 */
@Service
public class SysUserWalletLogServiceImpl implements ISysUserWalletLogService {

    @Autowired
    private SysUserWalletLogMapper logMapper;

    @Override
    public List<SysUserWalletLog> selectLogsByUserId(Long userId) {
        return logMapper.selectLogsByUserId(userId);
    }

    @Override
    public List<SysUserWalletLog> selectLogsByWalletId(Long walletId) {
        return logMapper.selectLogsByWalletId(walletId);
    }

    @Override
    public SysUserWalletLog selectLogById(Long logId) {
        return logMapper.selectLogById(logId);
    }

    @Override
    public List<SysUserWalletLog> selectLogList(SysUserWalletLog log) {
        return logMapper.selectLogList(log);
    }

    @Override
    public int insertLog(SysUserWalletLog log) {
        return logMapper.insertLog(log);
    }

    @Override
    public int updateLog(SysUserWalletLog log) {
        return logMapper.updateLog(log);
    }

    @Override
    public int deleteLogById(Long logId) {
        return logMapper.deleteLogById(logId);
    }

    @Override
    public int deleteLogByIds(Long[] logIds) {
        return logMapper.deleteLogByIds(logIds);
    }
}