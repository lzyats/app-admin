package com.ruoyi.system.domain;

import com.ruoyi.common.core.domain.BaseEntity;

public class SysMiner extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long minerId;

    private String minerName;

    private Integer minerLevel;

    private Integer power;

    private Double wagPerDay;

    private Integer minUserLevel;

    private Integer maxUserLevel;

    private String coverImage;

    private Integer sortOrder;

    private String status;

    public Long getMinerId()
    {
        return minerId;
    }

    public void setMinerId(Long minerId)
    {
        this.minerId = minerId;
    }

    public String getMinerName()
    {
        return minerName;
    }

    public void setMinerName(String minerName)
    {
        this.minerName = minerName;
    }

    public Integer getMinerLevel()
    {
        return minerLevel;
    }

    public void setMinerLevel(Integer minerLevel)
    {
        this.minerLevel = minerLevel;
    }

    public Integer getPower()
    {
        return power;
    }

    public void setPower(Integer power)
    {
        this.power = power;
    }

    public Double getWagPerDay()
    {
        return wagPerDay;
    }

    public void setWagPerDay(Double wagPerDay)
    {
        this.wagPerDay = wagPerDay;
    }

    public Integer getMinUserLevel()
    {
        return minUserLevel;
    }

    public void setMinUserLevel(Integer minUserLevel)
    {
        this.minUserLevel = minUserLevel;
    }

    public Integer getMaxUserLevel()
    {
        return maxUserLevel;
    }

    public void setMaxUserLevel(Integer maxUserLevel)
    {
        this.maxUserLevel = maxUserLevel;
    }

    public String getCoverImage()
    {
        return coverImage;
    }

    public void setCoverImage(String coverImage)
    {
        this.coverImage = coverImage;
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

