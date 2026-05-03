package com.ruoyi.web.controller.app;

import java.util.List;
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
    @Autowired
    private ISysNewsCategoryService newsCategoryService;

    @Autowired
    private ISysNewsArticleService newsArticleService;

    @GetMapping("/categories")
    public AjaxResult categories()
    {
        return success(newsCategoryService.selectNewsCategoryAll());
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
}
