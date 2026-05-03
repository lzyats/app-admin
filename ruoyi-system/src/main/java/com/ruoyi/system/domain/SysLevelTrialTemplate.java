package com.ruoyi.system.domain;

import java.math.BigDecimal;
import com.ruoyi.common.core.domain.BaseEntity;

public class SysLevelTrialTemplate extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long trialId;
    private String trialName;
    private Integer trialLevel;
    private BigDecimal bonusRate;
    private Integer validDays;
    private Integer totalCount;
    private Integer receivedCount;
    private String status;

    public Long getTrialId()
    {
        return trialId;
    }

    public void setTrialId(Long trialId)
    {
        this.trialId = trialId;
    }

    public String getTrialName()
    {
        return trialName;
    }

    public void setTrialName(String trialName)
    {
        this.trialName = trialName;
    }

    public Integer getTrialLevel()
    {
        return trialLevel;
    }

    public void setTrialLevel(Integer trialLevel)
    {
        this.trialLevel = trialLevel;
    }

    public BigDecimal getBonusRate()
    {
        return bonusRate;
    }

    public void setBonusRate(BigDecimal bonusRate)
    {
        this.bonusRate = bonusRate;
    }

    public Integer getValidDays()
    {
        return validDays;
    }

    public void setValidDays(Integer validDays)
    {
        this.validDays = validDays;
    }

    public Integer getTotalCount()
    {
        return totalCount;
    }

    public void setTotalCount(Integer totalCount)
    {
        this.totalCount = totalCount;
    }

    public Integer getReceivedCount()
    {
        return receivedCount;
    }

    public void setReceivedCount(Integer receivedCount)
    {
        this.receivedCount = receivedCount;
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
