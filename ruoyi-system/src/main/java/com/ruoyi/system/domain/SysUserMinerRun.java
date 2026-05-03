package com.ruoyi.system.domain;

import java.util.Date;
import com.ruoyi.common.core.domain.BaseEntity;

public class SysUserMinerRun extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long runId;

    private Long userId;

    private Long userMinerId;

    private Long minerId;

    private String rewardMode;

    private String runStatus;

    private Date startTime;

    private Date cycleEndTime;

    private Date lastCalcTime;

    private Double cycleWag;

    private Double producedWag;

    private String creditedFlag;

    private Date collectTime;

    private Integer version;

    public Long getRunId()
    {
        return runId;
    }

    public void setRunId(Long runId)
    {
        this.runId = runId;
    }

    public Long getUserId()
    {
        return userId;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    public Long getUserMinerId()
    {
        return userMinerId;
    }

    public void setUserMinerId(Long userMinerId)
    {
        this.userMinerId = userMinerId;
    }

    public Long getMinerId()
    {
        return minerId;
    }

    public void setMinerId(Long minerId)
    {
        this.minerId = minerId;
    }

    public String getRewardMode()
    {
        return rewardMode;
    }

    public void setRewardMode(String rewardMode)
    {
        this.rewardMode = rewardMode;
    }

    public String getRunStatus()
    {
        return runStatus;
    }

    public void setRunStatus(String runStatus)
    {
        this.runStatus = runStatus;
    }

    public Date getStartTime()
    {
        return startTime;
    }

    public void setStartTime(Date startTime)
    {
        this.startTime = startTime;
    }

    public Date getCycleEndTime()
    {
        return cycleEndTime;
    }

    public void setCycleEndTime(Date cycleEndTime)
    {
        this.cycleEndTime = cycleEndTime;
    }

    public Date getLastCalcTime()
    {
        return lastCalcTime;
    }

    public void setLastCalcTime(Date lastCalcTime)
    {
        this.lastCalcTime = lastCalcTime;
    }

    public Double getCycleWag()
    {
        return cycleWag;
    }

    public void setCycleWag(Double cycleWag)
    {
        this.cycleWag = cycleWag;
    }

    public Double getProducedWag()
    {
        return producedWag;
    }

    public void setProducedWag(Double producedWag)
    {
        this.producedWag = producedWag;
    }

    public String getCreditedFlag()
    {
        return creditedFlag;
    }

    public void setCreditedFlag(String creditedFlag)
    {
        this.creditedFlag = creditedFlag;
    }

    public Date getCollectTime()
    {
        return collectTime;
    }

    public void setCollectTime(Date collectTime)
    {
        this.collectTime = collectTime;
    }

    public Integer getVersion()
    {
        return version;
    }

    public void setVersion(Integer version)
    {
        this.version = version;
    }
}

