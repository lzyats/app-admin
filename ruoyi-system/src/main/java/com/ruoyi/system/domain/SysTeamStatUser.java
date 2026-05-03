package com.ruoyi.system.domain;

import java.math.BigDecimal;
import java.util.Date;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 团队统计用户汇总对象 sys_team_stat_user
 */
public class SysTeamStatUser extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long userId;
    private String userName;
    private String nickName;
    private Integer teamLevel;
    private Date calcDate;
    private Integer calcDepth;
    private Integer directUserCount;
    private Integer directValidUserCount;
    private Integer teamUserCount;
    private Integer teamValidUserCount;
    private BigDecimal teamTotalAsset;
    private BigDecimal teamTotalInvest;

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

    public String getNickName()
    {
        return nickName;
    }

    public void setNickName(String nickName)
    {
        this.nickName = nickName;
    }

    public Integer getTeamLevel()
    {
        return teamLevel;
    }

    public void setTeamLevel(Integer teamLevel)
    {
        this.teamLevel = teamLevel;
    }

    public Date getCalcDate()
    {
        return calcDate;
    }

    public void setCalcDate(Date calcDate)
    {
        this.calcDate = calcDate;
    }

    public Integer getCalcDepth()
    {
        return calcDepth;
    }

    public void setCalcDepth(Integer calcDepth)
    {
        this.calcDepth = calcDepth;
    }

    public Integer getDirectUserCount()
    {
        return directUserCount;
    }

    public void setDirectUserCount(Integer directUserCount)
    {
        this.directUserCount = directUserCount;
    }

    public Integer getDirectValidUserCount()
    {
        return directValidUserCount;
    }

    public void setDirectValidUserCount(Integer directValidUserCount)
    {
        this.directValidUserCount = directValidUserCount;
    }

    public Integer getTeamUserCount()
    {
        return teamUserCount;
    }

    public void setTeamUserCount(Integer teamUserCount)
    {
        this.teamUserCount = teamUserCount;
    }

    public Integer getTeamValidUserCount()
    {
        return teamValidUserCount;
    }

    public void setTeamValidUserCount(Integer teamValidUserCount)
    {
        this.teamValidUserCount = teamValidUserCount;
    }

    public BigDecimal getTeamTotalAsset()
    {
        return teamTotalAsset;
    }

    public void setTeamTotalAsset(BigDecimal teamTotalAsset)
    {
        this.teamTotalAsset = teamTotalAsset;
    }

    public BigDecimal getTeamTotalInvest()
    {
        return teamTotalInvest;
    }

    public void setTeamTotalInvest(BigDecimal teamTotalInvest)
    {
        this.teamTotalInvest = teamTotalInvest;
    }
}
