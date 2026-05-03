package com.ruoyi.common.core.domain.entity;

import java.util.Date;

/**
 * 用户积分账变实体
 */
public class SysUserPointLog {
    /** 账变ID */
    private Long logId;

    /** 积分账户ID */
    private Long pointAccountId;

    /** 用户ID */
    private Long userId;

    /** 用户名 */
    private String userName;

    /** 变动积分 */
    private Long points;

    /** 变动前积分 */
    private Long pointsBefore;

    /** 变动后积分 */
    private Long pointsAfter;

    /** 变动类型：earn/spend/adjust/freeze/unfreeze */
    private String changeType;

    /** 业务来源：invest/activity/redeem/lottery/manual */
    private String sourceType;

    /** 业务来源ID */
    private Long sourceId;

    /** 业务单号 */
    private String sourceNo;

    /** 状态：success/pending/failed */
    private String status;

    /** 操作人 */
    private String operatorName;

    /** 备注 */
    private String remark;

    /** 创建时间 */
    private Date createTime;

    /** 更新时间 */
    private Date updateTime;

    public Long getLogId() {
        return logId;
    }

    public void setLogId(Long logId) {
        this.logId = logId;
    }

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

    public Long getPoints() {
        return points;
    }

    public void setPoints(Long points) {
        this.points = points;
    }

    public Long getPointsBefore() {
        return pointsBefore;
    }

    public void setPointsBefore(Long pointsBefore) {
        this.pointsBefore = pointsBefore;
    }

    public Long getPointsAfter() {
        return pointsAfter;
    }

    public void setPointsAfter(Long pointsAfter) {
        this.pointsAfter = pointsAfter;
    }

    public String getChangeType() {
        return changeType;
    }

    public void setChangeType(String changeType) {
        this.changeType = changeType;
    }

    public String getSourceType() {
        return sourceType;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public Long getSourceId() {
        return sourceId;
    }

    public void setSourceId(Long sourceId) {
        this.sourceId = sourceId;
    }

    public String getSourceNo() {
        return sourceNo;
    }

    public void setSourceNo(String sourceNo) {
        this.sourceNo = sourceNo;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getOperatorName() {
        return operatorName;
    }

    public void setOperatorName(String operatorName) {
        this.operatorName = operatorName;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
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
