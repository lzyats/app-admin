package com.ruoyi.system.domain;

import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 用户安全问题答案表 sys_user_security_answer
 *
 * @author ruoyi
 */
public class SysUserSecurityAnswer extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 答案ID */
    @Excel(name = "答案ID", cellType = Excel.ColumnType.NUMERIC)
    private Long answerId;

    /** 用户ID */
    @Excel(name = "用户ID", cellType = Excel.ColumnType.NUMERIC)
    private Long userId;

    /** 问题ID */
    @Excel(name = "问题ID", cellType = Excel.ColumnType.NUMERIC)
    private Long questionId;

    /** 答案（加密存储） */
    private String answer;

    /** 问题文本（不存储，用于显示） */
    private String questionText;

    public Long getAnswerId()
    {
        return answerId;
    }

    public void setAnswerId(Long answerId)
    {
        this.answerId = answerId;
    }

    public Long getUserId()
    {
        return userId;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    public Long getQuestionId()
    {
        return questionId;
    }

    public void setQuestionId(Long questionId)
    {
        this.questionId = questionId;
    }

    public String getAnswer()
    {
        return answer;
    }

    public void setAnswer(String answer)
    {
        this.answer = answer;
    }

    public String getQuestionText()
    {
        return questionText;
    }

    public void setQuestionText(String questionText)
    {
        this.questionText = questionText;
    }

    @Override
    public String toString()
    {
        return new org.apache.commons.lang3.builder.ToStringBuilder(this)
            .append("answerId", answerId)
            .append("userId", userId)
            .append("questionId", questionId)
            .append("questionText", questionText)
            .toString();
    }
}
