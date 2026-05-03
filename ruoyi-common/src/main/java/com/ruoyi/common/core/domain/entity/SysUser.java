package com.ruoyi.common.core.domain.entity;

import java.util.Date;
import java.util.List;
import jakarta.validation.constraints.*;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.annotation.Excel.ColumnType;
import com.ruoyi.common.annotation.Excel.Type;
import com.ruoyi.common.annotation.Excels;
import com.ruoyi.common.core.domain.BaseEntity;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.xss.Xss;

/**
 * 用户对象 sys_user
 *
 * @author ruoyi
 */
public class SysUser extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 用户ID */
    @Excel(name = "用户序号", type = Type.EXPORT, cellType = ColumnType.NUMERIC, prompt = "用户编号")
    private Long userId;

    /** 部门ID */
    @Excel(name = "部门编号", type = Type.IMPORT)
    private Long deptId;

    /** 用户账号 */
    @Excel(name = "登录名称")
    private String userName;

    /** 用户昵称 */
    @Excel(name = "用户名称")
    private String nickName;

    /** 用户邮箱 */
    @Excel(name = "用户邮箱")
    private String email;

    /** 手机号码 */
    @Excel(name = "手机号码", cellType = ColumnType.TEXT)
    private String phonenumber;

    /** 用户性别 */
    @Excel(name = "用户性别", readConverterExp = "0=男,1=女,2=未知")
    private String sex;

    /** 生日 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "生日", width = 15, dateFormat = "yyyy-MM-dd", type = Type.EXPORT)
    private Date birthday;

    /** 用户头像 */
    private String avatar;

    /** 密码 */
    private String password;

    /** 用户邀请码 */
    private String inviteCode;

    /** 用户层级详情，示例：0,100,200 */
    private String levelDetail;

    /** 用户层级，示例：0/1/2 */
    private Integer userLevel;

    /** 用户等级，用于APP展示 */
    private Integer level;

    /** 用户上级名称 */
    private String parentUserName;

    /** 支付密码 */
    private String payPassword;

    /** 支付密码是否已设置：1已设置，0未设置，null表示兼容旧数据未返回 */
    private Integer payPasswordSet;

    /** 安全问题是否已设置：1已设置，0未设置 */
    private Integer securityQuestionSet;

    /** 累计投资金额（人民币） */
    private Double totalInvestAmount;

    /** 累计充值金额（人民币） */
    private Double totalRechargeAmount;

    /** 成长值 */
    private Long growthValue;

    /** 团队长等级，默认0 */
    private Integer teamLeaderLevel;

    /** 实名认证状态：-1未提交，0待审核，1通过，2拒绝 */
    @Excel(name = "实名状态", readConverterExp = "-1=未提交,0=待审核,1=通过,2=拒绝")
    private Integer realNameStatus;

    /** 默认币种历史字段：仅用于兼容旧数据，APP 不再作为默认币种切换入口使用 */
    private String defaultCurrency;

    /** 账号状态（0正常 1停用） */
    @Excel(name = "账号状态", readConverterExp = "0=正常,1=停用")
    private String status;

    /** 删除标志（0代表存在 2代表删除） */
    private String delFlag;

    /** 最后登录IP */
    @Excel(name = "最后登录IP", type = Type.EXPORT)
    private String loginIp;

    /** 最后登录时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "最后登录时间", width = 30, dateFormat = "yyyy-MM-dd HH:mm:ss", type = Type.EXPORT)
    private Date loginDate;

    /** 密码最后更新时间 */
    private Date pwdUpdateDate;

    /** 部门对象 */
    @Excels({
        @Excel(name = "部门名称", targetAttr = "deptName", type = Type.EXPORT),
        @Excel(name = "部门负责人", targetAttr = "leader", type = Type.EXPORT)
    })
    private SysDept dept;

    /** 角色对象 */
    private List<SysRole> roles;

    /** 角色组 */
    private Long[] roleIds;

    /** 岗位组 */
    private Long[] postIds;

    /** 角色ID */
    private Long roleId;

    public SysUser()
    {

    }

    public SysUser(Long userId)
    {
        this.userId = userId;
    }

    public Long getUserId()
    {
        return userId;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    public boolean isAdmin()
    {
        return SecurityUtils.isAdmin(this.userId);
    }

    public Long getDeptId()
    {
        return deptId;
    }

    public void setDeptId(Long deptId)
    {
        this.deptId = deptId;
    }

    @Xss(message = "用户昵称不能包含脚本字符")
    @Size(min = 0, max = 30, message = "用户昵称长度不能超过30个字符")
    public String getNickName()
    {
        return nickName;
    }

    public void setNickName(String nickName)
    {
        this.nickName = nickName;
    }

    @Xss(message = "用户账号不能包含脚本字符")
    @NotBlank(message = "用户账号不能为空")
    @Size(min = 0, max = 30, message = "用户账号长度不能超过30个字符")
    public String getUserName()
    {
        return userName;
    }

    public void setUserName(String userName)
    {
        this.userName = userName;
    }

    @Email(message = "邮箱格式不正确")
    @Size(min = 0, max = 50, message = "邮箱长度不能超过50个字符")
    public String getEmail()
    {
        return email;
    }

    public void setEmail(String email)
    {
        this.email = email;
    }

    @Size(min = 0, max = 11, message = "手机号码长度不能超过11个字符")
    public String getPhonenumber()
    {
        return phonenumber;
    }

    public void setPhonenumber(String phonenumber)
    {
        this.phonenumber = phonenumber;
    }

    public String getSex()
    {
        return sex;
    }

    public void setSex(String sex)
    {
        this.sex = sex;
    }

    public Date getBirthday()
    {
        return birthday;
    }

    public void setBirthday(Date birthday)
    {
        this.birthday = birthday;
    }

    public Double getTotalInvestAmount()
    {
        return totalInvestAmount;
    }

    public void setTotalInvestAmount(Double totalInvestAmount)
    {
        this.totalInvestAmount = totalInvestAmount;
    }

    public Double getTotalRechargeAmount()
    {
        return totalRechargeAmount;
    }

    public void setTotalRechargeAmount(Double totalRechargeAmount)
    {
        this.totalRechargeAmount = totalRechargeAmount;
    }

    public Long getGrowthValue()
    {
        return growthValue;
    }

    public void setGrowthValue(Long growthValue)
    {
        this.growthValue = growthValue;
    }

    public Integer getTeamLeaderLevel()
    {
        return teamLeaderLevel;
    }

    public void setTeamLeaderLevel(Integer teamLeaderLevel)
    {
        this.teamLeaderLevel = teamLeaderLevel;
    }

    public String getAvatar()
    {
        return avatar;
    }

    public void setAvatar(String avatar)
    {
        this.avatar = avatar;
    }

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    public String getPassword()
    {
        return password;
    }

    public void setPassword(String password)
    {
        this.password = password;
    }

    public String getInviteCode()
    {
        return inviteCode;
    }

    public void setInviteCode(String inviteCode)
    {
        this.inviteCode = inviteCode;
    }

    public String getLevelDetail()
    {
        return levelDetail;
    }

    public void setLevelDetail(String levelDetail)
    {
        this.levelDetail = levelDetail;
    }

    public Integer getUserLevel()
    {
        return userLevel;
    }

    public void setUserLevel(Integer userLevel)
    {
        this.userLevel = userLevel;
    }

    public Integer getLevel()
    {
        return level;
    }

    public void setLevel(Integer level)
    {
        this.level = level;
    }

    public String getParentUserName()
    {
        return parentUserName;
    }

    public void setParentUserName(String parentUserName) {
        this.parentUserName = parentUserName;
    }

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    public String getPayPassword() {
        return payPassword;
    }

    public void setPayPassword(String payPassword) {
        this.payPassword = payPassword;
    }

    public Integer getPayPasswordSet()
    {
        return payPasswordSet;
    }

    public void setPayPasswordSet(Integer payPasswordSet)
    {
        this.payPasswordSet = payPasswordSet;
    }

    public Integer getSecurityQuestionSet()
    {
        return securityQuestionSet;
    }

    public void setSecurityQuestionSet(Integer securityQuestionSet)
    {
        this.securityQuestionSet = securityQuestionSet;
    }

    public Integer getRealNameStatus()
    {
        return realNameStatus;
    }

    public void setRealNameStatus(Integer realNameStatus)
    {
        this.realNameStatus = realNameStatus;
    }

    public String getDefaultCurrency()
    {
        return defaultCurrency;
    }

    public void setDefaultCurrency(String defaultCurrency)
    {
        this.defaultCurrency = defaultCurrency;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getDelFlag()
    {
        return delFlag;
    }

    public void setDelFlag(String delFlag)
    {
        this.delFlag = delFlag;
    }

    public String getLoginIp()
    {
        return loginIp;
    }

    public void setLoginIp(String loginIp)
    {
        this.loginIp = loginIp;
    }

    public Date getLoginDate()
    {
        return loginDate;
    }

    public void setLoginDate(Date loginDate)
    {
        this.loginDate = loginDate;
    }

    public Date getPwdUpdateDate()
    {
        return pwdUpdateDate;
    }

    public void setPwdUpdateDate(Date pwdUpdateDate)
    {
        this.pwdUpdateDate = pwdUpdateDate;
    }

    public SysDept getDept()
    {
        return dept;
    }

    public void setDept(SysDept dept)
    {
        this.dept = dept;
    }

    public List<SysRole> getRoles()
    {
        return roles;
    }

    public void setRoles(List<SysRole> roles)
    {
        this.roles = roles;
    }

    public Long[] getRoleIds()
    {
        return roleIds;
    }

    public void setRoleIds(Long[] roleIds)
    {
        this.roleIds = roleIds;
    }

    public Long[] getPostIds()
    {
        return postIds;
    }

    public void setPostIds(Long[] postIds)
    {
        this.postIds = postIds;
    }

    public Long getRoleId()
    {
        return roleId;
    }

    public void setRoleId(Long roleId)
    {
        this.roleId = roleId;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("userId", getUserId())
            .append("deptId", getDeptId())
            .append("userName", getUserName())
            .append("nickName", getNickName())
            .append("email", getEmail())
            .append("phonenumber", getPhonenumber())
            .append("sex", getSex())
            .append("birthday", getBirthday())
            .append("avatar", getAvatar())
            .append("password", getPassword())
            .append("inviteCode", getInviteCode())
            .append("levelDetail", getLevelDetail())
            .append("userLevel", getUserLevel())
            .append("level", getLevel())
            .append("parentUserName", getParentUserName())
            .append("payPassword", getPayPassword())
            .append("payPasswordSet", getPayPasswordSet())
            .append("securityQuestionSet", getSecurityQuestionSet())
            .append("totalInvestAmount", getTotalInvestAmount())
            .append("totalRechargeAmount", getTotalRechargeAmount())
            .append("growthValue", getGrowthValue())
            .append("teamLeaderLevel", getTeamLeaderLevel())
            .append("realNameStatus", getRealNameStatus())
            .append("defaultCurrency", getDefaultCurrency())
            .append("status", getStatus())
            .append("delFlag", getDelFlag())
            .append("loginIp", getLoginIp())
            .append("loginDate", getLoginDate())
            .append("pwdUpdateDate", getPwdUpdateDate())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .append("dept", getDept())
            .toString();
    }
}
