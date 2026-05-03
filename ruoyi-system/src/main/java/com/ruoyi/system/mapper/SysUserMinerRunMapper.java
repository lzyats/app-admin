package com.ruoyi.system.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysUserMinerRun;

public interface SysUserMinerRunMapper
{
    SysUserMinerRun selectRunById(Long runId);

    SysUserMinerRun selectRunByIdForUpdate(@Param("runId") Long runId);

    SysUserMinerRun selectLatestRunByUserId(@Param("userId") Long userId);

    SysUserMinerRun selectActiveRunByUserIdForUpdate(@Param("userId") Long userId);

    List<SysUserMinerRun> selectRunsForCalc(@Param("now") java.util.Date now, @Param("limit") Integer limit);

    int insertRun(SysUserMinerRun run);

    int updateRun(SysUserMinerRun run);

    int markRunEndedByUserId(@Param("userId") Long userId, @Param("now") java.util.Date now);
}
