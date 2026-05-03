package com.ruoyi.system.domain;

import java.math.BigDecimal;
import java.util.Date;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 团队统计事件流水对象 sys_team_stat_event
 */
public class SysTeamStatEvent extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long eventId;
    private Date statDate;
    private Long ownerUserId;
    private Long memberUserId;
    private Integer relationDepth;
    private String eventType;
    private BigDecimal eventAmount;
    private Integer isValidUser;
    private String bizKey;
    private Date eventTime;

    public Long getEventId()
    {
        return eventId;
    }

    public void setEventId(Long eventId)
    {
        this.eventId = eventId;
    }

    public Date getStatDate()
    {
        return statDate;
    }

    public void setStatDate(Date statDate)
    {
        this.statDate = statDate;
    }

    public Long getOwnerUserId()
    {
        return ownerUserId;
    }

    public void setOwnerUserId(Long ownerUserId)
    {
        this.ownerUserId = ownerUserId;
    }

    public Long getMemberUserId()
    {
        return memberUserId;
    }

    public void setMemberUserId(Long memberUserId)
    {
        this.memberUserId = memberUserId;
    }

    public Integer getRelationDepth()
    {
        return relationDepth;
    }

    public void setRelationDepth(Integer relationDepth)
    {
        this.relationDepth = relationDepth;
    }

    public String getEventType()
    {
        return eventType;
    }

    public void setEventType(String eventType)
    {
        this.eventType = eventType;
    }

    public BigDecimal getEventAmount()
    {
        return eventAmount;
    }

    public void setEventAmount(BigDecimal eventAmount)
    {
        this.eventAmount = eventAmount;
    }

    public Integer getIsValidUser()
    {
        return isValidUser;
    }

    public void setIsValidUser(Integer isValidUser)
    {
        this.isValidUser = isValidUser;
    }

    public String getBizKey()
    {
        return bizKey;
    }

    public void setBizKey(String bizKey)
    {
        this.bizKey = bizKey;
    }

    public Date getEventTime()
    {
        return eventTime;
    }

    public void setEventTime(Date eventTime)
    {
        this.eventTime = eventTime;
    }
}
