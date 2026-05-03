package com.ruoyi.system.domain;

import com.ruoyi.common.core.domain.BaseEntity;

/**
 * User bank card entity.
 */
public class SysUserBankCard extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long bankCardId;

    private Long userId;

    private String userName;

    private String currencyType;

    private String bankName;

    private String accountNo;

    private String accountName;

    private String walletAddress;

    public Long getBankCardId()
    {
        return bankCardId;
    }

    public void setBankCardId(Long bankCardId)
    {
        this.bankCardId = bankCardId;
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
}
