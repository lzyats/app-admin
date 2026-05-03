package com.ruoyi.system.service.impl;

import java.util.List;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.system.domain.SysUserLevel;
import com.ruoyi.system.mapper.SysUserLevelMapper;
import com.ruoyi.system.service.ISysUserLevelService;

@Service
public class SysUserLevelServiceImpl implements ISysUserLevelService
{
    private static final String CACHE_KEY_OPTIONS = "user:level:options";
    private static final Integer CACHE_EXPIRE_MINUTES = 30;

    @Autowired
    private SysUserLevelMapper userLevelMapper;

    @Autowired
    private RedisCache redisCache;

    @Override
    public SysUserLevel selectUserLevelById(Long levelId)
    {
        return userLevelMapper.selectUserLevelById(levelId);
    }

    @Override
    public List<SysUserLevel> selectUserLevelList(SysUserLevel userLevel)
    {
        return userLevelMapper.selectUserLevelList(userLevel);
    }

    @Override
    public List<SysUserLevel> selectEnabledOptionsCached()
    {
        List<SysUserLevel> cached = redisCache.getCacheObject(CACHE_KEY_OPTIONS);
        if (cached != null)
        {
            return cached;
        }
        SysUserLevel query = new SysUserLevel();
        query.setStatus("0");
        List<SysUserLevel> list = userLevelMapper.selectUserLevelList(query);
        redisCache.setCacheObject(CACHE_KEY_OPTIONS, list, CACHE_EXPIRE_MINUTES, TimeUnit.MINUTES);
        return list;
    }

    @Override
    public int insertUserLevel(SysUserLevel userLevel)
    {
        int rows = userLevelMapper.insertUserLevel(userLevel);
        if (rows > 0)
        {
            clearCache();
        }
        return rows;
    }

    @Override
    public int updateUserLevel(SysUserLevel userLevel)
    {
        int rows = userLevelMapper.updateUserLevel(userLevel);
        if (rows > 0)
        {
            clearCache();
        }
        return rows;
    }

    @Override
    public int deleteUserLevelByIds(Long[] levelIds)
    {
        int rows = userLevelMapper.deleteUserLevelByIds(levelIds);
        if (rows > 0)
        {
            clearCache();
        }
        return rows;
    }

    @Override
    public int deleteUserLevelById(Long levelId)
    {
        int rows = userLevelMapper.deleteUserLevelById(levelId);
        if (rows > 0)
        {
            clearCache();
        }
        return rows;
    }

    @Override
    public void clearCache()
    {
        redisCache.deleteObject(CACHE_KEY_OPTIONS);
    }
}
