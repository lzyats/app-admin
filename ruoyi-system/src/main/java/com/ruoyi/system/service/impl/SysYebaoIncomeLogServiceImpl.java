package com.ruoyi.system.service.impl;

import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.domain.SysYebaoIncomeLog;
import com.ruoyi.system.mapper.SysYebaoIncomeLogMapper;
import com.ruoyi.system.service.ISysYebaoIncomeLogService;

@Service
public class SysYebaoIncomeLogServiceImpl implements ISysYebaoIncomeLogService
{
    private static final Logger logger = LoggerFactory.getLogger(SysYebaoIncomeLogServiceImpl.class);

    @Autowired
    private SysYebaoIncomeLogMapper incomeLogMapper;

    @Override
    public List<SysYebaoIncomeLog> selectYebaoIncomeLogList(SysYebaoIncomeLog log)
    {
        try
        {
            return incomeLogMapper.selectYebaoIncomeLogList(log);
        }
        catch (Exception e)
        {
            logger.warn("Select yebao income list failed, return empty list: {}", e.getMessage());
            return new ArrayList<>();
        }
    }

    @Override
    public List<SysYebaoIncomeLog> selectAppYebaoIncomeLogList(Long userId)
    {
        try
        {
            return incomeLogMapper.selectAppYebaoIncomeLogList(userId);
        }
        catch (Exception e)
        {
            logger.warn("Select app yebao income list failed, return empty list: {}", e.getMessage());
            return new ArrayList<>();
        }
    }

    @Override
    public SysYebaoIncomeLog selectYebaoIncomeLogById(Long incomeId)
    {
        try
        {
            return incomeLogMapper.selectYebaoIncomeLogById(incomeId);
        }
        catch (Exception e)
        {
            logger.warn("Select yebao income by id failed, return null: {}", e.getMessage());
            return null;
        }
    }

    @Override
    public int insertYebaoIncomeLog(SysYebaoIncomeLog log)
    {
        return incomeLogMapper.insertYebaoIncomeLog(log);
    }

    @Override
    public int updateYebaoIncomeLog(SysYebaoIncomeLog log)
    {
        return incomeLogMapper.updateYebaoIncomeLog(log);
    }

    @Override
    public int deleteYebaoIncomeLogById(Long incomeId)
    {
        return incomeLogMapper.deleteYebaoIncomeLogById(incomeId);
    }

    @Override
    public int deleteYebaoIncomeLogByIds(Long[] incomeIds)
    {
        return incomeLogMapper.deleteYebaoIncomeLogByIds(incomeIds);
    }
}
