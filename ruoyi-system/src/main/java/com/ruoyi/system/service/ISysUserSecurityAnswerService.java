package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysUserSecurityAnswer;

/**
 * 用户安全问题答案 服务层
 *
 * @author ruoyi
 */
public interface ISysUserSecurityAnswerService
{
    /**
     * 查询用户的安全问题答案
     *
     * @param userId 用户ID
     * @return 用户安全问题答案列表
     */
    public List<SysUserSecurityAnswer> selectAnswerByUserId(Long userId);

    /**
     * 查询用户已设置的问题数量
     *
     * @param userId 用户ID
     * @return 已设置问题数量
     */
    public int selectAnswerCountByUserId(Long userId);

    /**
     * 设置用户安全问题答案
     *
     * @param userId 用户ID
     * @param answers 安全问题答案列表
     * @return 结果
     */
    public int setUserSecurityAnswers(Long userId, List<SysUserSecurityAnswer> answers);

    /**
     * 验证用户安全问题答案是否正确
     *
     * @param userId 用户ID
     * @param questionId 问题ID
     * @param answer 答案
     * @return 是否正确
     */
    public boolean verifyAnswer(Long userId, Long questionId, String answer);

    /**
     * 删除用户安全问题答案
     *
     * @param answerId 答案ID
     * @return 结果
     */
    public int deleteAnswerById(Long answerId);

    /**
     * 删除用户的所有安全问题答案
     *
     * @param userId 用户ID
     * @return 结果
     */
    public int deleteAnswerByUserId(Long userId);
}