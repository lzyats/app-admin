package com.ruoyi.system.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * User recharge order entity.
 */
public class SysUserRecharge extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** Recharge ID */
    private Long rechargeId;

    /** Order number */
    @Excel(name = "Order No")
    private String orderNo;

    /** User ID */
    @Excel(name = "User ID", cellType = Excel.ColumnType.NUMERIC)
    private Long userId;

    /** User name */
    @Excel(name = "User Name")
    private String userName;

    /** Currency type */
    @Excel(name = "Currency Type")
    private String currencyType;

    /** Recharge method */
    @Excel(name = "Recharge Method")
    private String rechargeMethod;

    /** Amount */
    @Excel(name = "Amount")
    private Double amount;

    /** Wallet ID */
    @Excel(name = "Wallet ID", cellType = Excel.ColumnType.NUMERIC)
    private Long walletId;

    /** Status: 0 pending, 1 approved, 2 rejected */
    @Excel(name = "Status", readConverterExp = "0=Pending,1=Approved,2=Rejected")
    private Integer status;

    /** Reject reason */
    @Excel(name = "Reject Reason")
    private String rejectReason;

    /** Submit time */
    @Excel(name = "Submit Time", width = 20, dateFormat = "yyyy-MM-dd HH:mm:ss")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date submitTime;

    /** Review time */
    @Excel(name = "Review Time", width = 20, dateFormat = "yyyy-MM-dd HH:mm:ss")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date reviewTime;

    /** Review user ID */
    @Excel(name = "Review User ID", cellType = Excel.ColumnType.NUMERIC)
    private Long reviewUserId;

    /** Review user name */
    @Excel(name = "Review User Name")
    private String reviewUserName;

    public Long getRechargeId()
    {
        return rechargeId;
    }

    public void setRechargeId(Long rechargeId)
    {
        this.rechargeId = rechargeId;
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

    public String getCurrencyType()
    {
        return currencyType;
    }

    public void setCurrencyType(String currencyType)
    {
        this.currencyType = currencyType;
    }

    public String getRechargeMethod()
    {
        return rechargeMethod;
    }

    public void setRechargeMethod(String rechargeMethod)
    {
        this.rechargeMethod = rechargeMethod;
    }

    public Double getAmount()
    {
        return amount;
    }

    public void setAmount(Double amount)
    {
        this.amount = amount;
    }

    public Long getWalletId()
    {
        return walletId;
    }

    public void setWalletId(Long walletId)
    {
        this.walletId = walletId;
    }

    public Integer getStatus()
    {
        return status;
    }

    public void setStatus(Integer status)
    {
        this.status = status;
    }

    public String getRejectReason()
    {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason)
    {
        this.rejectReason = rejectReason;
    }

    public Date getSubmitTime()
    {
        return submitTime;
    }

    public void setSubmitTime(Date submitTime)
    {
        this.submitTime = submitTime;
    }

    public Date getReviewTime()
    {
        return reviewTime;
    }

    public void setReviewTime(Date reviewTime)
    {
        this.reviewTime = reviewTime;
    }

    public Long getReviewUserId()
    {
        return reviewUserId;
    }

    public void setReviewUserId(Long reviewUserId)
    {
        this.reviewUserId = reviewUserId;
    }

    public String getReviewUserName()
    {
        return reviewUserName;
    }

    public void setReviewUserName(String reviewUserName)
    {
        this.reviewUserName = reviewUserName;
    }
}
