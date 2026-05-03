package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysTeamLevel;

public interface ISysTeamLevelService
{
    SysTeamLevel selectTeamLevelById(Long teamLevelId);

    List<SysTeamLevel> selectTeamLevelList(SysTeamLevel teamLevel);

    List<SysTeamLevel> selectEnabledOptionsCached();

    int insertTeamLevel(SysTeamLevel teamLevel);

    int updateTeamLevel(SysTeamLevel teamLevel);

    int deleteTeamLevelByIds(Long[] teamLevelIds);

    /**
     * 检查并升级用户团队长等级
     *
     * @param userId 用户ID
     * @return true 表示发生升级
     */
    boolean checkAndUpgradeUserTeamLevel(Long userId);

    void clearCache();
}
