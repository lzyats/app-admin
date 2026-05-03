package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysYebaoIncomeLog;

public interface ISysYebaoIncomeLogService
{
    List<SysYebaoIncomeLog> selectYebaoIncomeLogList(SysYebaoIncomeLog log);

    List<SysYebaoIncomeLog> selectAppYebaoIncomeLogList(Long userId);

    SysYebaoIncomeLog selectYebaoIncomeLogById(Long incomeId);

    int insertYebaoIncomeLog(SysYebaoIncomeLog log);

    int updateYebaoIncomeLog(SysYebaoIncomeLog log);

    int deleteYebaoIncomeLogById(Long incomeId);

    int deleteYebaoIncomeLogByIds(Long[] incomeIds);
}
