package com.ruoyi.system.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * User withdraw order entity.
 */
public class SysUserWithdraw extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** Withdraw ID */
    private Long withdrawId;

    /** Order number */
    @Excel(name = "Order No")
    private String orderNo;

    /** Request number for idempotency */
    private String requestNo;

    /** User ID */
    @Excel(name = "User ID", cellType = Excel.ColumnType.NUMERIC)
    private Long userId;

    /** User name */
    @Excel(name = "User Name")
    private String userName;

    /** Currency type */
    @Excel(name = "Currency Type")
    private String currencyType;

    /** Withdraw method */
    @Excel(name = "Withdraw Method")
    private String withdrawMethod;

    /** Bank card ID */
    @Excel(name = "Bank Card ID", cellType = Excel.ColumnType.NUMERIC)
    private Long bankCardId;

    /** Bank name */
    @Excel(name = "Bank Name")
    private String bankName;

    /** Account number */
    @Excel(name = "Account No")
    private String accountNo;

    /** Account name */
    @Excel(name = "Account Name")
    private String accountName;

    /** Wallet address */
    @Excel(name = "Wallet Address")
    private String walletAddress;

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

    public Long getWithdrawId()
    {
        return withdrawId;
    }

    public void setWithdrawId(Long withdrawId)
    {
        this.withdrawId = withdrawId;
    }

    public String getOrderNo()
    {
        return orderNo;
    }

    public void setOrderNo(String orderNo)
    {
        this.orderNo = orderNo;
    }

    public String getRequestNo()
    {
        return requestNo;
    }

    public void setRequestNo(String requestNo)
    {
        this.requestNo = requestNo;
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

    public String getWithdrawMethod()
    {
        return withdrawMethod;
    }

    public void setWithdrawMethod(String withdrawMethod)
    {
        this.withdrawMethod = withdrawMethod;
    }

    public Long getBankCardId()
    {
        return bankCardId;
    }

    public void setBankCardId(Long bankCardId)
    {
        this.bankCardId = bankCardId;
    }

    public String getBankName()
    {
        return bankName;
    }

    public void setBankName(String bankName)
    {
        this.bankName = bankName;
    }

    public String getAccountNo()
    {
        return accountNo;
    }

    public void setAccountNo(String accountNo)
    {
        this.accountNo = accountNo;
    }

    public String getAccountName()
    {
        return accountName;
    }

    public void setAccountName(String accountName)
    {
        this.accountName = accountName;
    }

    public String getWalletAddress()
    {
        return walletAddress;
    }

    public void setWalletAddress(String walletAddress)
    {
        this.walletAddress = walletAddress;
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
