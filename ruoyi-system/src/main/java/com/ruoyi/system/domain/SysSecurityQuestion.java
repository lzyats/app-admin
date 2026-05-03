package com.ruoyi.system.domain;

import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 安全问题表 sys_security_question
 *
 * @author ruoyi
 */
public class SysSecurityQuestion extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 问题ID */
    @Excel(name = "问题ID", cellType = Excel.ColumnType.NUMERIC)
    private Long questionId;

    /** 问题代码 */
    @Excel(name = "问题代码")
    private String questionCode;

    /** 问题文本 */
    @Excel(name = "问题文本")
    private String questionText;

    /** 排序 */
    @Excel(name = "排序", cellType = Excel.ColumnType.NUMERIC)
    private Integer questionOrder;

    /** 状态（0正常 1停用） */
    @Excel(name = "状态", readConverterExp = "0=正常,1=停用")
    private String status;

    public Long getQuestionId()
    {
        return questionId;
    }

    public void setQuestionId(Long questionId)
    {
        this.questionId = questionId;
    }

    public String getQuestionCode()
    {
        return questionCode;
    }

    public void setQuestionCode(String questionCode)
    {
        this.questionCode = questionCode;
    }

    public String getQuestionText()
    {
        return questionText;
    }

    public void setQuestionText(String questionText)
    {
        this.questionText = questionText;
    }

    public Integer getQuestionOrder()
    {
        return questionOrder;
    }

    public void setQuestionOrder(Integer questionOrder)
    {
        this.questionOrder = questionOrder;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    @Override
    public String toString()
    {
        return new org.apache.commons.lang3.builder.ToStringBuilder(this)
            .append("questionId", questionId)
            .append("questionCode", questionCode)
            .append("questionText", questionText)
            .append("questionOrder", questionOrder)
            .append("status", status)
            .toString();
    }
}