package com.ruoyi.common.core.domain.model;

/**
 * 安全问题答案请求体
 *
 * @author ruoyi
 */
public class SecurityAnswerBody
{
    /**
     * 问题ID
     */
    private Long questionId;

    /**
     * 答案
     */
    private String answer;

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
}