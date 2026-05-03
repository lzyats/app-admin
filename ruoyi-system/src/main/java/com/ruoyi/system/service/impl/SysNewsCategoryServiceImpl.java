package com.ruoyi.system.service.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysNewsCategory;
import com.ruoyi.system.mapper.SysNewsCategoryMapper;
import com.ruoyi.system.service.ISysNewsCategoryService;

@Service
public class SysNewsCategoryServiceImpl implements ISysNewsCategoryService
{
    private static final String CACHE_PREFIX = "news:category:";
    private static final String CACHE_ALL_KEY = CACHE_PREFIX + "all";

    @Autowired
    private SysNewsCategoryMapper newsCategoryMapper;

    @Autowired
    private RedisCache redisCache;

    @Override
    public List<SysNewsCategory> selectNewsCategoryList(SysNewsCategory category)
    {
        return newsCategoryMapper.selectNewsCategoryList(category);
    }

    @Override
    public List<SysNewsCategory> selectNewsCategoryAll()
    {
        String cached = redisCache.getCacheObject(CACHE_ALL_KEY);
        if (StringUtils.isNotBlank(cached))
        {
            try
            {
                return JSON.parseArray(cached, SysNewsCategory.class);
            }
            catch (Exception ignored)
            {
                redisCache.deleteObject(CACHE_ALL_KEY);
            }
        }
        List<SysNewsCategory> categories = newsCategoryMapper.selectNewsCategoryAll();
        redisCache.setCacheObject(CACHE_ALL_KEY, JSON.toJSONString(categories == null ? new ArrayList<>() : categories));
        return categories == null ? new ArrayList<>() : categories;
    }

    @Override
    public SysNewsCategory selectNewsCategoryById(Long categoryId)
    {
        return newsCategoryMapper.selectNewsCategoryById(categoryId);
    }

    @Override
    public int insertNewsCategory(SysNewsCategory category)
    {
        int rows = newsCategoryMapper.insertNewsCategory(category);
        clearCache();
        return rows;
    }

    @Override
    public int updateNewsCategory(SysNewsCategory category)
    {
        int rows = newsCategoryMapper.updateNewsCategory(category);
        clearCache();
        return rows;
    }

    @Override
    public int deleteNewsCategoryById(Long categoryId)
    {
        int rows = newsCategoryMapper.deleteNewsCategoryById(categoryId);
        clearCache();
        return rows;
    }

    @Override
    public int deleteNewsCategoryByIds(Long[] categoryIds)
    {
        int rows = newsCategoryMapper.deleteNewsCategoryByIds(categoryIds);
        clearCache();
        return rows;
    }

    @Override
    public void clearCache()
    {
        Collection<String> keys = redisCache.keys("news:*");
        if (keys != null && !keys.isEmpty())
        {
            redisCache.deleteObject(keys);
        }
    }
}
