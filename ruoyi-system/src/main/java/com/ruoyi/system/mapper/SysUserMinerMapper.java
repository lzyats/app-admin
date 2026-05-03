package com.ruoyi.system.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysUserMiner;

public interface SysUserMinerMapper
{
    SysUserMiner selectUserMinerById(Long userMinerId);

    SysUserMiner selectCurrentUserMiner(@Param("userId") Long userId);

    SysUserMiner selectUserMinerByUserAndMiner(@Param("userId") Long userId, @Param("minerId") Long minerId);

    List<SysUserMiner> selectUserMinerList(SysUserMiner query);

    int insertUserMiner(SysUserMiner userMiner);

    int updateUserMiner(SysUserMiner userMiner);

    int updateUserCurrentMiner(@Param("userId") Long userId, @Param("currentUserMinerId") Long currentUserMinerId, @Param("now") java.util.Date now);
}

