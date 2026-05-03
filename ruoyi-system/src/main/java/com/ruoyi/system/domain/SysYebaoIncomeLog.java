package com.ruoyi.system.domain;

import java.util.Date;
import com.ruoyi.common.core.domain.BaseEntity;

public class SysYebaoIncomeLog extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long incomeId;
    private String incomeNo;
    private Long orderId;
    private String orderNo;
    private Long userId;
    private String userName;
    private Integer shares;
    private Double principalAmount;
    private Double annualRate;
    private Integer settleDays;
    private Double incomeAmount;
    private Date periodStartTime;
    private Date periodEndTime;
    private Date settleTime;
    private String status;

    public Long getIncomeId()
    {
        return incomeId;
    }

    public void setIncomeId(Long incomeId)
    {
        this.incomeId = incomeId;
    }

    public String getIncomeNo()
    {
        return incomeNo;
    }

    public void setIncomeNo(String incomeNo)
    {
        this.incomeNo = incomeNo;
    }

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

    public Integer getSettleDays()
    {
        return settleDays;
    }

    public void setSettleDays(Integer settleDays)
    {
        this.settleDays = settleDays;
    }

    public Double getIncomeAmount()
    {
        return incomeAmount;
    }

    public void setIncomeAmount(Double incomeAmount)
    {
        this.incomeAmount = incomeAmount;
    }

    public Date getPeriodStartTime()
    {
        return periodStartTime;
    }

    public void setPeriodStartTime(Date periodStartTime)
    {
        this.periodStartTime = periodStartTime;
    }

    public Date getPeriodEndTime()
    {
        return periodEndTime;
    }

    public void setPeriodEndTime(Date periodEndTime)
    {
        this.periodEndTime = periodEndTime;
    }

    public Date getSettleTime()
    {
        return settleTime;
    }

    public void setSettleTime(Date settleTime)
    {
        this.settleTime = settleTime;
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
