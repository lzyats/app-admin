package com.ruoyi.system.domain;

import com.ruoyi.common.core.domain.BaseEntity;

public class SysInvestTag extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long tagId;
    private String tagCode;
    private String tagName;
    private String tagColor;
    private Integer sortOrder;
    private String status;

    public Long getTagId()
    {
        return tagId;
    }

    public void setTagId(Long tagId)
    {
        this.tagId = tagId;
    }

    public String getTagCode()
    {
        return tagCode;
    }

    public void setTagCode(String tagCode)
    {
        this.tagCode = tagCode;
    }

    public String getTagName()
    {
        return tagName;
    }

    public void setTagName(String tagName)
    {
        this.tagName = tagName;
    }

    public String getTagColor()
    {
        return tagColor;
    }

    public void setTagColor(String tagColor)
    {
        this.tagColor = tagColor;
    }

    public Integer getSortOrder()
    {
        return sortOrder;
    }

    public void setSortOrder(Integer sortOrder)
    {
        this.sortOrder = sortOrder;
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
