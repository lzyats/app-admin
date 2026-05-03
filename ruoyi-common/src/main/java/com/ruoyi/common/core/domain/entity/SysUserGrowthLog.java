package com.ruoyi.common.core.domain.entity;

import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 用户成长值变动日志
 */
public class SysUserGrowthLog extends BaseEntity
{
    private Long logId;
    private Long userId;
    private String userName;
    private Long changeValue;
    private Long growthValueBefore;
    private Long growthValueAfter;
    private String changeType;
    private String sourceType;
    private Long sourceId;
    private String sourceNo;
    private String status;
    private String operatorName;

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

    public String getUserName()
    {
        return userName;
    }

    public void setUserName(String userName)
    {
        this.userName = userName;
    }

    public Long getChangeValue()
    {
        return changeValue;
    }

    public void setChangeValue(Long changeValue)
    {
        this.changeValue = changeValue;
    }

    public Long getGrowthValueBefore()
    {
        return growthValueBefore;
    }

    public void setGrowthValueBefore(Long growthValueBefore)
    {
        this.growthValueBefore = growthValueBefore;
    }

    public Long getGrowthValueAfter()
    {
        return growthValueAfter;
    }

    public void setGrowthValueAfter(Long growthValueAfter)
    {
        this.growthValueAfter = growthValueAfter;
    }

    public String getChangeType()
    {
        return changeType;
    }

    public void setChangeType(String changeType)
    {
        this.changeType = changeType;
    }

    public String getSourceType()
    {
        return sourceType;
    }

    public void setSourceType(String sourceType)
    {
        this.sourceType = sourceType;
    }

    public Long getSourceId()
    {
        return sourceId;
    }

    public void setSourceId(Long sourceId)
    {
        this.sourceId = sourceId;
    }

    public String getSourceNo()
    {
        return sourceNo;
    }

    public void setSourceNo(String sourceNo)
    {
        this.sourceNo = sourceNo;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getOperatorName()
    {
        return operatorName;
    }

    public void setOperatorName(String operatorName)
    {
        this.operatorName = operatorName;
    }

}
