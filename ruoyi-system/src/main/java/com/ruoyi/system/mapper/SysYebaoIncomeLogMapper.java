package com.ruoyi.system.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysYebaoIncomeLog;

public interface SysYebaoIncomeLogMapper
{
    List<SysYebaoIncomeLog> selectYebaoIncomeLogList(SysYebaoIncomeLog log);

    List<SysYebaoIncomeLog> selectAppYebaoIncomeLogList(@Param("userId") Long userId);

    SysYebaoIncomeLog selectYebaoIncomeLogById(@Param("incomeId") Long incomeId);

    int insertYebaoIncomeLog(SysYebaoIncomeLog log);

    int updateYebaoIncomeLog(SysYebaoIncomeLog log);

    int deleteYebaoIncomeLogById(@Param("incomeId") Long incomeId);

    int deleteYebaoIncomeLogByIds(Long[] incomeIds);
}
