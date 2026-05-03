package com.ruoyi.system.domain;

import java.math.BigDecimal;
import com.ruoyi.common.core.domain.BaseEntity;

public class SysCouponTemplate extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long couponId;
    private String couponName;
    private String couponType;
    private String scopeType;
    private String productIdsJson;
    private BigDecimal minAmount;
    private BigDecimal discountAmount;
    private BigDecimal bonusPrincipal;
    private BigDecimal bonusRate;
    private BigDecimal experiencePrincipal;
    private Integer minExperienceUnits;
    private Integer maxExperienceUnits;
    private Integer validDays;
    private Integer totalCount;
    private Integer receivedCount;
    private String status;

    public Long getCouponId()
    {
        return couponId;
    }

    public void setCouponId(Long couponId)
    {
        this.couponId = couponId;
    }

    public String getCouponName()
    {
        return couponName;
    }

    public void setCouponName(String couponName)
    {
        this.couponName = couponName;
    }

    public String getCouponType()
    {
        return couponType;
    }

    public void setCouponType(String couponType)
    {
        this.couponType = couponType;
    }

    public String getScopeType()
    {
        return scopeType;
    }

    public void setScopeType(String scopeType)
    {
        this.scopeType = scopeType;
    }

    public String getProductIdsJson()
    {
        return productIdsJson;
    }

    public void setProductIdsJson(String productIdsJson)
    {
        this.productIdsJson = productIdsJson;
    }

    public BigDecimal getMinAmount()
    {
        return minAmount;
    }

    public void setMinAmount(BigDecimal minAmount)
    {
        this.minAmount = minAmount;
    }

    public BigDecimal getDiscountAmount()
    {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount)
    {
        this.discountAmount = discountAmount;
    }

    public BigDecimal getBonusPrincipal()
    {
        return bonusPrincipal;
    }

    public void setBonusPrincipal(BigDecimal bonusPrincipal)
    {
        this.bonusPrincipal = bonusPrincipal;
    }

    public BigDecimal getBonusRate()
    {
        return bonusRate;
    }

    public void setBonusRate(BigDecimal bonusRate)
    {
        this.bonusRate = bonusRate;
    }

    public BigDecimal getExperiencePrincipal()
    {
        return experiencePrincipal;
    }

    public void setExperiencePrincipal(BigDecimal experiencePrincipal)
    {
        this.experiencePrincipal = experiencePrincipal;
    }

    public Integer getMinExperienceUnits()
    {
        return minExperienceUnits;
    }

    public void setMinExperienceUnits(Integer minExperienceUnits)
    {
        this.minExperienceUnits = minExperienceUnits;
    }

    public Integer getMaxExperienceUnits()
    {
        return maxExperienceUnits;
    }

    public void setMaxExperienceUnits(Integer maxExperienceUnits)
    {
        this.maxExperienceUnits = maxExperienceUnits;
    }

    public Integer getValidDays()
    {
        return validDays;
    }

    public void setValidDays(Integer validDays)
    {
        this.validDays = validDays;
    }

    public Integer getTotalCount()
    {
        return totalCount;
    }

    public void setTotalCount(Integer totalCount)
    {
        this.totalCount = totalCount;
    }

    public Integer getReceivedCount()
    {
        return receivedCount;
    }

    public void setReceivedCount(Integer receivedCount)
    {
        this.receivedCount = receivedCount;
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
