package com.ruoyi.system.domain;

import java.util.Date;
import com.ruoyi.common.core.domain.BaseEntity;

public class SysMinerExchangeLog extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long exchangeId;

    private Long userId;

    private String requestNo;

    private Double wagAmount;

    private Double rate;

    private String targetCurrency;

    private Double targetAmount;

    private String status;

    private String errorMsg;

    private Date createTime;

    private Date updateTime;

    public Long getExchangeId()
    {
        return exchangeId;
    }

    public void setExchangeId(Long exchangeId)
    {
        this.exchangeId = exchangeId;
    }

    public Long getUserId()
    {
        return userId;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    public String getRequestNo()
    {
        return requestNo;
    }

    public void setRequestNo(String requestNo)
    {
        this.requestNo = requestNo;
    }

    public Double getWagAmount()
    {
        return wagAmount;
    }

    public void setWagAmount(Double wagAmount)
    {
        this.wagAmount = wagAmount;
    }

    public Double getRate()
    {
        return rate;
    }

    public void setRate(Double rate)
    {
        this.rate = rate;
    }

    public String getTargetCurrency()
    {
        return targetCurrency;
    }

    public void setTargetCurrency(String targetCurrency)
    {
        this.targetCurrency = targetCurrency;
    }

    public Double getTargetAmount()
    {
        return targetAmount;
    }

    public void setTargetAmount(Double targetAmount)
    {
        this.targetAmount = targetAmount;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getErrorMsg()
    {
        return errorMsg;
    }

    public void setErrorMsg(String errorMsg)
    {
        this.errorMsg = errorMsg;
    }

    public Date getCreateTime()
    {
        return createTime;
    }

    public void setCreateTime(Date createTime)
    {
        this.createTime = createTime;
    }

    public Date getUpdateTime()
    {
        return updateTime;
    }

    public void setUpdateTime(Date updateTime)
    {
        this.updateTime = updateTime;
    }
}

