package com.ruoyi.system.domain;

import java.math.BigDecimal;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 团队长等级配置对象 sys_team_level
 */
public class SysTeamLevel extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long teamLevelId;
    private Integer teamLevel;
    private String teamLevelName;
    private Integer requiredUserLevel;
    private Integer requiredDirectUsers;
    private Integer requiredTeamUsers;
    private BigDecimal requiredTeamInvest;
    private BigDecimal rewardAmount;
    private BigDecimal teamBonusRate;
    private String status;

    public Long getTeamLevelId()
    {
        return teamLevelId;
    }

    public void setTeamLevelId(Long teamLevelId)
    {
        this.teamLevelId = teamLevelId;
    }

    public Integer getTeamLevel()
    {
        return teamLevel;
    }

    public void setTeamLevel(Integer teamLevel)
    {
        this.teamLevel = teamLevel;
    }

    public String getTeamLevelName()
    {
        return teamLevelName;
    }

    public void setTeamLevelName(String teamLevelName)
    {
        this.teamLevelName = teamLevelName;
    }

    public Integer getRequiredUserLevel()
    {
        return requiredUserLevel;
    }

    public void setRequiredUserLevel(Integer requiredUserLevel)
    {
        this.requiredUserLevel = requiredUserLevel;
    }

    public Integer getRequiredDirectUsers()
    {
        return requiredDirectUsers;
    }

    public void setRequiredDirectUsers(Integer requiredDirectUsers)
    {
        this.requiredDirectUsers = requiredDirectUsers;
    }

    public Integer getRequiredTeamUsers()
    {
        return requiredTeamUsers;
    }

    public void setRequiredTeamUsers(Integer requiredTeamUsers)
    {
        this.requiredTeamUsers = requiredTeamUsers;
    }

    public BigDecimal getRequiredTeamInvest()
    {
        return requiredTeamInvest;
    }

    public void setRequiredTeamInvest(BigDecimal requiredTeamInvest)
    {
        this.requiredTeamInvest = requiredTeamInvest;
    }

    public BigDecimal getRewardAmount()
    {
        return rewardAmount;
    }

    public void setRewardAmount(BigDecimal rewardAmount)
    {
        this.rewardAmount = rewardAmount;
    }

    public BigDecimal getTeamBonusRate()
    {
        return teamBonusRate;
    }

    public void setTeamBonusRate(BigDecimal teamBonusRate)
    {
        this.teamBonusRate = teamBonusRate;
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
