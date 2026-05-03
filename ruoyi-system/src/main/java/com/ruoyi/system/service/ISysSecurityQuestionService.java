package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysSecurityQuestion;

/**
 * 安全问题 服务层
 *
 * @author ruoyi
 */
public interface ISysSecurityQuestionService
{
    /**
     * 查询安全问题
     *
     * @param questionId 问题ID
     * @return 安全问题
     */
    public SysSecurityQuestion selectQuestionById(Long questionId);

    /**
     * 查询所有可用的安全问题
     *
     * @return 安全问题列表
     */
    public List<SysSecurityQuestion> selectQuestionAll();

    /**
     * 查询所有可用的安全问题（支持多语言）
     *
     * @param lang 语言代码（zh-CN, en-US）
     * @return 安全问题列表
     */
    public List<SysSecurityQuestion> selectQuestionAll(String lang);

    /**
     * 查询安全问题列表
     *
     * @param question 安全问题信息
     * @return 安全问题集合
     */
    public List<SysSecurityQuestion> selectQuestionList(SysSecurityQuestion question);

    /**
     * 新增安全问题
     *
     * @param question 安全问题
     * @return 结果
     */
    public int insertQuestion(SysSecurityQuestion question);

    /**
     * 修改安全问题
     *
     * @param question 安全问题
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

    /**
     * 清除安全问题缓存
     */
    public void clearCache();
}