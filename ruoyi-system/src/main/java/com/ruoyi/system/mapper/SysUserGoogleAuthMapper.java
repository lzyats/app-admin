package com.ruoyi.system.mapper;

import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysUserGoogleAuth;

public interface SysUserGoogleAuthMapper
{
    SysUserGoogleAuth selectByUserId(@Param("userId") Long userId);

    int upsert(@Param("userId") Long userId, @Param("secret") String secret, @Param("enabled") Integer enabled);

    int deleteByUserId(@Param("userId") Long userId);
}
