package com.ruoyi.system.domain;

import com.ruoyi.common.core.domain.BaseEntity;
import java.math.BigDecimal;

public class SysYebaoConfig extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long configId;
    private String configName;
    private Double annualRate;
    private Double unitAmount;
    private BigDecimal growthValuePerUnit; // 每份成长值
    private String status;

    public Long getConfigId()
    {
        return configId;
    }

    public void setConfigId(Long configId)
    {
        this.configId = configId;
    }

    public String getConfigName()
    {
        return configName;
    }

    public void setConfigName(String configName)
    {
        this.configName = configName;
    }

    public Double getAnnualRate()
    {
        return annualRate;
    }

    public void setAnnualRate(Double annualRate)
    {
        this.annualRate = annualRate;
    }

    public Double getUnitAmount()
    {
        return unitAmount;
    }

    public void setUnitAmount(Double unitAmount)
    {
        this.unitAmount = unitAmount;
    }

    public BigDecimal getGrowthValuePerUnit() {
        return growthValuePerUnit;
    }

    public void setGrowthValuePerUnit(BigDecimal growthValuePerUnit) {
        this.growthValuePerUnit = growthValuePerUnit;
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
