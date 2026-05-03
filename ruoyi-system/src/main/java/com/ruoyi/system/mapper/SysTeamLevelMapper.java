package com.ruoyi.system.mapper;

import java.math.BigDecimal;
import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysTeamLevel;

public interface SysTeamLevelMapper
{
    SysTeamLevel selectTeamLevelById(Long teamLevelId);

    List<SysTeamLevel> selectTeamLevelList(SysTeamLevel teamLevel);

    int insertTeamLevel(SysTeamLevel teamLevel);

    int updateTeamLevel(SysTeamLevel teamLevel);

    int deleteTeamLevelById(Long teamLevelId);

    int deleteTeamLevelByIds(Long[] teamLevelIds);

    int countDirectValidUsers(Long userId);

    int countTeamValidUsers(Long userId);

    BigDecimal sumTeamInvestAmount(Long userId);

    int updateUserTeamLeaderLevel(@Param("userId") Long userId, @Param("teamLeaderLevel") Integer teamLeaderLevel);
}
