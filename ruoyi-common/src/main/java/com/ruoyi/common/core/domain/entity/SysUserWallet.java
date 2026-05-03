package com.ruoyi.common.core.domain.entity;

import java.util.Date;

/**
 * 用户钱包实体
 */
public class SysUserWallet {
    /** 钱包ID */
    private Long walletId;

    /** 用户ID */
    private Long userId;

    /** 钱包币种，CNY 或 USD */
    private String currencyType;

    /** 用户名称 */
    private String userName;

    /** 总投资金额 */
    private Double totalInvest;

    /** 可用余额 */
    private Double availableBalance;

    /** 人民币可兑换美元额度 */
    private Double usdExchangeQuota;

    /** 冻结金额 */
    private Double frozenAmount;

    /** 收益金额 */
    private Double profitAmount;

    /** 待收金额 */
    private Double pendingAmount;

    /** 累计充值 */
    private Double totalRecharge;

    /** 累计提现 */
    private Double totalWithdraw;

    /** 创建时间 */
    private Date createTime;

    /** 更新时间 */
    private Date updateTime;

    public Long getWalletId() {
        return walletId;
    }

    public void setWalletId(Long walletId) {
        this.walletId = walletId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getCurrencyType() {
        return currencyType;
    }

    public void setCurrencyType(String currencyType) {
        this.currencyType = currencyType;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public Double getTotalInvest() {
        return totalInvest;
    }

    public void setTotalInvest(Double totalInvest) {
        this.totalInvest = totalInvest;
    }

    public Double getAvailableBalance() {
        return availableBalance;
    }

    public void setAvailableBalance(Double availableBalance) {
        this.availableBalance = availableBalance;
    }

    public Double getUsdExchangeQuota() {
        return usdExchangeQuota;
    }

    public void setUsdExchangeQuota(Double usdExchangeQuota) {
        this.usdExchangeQuota = usdExchangeQuota;
    }

    public Double getFrozenAmount() {
        return frozenAmount;
    }

    public void setFrozenAmount(Double frozenAmount) {
        this.frozenAmount = frozenAmount;
    }

    public Double getProfitAmount() {
        return profitAmount;
    }

    public void setProfitAmount(Double profitAmount) {
        this.profitAmount = profitAmount;
    }

    public Double getPendingAmount() {
        return pendingAmount;
    }

    public void setPendingAmount(Double pendingAmount) {
        this.pendingAmount = pendingAmount;
    }

    public Double getTotalRecharge() {
        return totalRecharge;
    }

    public void setTotalRecharge(Double totalRecharge) {
        this.totalRecharge = totalRecharge;
    }

    public Double getTotalWithdraw() {
        return totalWithdraw;
    }

    public void setTotalWithdraw(Double totalWithdraw) {
        this.totalWithdraw = totalWithdraw;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public Date getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
    }
}
