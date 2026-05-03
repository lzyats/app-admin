package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.SysNewsArticle;

public interface SysNewsArticleMapper
{
    List<SysNewsArticle> selectNewsArticleList(SysNewsArticle article);

    List<SysNewsArticle> selectNewsArticleAll(SysNewsArticle article);

    SysNewsArticle selectNewsArticleById(Long articleId);

    int insertNewsArticle(SysNewsArticle article);

    int updateNewsArticle(SysNewsArticle article);

    int deleteNewsArticleById(Long articleId);

    int deleteNewsArticleByIds(Long[] articleIds);
}
