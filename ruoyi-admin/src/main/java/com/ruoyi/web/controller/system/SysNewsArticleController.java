package com.ruoyi.web.controller.system;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.SysNewsArticle;
import com.ruoyi.system.service.ISysNewsArticleService;

@RestController
@RequestMapping("/system/news/article")
public class SysNewsArticleController extends BaseController
{
    @Autowired
    private ISysNewsArticleService newsArticleService;

    @PreAuthorize("@ss.hasPermi('system:news:article:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysNewsArticle article)
    {
        startPage();
        List<SysNewsArticle> list = newsArticleService.selectNewsArticleList(article);
        return getDataTable(list);
    }

    @GetMapping(value = "/{articleId}")
    public AjaxResult getInfo(@PathVariable Long articleId)
    {
        return success(newsArticleService.selectNewsArticleById(articleId));
    }

    @PreAuthorize("@ss.hasPermi('system:news:article:add')")
    @Log(title = "新闻文章", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysNewsArticle article)
    {
        article.setCreateBy(getUsername());
        return toAjax(newsArticleService.insertNewsArticle(article));
    }

    @PreAuthorize("@ss.hasPermi('system:news:article:edit')")
    @Log(title = "新闻文章", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysNewsArticle article)
    {
        article.setUpdateBy(getUsername());
        return toAjax(newsArticleService.updateNewsArticle(article));
    }

    @PreAuthorize("@ss.hasPermi('system:news:article:remove')")
    @Log(title = "新闻文章", businessType = BusinessType.DELETE)
    @DeleteMapping("/{articleIds}")
    public AjaxResult remove(@PathVariable Long[] articleIds)
    {
        return toAjax(newsArticleService.deleteNewsArticleByIds(articleIds));
    }
}
