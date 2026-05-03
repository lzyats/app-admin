package com.ruoyi.system.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.service.ISysUserApiService;

/**
 * APP 专用用户缓存查询服务实现。
 *
 * 采用缓存优先、查库回源、写后失效的策略，供 APP 和后台用户页共用。
 */
@Service
public class SysUserApiServiceImpl implements ISysUserApiService
{
    /**
     * 用户缓存前缀。
     * 统一以 userId、userName、inviteCode 三种维度建立索引。
     */
    private static final String USER_CACHE_PREFIX = "cache:app:user:v2:";

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private RedisTemplate<Object, Object> redisTemplate;

    @Override
    public SysUser selectUserById(Long userId)
    {
        if (userId == null)
        {
            return null;
        }
        String cacheKey = buildIdKey(userId);
        SysUser user = getCacheUser(cacheKey);
        if (user != null)
        {
            return user;
        }
        user = userMapper.selectUserById(userId);
        cacheUser(user);
        return user;
    }

    @Override
    public SysUser selectUserByUserName(String userName)
    {
        if (StringUtils.isBlank(userName))
        {
            return null;
        }
        String cacheKey = buildUserNameKey(userName);
        SysUser user = getCacheUser(cacheKey);
        if (user != null)
        {
            return user;
        }
        user = userMapper.selectUserByUserName(userName);
        cacheUser(user);
        return user;
    }

    @Override
    public SysUser selectUserByInviteCode(String inviteCode)
    {
        if (StringUtils.isBlank(inviteCode))
        {
            return null;
        }
        String cacheKey = buildInviteCodeKey(inviteCode);
        SysUser user = getCacheUser(cacheKey);
        if (user != null)
        {
            return user;
        }
        user = userMapper.selectUserByInviteCode(inviteCode);
        cacheUser(user);
        return user;
    }

    @Override
    public void evictUserCache(Long userId)
    {
        if (userId == null)
        {
            return;
        }
        String idKey = buildIdKey(userId);
        SysUser cachedUser = getCacheUser(idKey);
        if (cachedUser == null)
        {
            cachedUser = userMapper.selectUserById(userId);
        }
        redisTemplate.delete(idKey);
        if (cachedUser != null)
        {
            if (StringUtils.isNotBlank(cachedUser.getUserName()))
            {
                redisTemplate.delete(buildUserNameKey(cachedUser.getUserName()));
            }
            if (StringUtils.isNotBlank(cachedUser.getInviteCode()))
            {
                redisTemplate.delete(buildInviteCodeKey(cachedUser.getInviteCode()));
            }
        }
    }

    private void cacheUser(SysUser user)
    {
        if (user == null || user.getUserId() == null)
        {
            return;
        }
        user.setRealNameStatus(normalizeRealNameStatus(user.getRealNameStatus()));
        user.setPayPasswordSet(StringUtils.isNotBlank(user.getPayPassword()) ? 1 : 0);
        redisTemplate.opsForValue().set(buildIdKey(user.getUserId()), user);
        if (StringUtils.isNotBlank(user.getUserName()))
        {
            redisTemplate.opsForValue().set(buildUserNameKey(user.getUserName()), user);
        }
        if (StringUtils.isNotBlank(user.getInviteCode()))
        {
            redisTemplate.opsForValue().set(buildInviteCodeKey(user.getInviteCode()), user);
        }
    }

    private SysUser getCacheUser(String key)
    {
        Object cached = redisTemplate.opsForValue().get(key);
        if (cached instanceof SysUser)
        {
            SysUser user = (SysUser) cached;
            user.setRealNameStatus(normalizeRealNameStatus(user.getRealNameStatus()));
            user.setPayPasswordSet(StringUtils.isNotBlank(user.getPayPassword()) ? 1 : 0);
            return user;
        }
        return null;
    }

    private Integer normalizeRealNameStatus(Integer status)
    {
        if (status == null || status <= 0)
        {
            return 0;
        }
        return status;
    }

    private String buildIdKey(Long userId)
    {
        return USER_CACHE_PREFIX + "id:" + userId;
    }

    private String buildUserNameKey(String userName)
    {
        return USER_CACHE_PREFIX + "name:" + userName;
    }

    private String buildInviteCodeKey(String inviteCode)
    {
        return USER_CACHE_PREFIX + "invite:" + inviteCode;
    }
}
