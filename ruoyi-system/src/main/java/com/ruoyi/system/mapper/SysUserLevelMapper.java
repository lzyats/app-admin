package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.SysUserLevel;

public interface SysUserLevelMapper
{
    SysUserLevel selectUserLevelById(Long levelId);

    List<SysUserLevel> selectUserLevelList(SysUserLevel userLevel);

    int insertUserLevel(SysUserLevel userLevel);

    int updateUserLevel(SysUserLevel userLevel);

    int deleteUserLevelById(Long levelId);

    int deleteUserLevelByIds(Long[] levelIds);
}
