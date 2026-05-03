package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysNewsArticle;

public interface ISysNewsArticleService
{
    List<SysNewsArticle> selectNewsArticleList(SysNewsArticle article);

    List<SysNewsArticle> selectNewsArticleAll(SysNewsArticle article);

    List<SysNewsArticle> selectAppNewsArticles(SysNewsArticle article);

    SysNewsArticle selectNewsArticleById(Long articleId);

    SysNewsArticle selectAppNewsArticleById(Long articleId);

    int insertNewsArticle(SysNewsArticle article);

    int updateNewsArticle(SysNewsArticle article);

    int deleteNewsArticleById(Long articleId);

    int deleteNewsArticleByIds(Long[] articleIds);

    void clearCache();
}
