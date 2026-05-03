package com.ruoyi.system.domain;

import java.math.BigDecimal;
import com.ruoyi.common.core.domain.BaseEntity;

public class SysInvestProduct extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long productId;
    private String productCode;
    private String productName;
    private String currency;
    private String cardTheme;
    private String riskTag;
    private BigDecimal singleRate;
    private BigDecimal groupRate;
    private Integer cycleDays;
    private String interestMode;
    private String principalMode;
    private Integer interestStageCount;
    private Integer principalStageCount;
    private String stageConfigJson;
    private BigDecimal minInvestAmount;
    private BigDecimal maxInvestAmount;
    private Long totalShares;
    private Long soldShares;
    private BigDecimal pointPerUnit;
    private BigDecimal growthPerUnit;
    private BigDecimal redPacketPerUnit;
    private String couponEnabled;
    private String groupEnabled;
    private Integer groupSize;
    private String autoGroup;
    private Integer limitLevel;
    private Integer limitTimes;
    private String status;
    private Long[] tagIds;

    public Long getProductId()
    {
        return productId;
    }

    public void setProductId(Long productId)
    {
        this.productId = productId;
    }

    public String getProductCode()
    {
        return productCode;
    }

    public void setProductCode(String productCode)
    {
        this.productCode = productCode;
    }

    public String getProductName()
    {
        return productName;
    }

    public void setProductName(String productName)
    {
        this.productName = productName;
    }

    public String getCurrency()
    {
        return currency;
    }

    public void setCurrency(String currency)
    {
        this.currency = currency;
    }

    public String getCardTheme()
    {
        return cardTheme;
    }

    public void setCardTheme(String cardTheme)
    {
        this.cardTheme = cardTheme;
    }

    public String getRiskTag()
    {
        return riskTag;
    }

    public void setRiskTag(String riskTag)
    {
        this.riskTag = riskTag;
    }

    public BigDecimal getSingleRate()
    {
        return singleRate;
    }

    public void setSingleRate(BigDecimal singleRate)
    {
        this.singleRate = singleRate;
    }

    public BigDecimal getGroupRate()
    {
        return groupRate;
    }

    public void setGroupRate(BigDecimal groupRate)
    {
        this.groupRate = groupRate;
    }

    public Integer getCycleDays()
    {
        return cycleDays;
    }

    public void setCycleDays(Integer cycleDays)
    {
        this.cycleDays = cycleDays;
    }

    public String getInterestMode()
    {
        return interestMode;
    }

    public void setInterestMode(String interestMode)
    {
        this.interestMode = interestMode;
    }

    public String getPrincipalMode()
    {
        return principalMode;
    }

    public void setPrincipalMode(String principalMode)
    {
        this.principalMode = principalMode;
    }

    public Integer getInterestStageCount()
    {
        return interestStageCount;
    }

    public void setInterestStageCount(Integer interestStageCount)
    {
        this.interestStageCount = interestStageCount;
    }

    public Integer getPrincipalStageCount()
    {
        return principalStageCount;
    }

    public void setPrincipalStageCount(Integer principalStageCount)
    {
        this.principalStageCount = principalStageCount;
    }

    public String getStageConfigJson()
    {
        return stageConfigJson;
    }

    public void setStageConfigJson(String stageConfigJson)
    {
        this.stageConfigJson = stageConfigJson;
    }

    public BigDecimal getMinInvestAmount()
    {
        return minInvestAmount;
    }

    public void setMinInvestAmount(BigDecimal minInvestAmount)
    {
        this.minInvestAmount = minInvestAmount;
    }

    public BigDecimal getMaxInvestAmount()
    {
        return maxInvestAmount;
    }

    public void setMaxInvestAmount(BigDecimal maxInvestAmount)
    {
        this.maxInvestAmount = maxInvestAmount;
    }

    public Long getTotalShares()
    {
        return totalShares;
    }

    public void setTotalShares(Long totalShares)
    {
        this.totalShares = totalShares;
    }

    public Long getSoldShares()
    {
        return soldShares;
    }

    public void setSoldShares(Long soldShares)
    {
        this.soldShares = soldShares;
    }

    public BigDecimal getPointPerUnit()
    {
        return pointPerUnit;
    }

    public void setPointPerUnit(BigDecimal pointPerUnit)
    {
        this.pointPerUnit = pointPerUnit;
    }

    public BigDecimal getGrowthPerUnit()
    {
        return growthPerUnit;
    }

    public void setGrowthPerUnit(BigDecimal growthPerUnit)
    {
        this.growthPerUnit = growthPerUnit;
    }

    public BigDecimal getRedPacketPerUnit()
    {
        return redPacketPerUnit;
    }

    public void setRedPacketPerUnit(BigDecimal redPacketPerUnit)
    {
        this.redPacketPerUnit = redPacketPerUnit;
    }

    public String getCouponEnabled()
    {
        return couponEnabled;
    }

    public void setCouponEnabled(String couponEnabled)
    {
        this.couponEnabled = couponEnabled;
    }

    public String getGroupEnabled()
    {
        return groupEnabled;
    }

    public void setGroupEnabled(String groupEnabled)
    {
        this.groupEnabled = groupEnabled;
    }

    public Integer getGroupSize()
    {
        return groupSize;
    }

    public void setGroupSize(Integer groupSize)
    {
        this.groupSize = groupSize;
    }

    public String getAutoGroup()
    {
        return autoGroup;
    }

    public void setAutoGroup(String autoGroup)
    {
        this.autoGroup = autoGroup;
    }

    public Integer getLimitLevel()
    {
        return limitLevel;
    }

    public void setLimitLevel(Integer limitLevel)
    {
        this.limitLevel = limitLevel;
    }

    public Integer getLimitTimes()
    {
        return limitTimes;
    }

    public void setLimitTimes(Integer limitTimes)
    {
        this.limitTimes = limitTimes;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public Long[] getTagIds()
    {
        return tagIds;
    }

    public void setTagIds(Long[] tagIds)
    {
        this.tagIds = tagIds;
    }
}
