package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysUserLevel;

public interface ISysUserLevelService
{
    SysUserLevel selectUserLevelById(Long levelId);

    List<SysUserLevel> selectUserLevelList(SysUserLevel userLevel);

    List<SysUserLevel> selectEnabledOptionsCached();

    int insertUserLevel(SysUserLevel userLevel);

    int updateUserLevel(SysUserLevel userLevel);

    int deleteUserLevelByIds(Long[] levelIds);

    int deleteUserLevelById(Long levelId);

    void clearCache();
}
