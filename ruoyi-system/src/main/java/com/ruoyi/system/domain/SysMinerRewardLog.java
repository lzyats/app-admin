package com.ruoyi.system.domain;

import java.util.Date;
import com.ruoyi.common.core.domain.BaseEntity;

public class SysMinerRewardLog extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long logId;

    private Long userId;

    private Long minerId;

    private Long userMinerId;

    private Long runId;

    private String rewardMode;

    private String action;

    private Double wagAmount;

    private Date periodStart;

    private Date periodEnd;

    private Date createTime;

    private String remark;

    public Long getLogId()
    {
        return logId;
    }

    public void setLogId(Long logId)
    {
        this.logId = logId;
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

    public Long getUserMinerId()
    {
        return userMinerId;
    }

    public void setUserMinerId(Long userMinerId)
    {
        this.userMinerId = userMinerId;
    }

    public Long getRunId()
    {
        return runId;
    }

    public void setRunId(Long runId)
    {
        this.runId = runId;
    }

    public String getRewardMode()
    {
        return rewardMode;
    }

    public void setRewardMode(String rewardMode)
    {
        this.rewardMode = rewardMode;
    }

    public String getAction()
    {
        return action;
    }

    public void setAction(String action)
    {
        this.action = action;
    }

    public Double getWagAmount()
    {
        return wagAmount;
    }

    public void setWagAmount(Double wagAmount)
    {
        this.wagAmount = wagAmount;
    }

    public Date getPeriodStart()
    {
        return periodStart;
    }

    public void setPeriodStart(Date periodStart)
    {
        this.periodStart = periodStart;
    }

    public Date getPeriodEnd()
    {
        return periodEnd;
    }

    public void setPeriodEnd(Date periodEnd)
    {
        this.periodEnd = periodEnd;
    }

    public Date getCreateTime()
    {
        return createTime;
    }

    public void setCreateTime(Date createTime)
    {
        this.createTime = createTime;
    }

    public String getRemark()
    {
        return remark;
    }

    public void setRemark(String remark)
    {
        this.remark = remark;
    }
}

