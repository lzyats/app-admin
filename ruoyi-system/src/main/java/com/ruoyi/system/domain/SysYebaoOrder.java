package com.ruoyi.system.domain;

import java.util.Date;
import com.ruoyi.common.core.domain.BaseEntity;

public class SysYebaoOrder extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long orderId;
    private String orderNo;
    private Long userId;
    private String userName;
    private Integer shares;
    private Double unitAmount;
    private Double principalAmount;
    private Double annualRate;
    private Double settledIncome;
    private Date investTime;
    private Date lastSettleTime;
    private Date nextSettleTime;
    private String status;

    public Long getOrderId()
    {
        return orderId;
    }

    public void setOrderId(Long orderId)
    {
        this.orderId = orderId;
    }

    public String getOrderNo()
    {
        return orderNo;
    }

    public void setOrderNo(String orderNo)
    {
        this.orderNo = orderNo;
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

    public Integer getShares()
    {
        return shares;
    }

    public void setShares(Integer shares)
    {
        this.shares = shares;
    }

    public Double getUnitAmount()
    {
        return unitAmount;
    }

    public void setUnitAmount(Double unitAmount)
    {
        this.unitAmount = unitAmount;
    }

    public Double getPrincipalAmount()
    {
        return principalAmount;
    }

    public void setPrincipalAmount(Double principalAmount)
    {
        this.principalAmount = principalAmount;
    }

    public Double getAnnualRate()
    {
        return annualRate;
    }

    public void setAnnualRate(Double annualRate)
    {
        this.annualRate = annualRate;
    }

    public Double getSettledIncome()
    {
        return settledIncome;
    }

    public void setSettledIncome(Double settledIncome)
    {
        this.settledIncome = settledIncome;
    }

    public Date getInvestTime()
    {
        return investTime;
    }

    public void setInvestTime(Date investTime)
    {
        this.investTime = investTime;
    }

    public Date getLastSettleTime()
    {
        return lastSettleTime;
    }

    public void setLastSettleTime(Date lastSettleTime)
    {
        this.lastSettleTime = lastSettleTime;
    }

    public Date getNextSettleTime()
    {
        return nextSettleTime;
    }

    public void setNextSettleTime(Date nextSettleTime)
    {
        this.nextSettleTime = nextSettleTime;
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
