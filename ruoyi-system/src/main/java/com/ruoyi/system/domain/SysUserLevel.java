package com.ruoyi.system.domain;

import java.math.BigDecimal;
import com.ruoyi.common.core.domain.BaseEntity;

public class SysUserLevel extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long levelId;

    private Integer level;

    private String levelName;

    private Long requiredGrowthValue;

    private BigDecimal investBonus;

    private String icon;

    private String status;

    public Long getLevelId()
    {
        return levelId;
    }

    public void setLevelId(Long levelId)
    {
        this.levelId = levelId;
    }

    public Integer getLevel()
    {
        return level;
    }

    public void setLevel(Integer level)
    {
        this.level = level;
    }

    public String getLevelName()
    {
        return levelName;
    }

    public void setLevelName(String levelName)
    {
        this.levelName = levelName;
    }

    public Long getRequiredGrowthValue()
    {
        return requiredGrowthValue;
    }

    public void setRequiredGrowthValue(Long requiredGrowthValue)
    {
        this.requiredGrowthValue = requiredGrowthValue;
    }

    public BigDecimal getInvestBonus()
    {
        return investBonus;
    }

    public void setInvestBonus(BigDecimal investBonus)
    {
        this.investBonus = investBonus;
    }

    public String getIcon()
    {
        return icon;
    }

    public void setIcon(String icon)
    {
        this.icon = icon;
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
