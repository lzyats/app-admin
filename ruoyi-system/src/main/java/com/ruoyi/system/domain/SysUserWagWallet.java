package com.ruoyi.system.domain;

import java.util.Date;
import com.ruoyi.common.core.domain.BaseEntity;

public class SysUserWagWallet extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long userId;

    private Double availableWag;

    private Double totalEarnedWag;

    private Double totalExchangedWag;

    private Date createTime;

    private Date updateTime;

    public Long getUserId()
    {
        return userId;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    public Double getAvailableWag()
    {
        return availableWag;
    }

    public void setAvailableWag(Double availableWag)
    {
        this.availableWag = availableWag;
    }

    public Double getTotalEarnedWag()
    {
        return totalEarnedWag;
    }

    public void setTotalEarnedWag(Double totalEarnedWag)
    {
        this.totalEarnedWag = totalEarnedWag;
    }

    public Double getTotalExchangedWag()
    {
        return totalExchangedWag;
    }

    public void setTotalExchangedWag(Double totalExchangedWag)
    {
        this.totalExchangedWag = totalExchangedWag;
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

