package com.ruoyi.system.domain;

import java.util.Date;
import com.ruoyi.common.core.domain.BaseEntity;

public class SysUserMiner extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long userMinerId;

    private Long userId;

    private Long minerId;

    private String minerName;

    private Integer minerLevel;

    private Integer power;

    private Double wagPerDay;

    private String coverImage;

    private String isCurrent;

    private Date claimTime;

    private Date activeTime;

    private Date inactiveTime;

    private Double totalOutputWag;

    private String status;

    public Long getUserMinerId()
    {
        return userMinerId;
    }

    public void setUserMinerId(Long userMinerId)
    {
        this.userMinerId = userMinerId;
    }

    public Long getUserId()
    {
        return userId;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

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

    public String getCoverImage()
    {
        return coverImage;
    }

    public void setCoverImage(String coverImage)
    {
        this.coverImage = coverImage;
    }

    public String getIsCurrent()
    {
        return isCurrent;
    }

    public void setIsCurrent(String isCurrent)
    {
        this.isCurrent = isCurrent;
    }

    public Date getClaimTime()
    {
        return claimTime;
    }

    public void setClaimTime(Date claimTime)
    {
        this.claimTime = claimTime;
    }

    public Date getActiveTime()
    {
        return activeTime;
    }

    public void setActiveTime(Date activeTime)
    {
        this.activeTime = activeTime;
    }

    public Date getInactiveTime()
    {
        return inactiveTime;
    }

    public void setInactiveTime(Date inactiveTime)
    {
        this.inactiveTime = inactiveTime;
    }

    public Double getTotalOutputWag()
    {
        return totalOutputWag;
    }

    public void setTotalOutputWag(Double totalOutputWag)
    {
        this.totalOutputWag = totalOutputWag;
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

