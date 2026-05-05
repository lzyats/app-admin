package com.ruoyi.web.controller.app;

import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysNotice;
import com.ruoyi.system.domain.SysNewsCategory;
import com.ruoyi.system.mapper.SysNoticeMapper;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.system.domain.SysNewsArticle;
import com.ruoyi.system.service.ISysNewsArticleService;
import com.ruoyi.system.service.ISysNewsCategoryService;

@RestController
@RequestMapping("/app/news")
public class AppNewsController extends BaseController
{
    private static final String CATEGORY_TYPE_NEWS = "NEWS";

    @Autowired
    private ISysNewsCategoryService newsCategoryService;

    @Autowired
    private ISysNewsArticleService newsArticleService;

    @Autowired
    private SysNoticeMapper noticeMapper;

    @Autowired
    private RedisCache redisCache;

    private static final String HOME_CACHE_KEY = "news:home:mix:v1";
    private static final Integer HOME_CACHE_TTL_MINUTES = 10;
    private static final String HOME_LATEST_NEWS_CACHE_KEY = "news:home:latest:v1";
    private static final Integer HOME_LATEST_NEWS_CACHE_MINUTES = 30;

    @GetMapping("/categories")
    public AjaxResult categories()
    {
        SysNewsCategory category = new SysNewsCategory();
        category.setStatus("0");
        category.setCategoryType(CATEGORY_TYPE_NEWS);
        return success(newsCategoryService.selectNewsCategoryList(category));
    }

    @GetMapping("/list")
    public AjaxResult list(SysNewsArticle article)
    {
        if (article.getStatus() == null || article.getStatus().isEmpty())
        {
            article.setStatus("0");
        }
        List<SysNewsArticle> list = newsArticleService.selectAppNewsArticles(article);
        return success(list);
    }

    @GetMapping("/{articleId}")
    public AjaxResult detail(@PathVariable Long articleId)
    {
        return success(newsArticleService.selectAppNewsArticleById(articleId));
    }

    @GetMapping("/home")
    public AjaxResult home()
    {
        String cached = redisCache.getCacheObject(HOME_CACHE_KEY);
        if (StringUtils.isNotBlank(cached))
        {
            return success(JSON.parseObject(cached));
        }
        SysNewsArticle bannerQuery = new SysNewsArticle();
        bannerQuery.setStatus("0");
        bannerQuery.setCategoryCode("APP_HOME_BANNER");
        List<SysNewsArticle> banners = newsArticleService.selectAppNewsArticles(bannerQuery);

        SysNewsArticle adQuery = new SysNewsArticle();
        adQuery.setStatus("0");
        adQuery.setCategoryCode("APP_HOME_AD");
        List<SysNewsArticle> ads = newsArticleService.selectAppNewsArticles(adQuery);

        List<SysNotice> notices = noticeMapper.selectAppNoticesForHome(20);

        Map<String, Object> result = new HashMap<>();
        result.put("banners", banners);
        result.put("ads", ads);
        result.put("notices", notices);
        redisCache.setCacheObject(HOME_CACHE_KEY, JSON.toJSONString(result), HOME_CACHE_TTL_MINUTES, TimeUnit.MINUTES);
        return success(result);
    }

    @GetMapping("/home/latest")
    public AjaxResult homeLatest()
    {
        String cached = redisCache.getCacheObject(HOME_LATEST_NEWS_CACHE_KEY);
        if (StringUtils.isNotBlank(cached))
        {
            return success(JSON.parseObject(cached));
        }

        SysNewsArticle query = new SysNewsArticle();
        query.setStatus("0");
        query.setCategoryCode("NEWS_INFO");
        List<SysNewsArticle> rawList = newsArticleService.selectAppNewsArticles(query);
        List<Map<String, Object>> rows = new ArrayList<>();
        for (SysNewsArticle item : rawList)
        {
            if (rows.size() >= 4)
            {
                break;
            }
            if (item == null || StringUtils.isBlank(item.getCoverImage()))
            {
                continue;
            }
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("articleId", item.getArticleId());
            row.put("articleTitle", item.getArticleTitle());
            row.put("coverImage", item.getCoverImage());
            row.put("summary", item.getSummary());
            rows.add(row);
        }
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("rows", rows);
        redisCache.setCacheObject(
            HOME_LATEST_NEWS_CACHE_KEY,
            JSON.toJSONString(result),
            HOME_LATEST_NEWS_CACHE_MINUTES,
            TimeUnit.MINUTES
        );
        return success(result);
    }
}
