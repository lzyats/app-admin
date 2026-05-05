package com.ruoyi.system.domain;

import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 新闻分类表 sys_news_category
 */
public class SysNewsCategory extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long categoryId;

    private String categoryCode;

    private String categoryName;

    /**
     * 分类类型：NEWS=新闻分类，APP_HOME_BANNER=首页Banner，APP_HOME_AD=首页广告
     */
    private String categoryType;

    private Integer sortOrder;

    private String status;

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

    public Integer getSortOrder()
    {
        return sortOrder;
    }

    public void setSortOrder(Integer sortOrder)
    {
        this.sortOrder = sortOrder;
    }

    public String getCategoryType()
    {
        return categoryType;
    }

    public void setCategoryType(String categoryType)
    {
        this.categoryType = categoryType;
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
