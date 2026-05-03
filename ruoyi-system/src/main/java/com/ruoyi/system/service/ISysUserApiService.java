package com.ruoyi.system.service;

import com.ruoyi.common.core.domain.entity.SysUser;

/**
 * APP 专用用户缓存查询服务。
 *
 * 负责用户信息的 Redis 缓存读写，供前端 APP 和后台用户管理页复用。
 */
public interface ISysUserApiService
{
    SysUser selectUserById(Long userId);

    SysUser selectUserByUserName(String userName);

    SysUser selectUserByInviteCode(String inviteCode);

    void evictUserCache(Long userId);
}
