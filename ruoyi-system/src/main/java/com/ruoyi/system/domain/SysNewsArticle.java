package com.ruoyi.system.domain;

import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 新闻文章表 sys_news_article
 */
public class SysNewsArticle extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long articleId;

    private Long categoryId;

    private String categoryCode;

    private String categoryName;

    private String articleTitle;

    private String summary;

    private String coverImage;

    private String articleContent;

    private Integer sortOrder;

    private String topFlag;

    private String status;

    public Long getArticleId()
    {
        return articleId;
    }

    public void setArticleId(Long articleId)
    {
        this.articleId = articleId;
    }

    public Long getCategoryId()
    {
        return categoryId;
    }

    public void setCategoryId(Long categoryId)
    {
        this.categoryId = categoryId;
    }

    public String getCategoryCode()
    {
        return categoryCode;
    }

    public void setCategoryCode(String categoryCode)
    {
        this.categoryCode = categoryCode;
    }

    public String getCategoryName()
    {
        return categoryName;
    }

    public void setCategoryName(String categoryName)
    {
        this.categoryName = categoryName;
    }

    public String getArticleTitle()
    {
        return articleTitle;
    }

    public void setArticleTitle(String articleTitle)
    {
        this.articleTitle = articleTitle;
    }

    public String getSummary()
    {
        return summary;
    }

    public void setSummary(String summary)
    {
        this.summary = summary;
    }

    public String getCoverImage()
    {
        return coverImage;
    }

    public void setCoverImage(String coverImage)
    {
        this.coverImage = coverImage;
    }

    public String getArticleContent()
    {
        return articleContent;
    }

    public void setArticleContent(String articleContent)
    {
        this.articleContent = articleContent;
    }

    public Integer getSortOrder()
    {
        return sortOrder;
    }

    public void setSortOrder(Integer sortOrder)
    {
        this.sortOrder = sortOrder;
    }

    public String getTopFlag()
    {
        return topFlag;
    }

    public void setTopFlag(String topFlag)
    {
        this.topFlag = topFlag;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }
}
