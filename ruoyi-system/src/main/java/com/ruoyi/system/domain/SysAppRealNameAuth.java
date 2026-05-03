package com.ruoyi.system.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * APP实名认证表 sys_app_real_name_auth
 *
 * @author ruoyi
 */
public class SysAppRealNameAuth extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long authId;

    @Excel(name = "用户ID", cellType = Excel.ColumnType.NUMERIC)
    private Long userId;

    @Excel(name = "用户账号")
    private String userName;

    @Excel(name = "真实姓名")
    private String realName;

    @Excel(name = "身份证号")
    private String idCardNumber;

    @Excel(name = "身份证正面照")
    private String idCardFront;

    @Excel(name = "身份证反面照")
    private String idCardBack;

    @Excel(name = "手持身份证照")
    private String handheldPhoto;

    @Excel(name = "审核状态", readConverterExp = "0=待审核,1=通过,2=拒绝")
    private Integer status;

    @Excel(name = "拒绝原因")
    private String rejectReason;

    @Excel(name = "提交时间", width = 20, dateFormat = "yyyy-MM-dd HH:mm:ss")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date submitTime;

    @Excel(name = "审核时间", width = 20, dateFormat = "yyyy-MM-dd HH:mm:ss")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date reviewTime;

    @Excel(name = "审核人ID", cellType = Excel.ColumnType.NUMERIC)
    private Long reviewUserId;

    @Excel(name = "审核人账号")
    private String reviewUserName;

    public Long getAuthId()
    {
        return authId;
    }

    public void setAuthId(Long authId)
    {
        this.authId = authId;
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

    public String getRealName()
    {
        return realName;
    }

    public void setRealName(String realName)
    {
        this.realName = realName;
    }

    public String getIdCardNumber()
    {
        return idCardNumber;
    }

    public void setIdCardNumber(String idCardNumber)
    {
        this.idCardNumber = idCardNumber;
    }

    public String getIdCardFront()
    {
        return idCardFront;
    }

    public void setIdCardFront(String idCardFront)
    {
        this.idCardFront = idCardFront;
    }

    public String getIdCardBack()
    {
        return idCardBack;
    }

    public void setIdCardBack(String idCardBack)
    {
        this.idCardBack = idCardBack;
    }

    public String getHandheldPhoto()
    {
        return handheldPhoto;
    }

    public void setHandheldPhoto(String handheldPhoto)
    {
        this.handheldPhoto = handheldPhoto;
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

    @Override
    public String toString()
    {
        return new org.apache.commons.lang3.builder.ToStringBuilder(this)
            .append("authId", authId)
            .append("userId", userId)
            .append("userName", userName)
            .append("realName", realName)
            .append("idCardNumber", idCardNumber)
            .append("status", status)
            .toString();
    }
}