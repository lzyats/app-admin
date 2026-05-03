package com.ruoyi.system.service.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysNewsArticle;
import com.ruoyi.system.mapper.SysNewsArticleMapper;
import com.ruoyi.system.service.ISysNewsArticleService;

@Service
public class SysNewsArticleServiceImpl implements ISysNewsArticleService
{
    private static final String CACHE_PREFIX = "news:article:";
    private static final String CACHE_DETAIL_PREFIX = CACHE_PREFIX + "detail:";
    private static final String CACHE_LIST_PREFIX = CACHE_PREFIX + "list:";

    @Autowired
    private SysNewsArticleMapper newsArticleMapper;

    @Autowired
    private RedisCache redisCache;

    @Override
    public List<SysNewsArticle> selectNewsArticleList(SysNewsArticle article)
    {
        return newsArticleMapper.selectNewsArticleList(article);
    }

    @Override
    public List<SysNewsArticle> selectNewsArticleAll(SysNewsArticle article)
    {
        return selectAppNewsArticles(article);
    }

    @Override
    public List<SysNewsArticle> selectAppNewsArticles(SysNewsArticle article)
    {
        String cacheKey = buildListCacheKey(article);
        String cached = redisCache.getCacheObject(cacheKey);
        if (StringUtils.isNotBlank(cached))
        {
            try
            {
                return JSON.parseArray(cached, SysNewsArticle.class);
            }
            catch (Exception ignored)
            {
                redisCache.deleteObject(cacheKey);
            }
        }
        List<SysNewsArticle> articles = newsArticleMapper.selectNewsArticleAll(article);
        redisCache.setCacheObject(cacheKey, JSON.toJSONString(articles == null ? new ArrayList<>() : articles));
        return articles == null ? new ArrayList<>() : articles;
    }

    @Override
    public SysNewsArticle selectNewsArticleById(Long articleId)
    {
        return newsArticleMapper.selectNewsArticleById(articleId);
    }

    @Override
    public SysNewsArticle selectAppNewsArticleById(Long articleId)
    {
        String cacheKey = CACHE_DETAIL_PREFIX + articleId;
        String cached = redisCache.getCacheObject(cacheKey);
        if (StringUtils.isNotBlank(cached))
        {
            try
            {
                return JSON.parseObject(cached, SysNewsArticle.class);
            }
            catch (Exception ignored)
            {
                redisCache.deleteObject(cacheKey);
            }
        }
        SysNewsArticle article = newsArticleMapper.selectNewsArticleById(articleId);
        if (article != null)
        {
            redisCache.setCacheObject(cacheKey, JSON.toJSONString(article));
        }
        return article;
    }

    @Override
    public int insertNewsArticle(SysNewsArticle article)
    {
        int rows = newsArticleMapper.insertNewsArticle(article);
        clearCache();
        return rows;
    }

    @Override
    public int updateNewsArticle(SysNewsArticle article)
    {
        int rows = newsArticleMapper.updateNewsArticle(article);
        clearCache();
        return rows;
    }

    @Override
    public int deleteNewsArticleById(Long articleId)
    {
        int rows = newsArticleMapper.deleteNewsArticleById(articleId);
        clearCache();
        return rows;
    }

    @Override
    public int deleteNewsArticleByIds(Long[] articleIds)
    {
        int rows = newsArticleMapper.deleteNewsArticleByIds(articleIds);
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

    private String buildListCacheKey(SysNewsArticle article)
    {
        String articleTitle = article != null && StringUtils.isNotBlank(article.getArticleTitle()) ? article.getArticleTitle().trim() : "";
        String categoryCode = article != null && StringUtils.isNotBlank(article.getCategoryCode()) ? article.getCategoryCode().trim() : "";
        String status = article != null && StringUtils.isNotBlank(article.getStatus()) ? article.getStatus().trim() : "";
        return CACHE_LIST_PREFIX + categoryCode + ':' + status + ':' + articleTitle;
    }
}
