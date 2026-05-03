package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.SysSecurityQuestion;

/**
 * 安全问题 数据层
 *
 * @author ruoyi
 */
public interface SysSecurityQuestionMapper
{
    /**
     * 查询安全问题列表
     *
     * @param question 安全问题信息
     * @return 安全问题集合
     */
    public List<SysSecurityQuestion> selectQuestionList(SysSecurityQuestion question);

    /**
     * 查询所有可用的安全问题
     *
     * @return 安全问题列表
     */
    public List<SysSecurityQuestion> selectQuestionAll();

    /**
     * 通过ID查询安全问题
     *
     * @param questionId 问题ID
     * @return 安全问题
     */
    public SysSecurityQuestion selectQuestionById(Long questionId);

    /**
     * 新增安全问题
     *
     * @param question 安全问题信息
     * @return 结果
     */
    public int insertQuestion(SysSecurityQuestion question);

    /**
     * 修改安全问题
     *
     * @param question 安全问题信息
     * @return 结果
     */
    public int updateQuestion(SysSecurityQuestion question);

    /**
     * 删除安全问题
     *
     * @param questionId 问题ID
     * @return 结果
     */
    public int deleteQuestionById(Long questionId);

    /**
     * 批量删除安全问题
     *
     * @param questionIds 需要删除的问题ID
     * @return 结果
     */
    public int deleteQuestionByIds(Long[] questionIds);
}