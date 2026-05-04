package com.ruoyi.system.domain;

import java.util.Date;

public class SysUserGoogleAuth
{
    private Long userId;
    private String secret;
    private Integer enabled;
    private Date bindTime;
    private Date updateTime;

    public Long getUserId()
    {
        return userId;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    public String getSecret()
    {
        return secret;
    }

    public void setSecret(String secret)
    {
        this.secret = secret;
    }

    public Integer getEnabled()
    {
        return enabled;
    }

    public void setEnabled(Integer enabled)
    {
        this.enabled = enabled;
    }

    public Date getBindTime()
    {
        return bindTime;
    }

    public void setBindTime(Date bindTime)
    {
        this.bindTime = bindTime;
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
