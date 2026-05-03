package com.ruoyi.common.core.domain.entity;

import java.util.Date;

/**
 * 用户积分账户实体
 */
public class SysUserPointAccount {
    /** 积分账户ID */
    private Long pointAccountId;

    /** 用户ID */
    private Long userId;

    /** 用户名 */
    private String userName;

    /** 可用积分 */
    private Long availablePoints;

    /** 冻结积分 */
    private Long frozenPoints;

    /** 累计获得积分 */
    private Long totalEarned;

    /** 累计消耗积分 */
    private Long totalSpent;

    /** 累计人工调整积分 */
    private Long totalAdjusted;

    /** 创建时间 */
    private Date createTime;

    /** 更新时间 */
    private Date updateTime;

    public Long getPointAccountId() {
        return pointAccountId;
    }

    public void setPointAccountId(Long pointAccountId) {
        this.pointAccountId = pointAccountId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public Long getAvailablePoints() {
        return availablePoints;
    }

    public void setAvailablePoints(Long availablePoints) {
        this.availablePoints = availablePoints;
    }

    public Long getFrozenPoints() {
        return frozenPoints;
    }

    public void setFrozenPoints(Long frozenPoints) {
        this.frozenPoints = frozenPoints;
    }

    public Long getTotalEarned() {
        return totalEarned;
    }

    public void setTotalEarned(Long totalEarned) {
        this.totalEarned = totalEarned;
    }

    public Long getTotalSpent() {
        return totalSpent;
    }

    public void setTotalSpent(Long totalSpent) {
        this.totalSpent = totalSpent;
    }

    public Long getTotalAdjusted() {
        return totalAdjusted;
    }

    public void setTotalAdjusted(Long totalAdjusted) {
        this.totalAdjusted = totalAdjusted;
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
