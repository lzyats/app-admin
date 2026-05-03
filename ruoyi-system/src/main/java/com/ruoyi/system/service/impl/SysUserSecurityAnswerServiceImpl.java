package com.ruoyi.system.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysUserSecurityAnswer;
import com.ruoyi.system.mapper.SysUserSecurityAnswerMapper;
import com.ruoyi.system.service.ISysUserSecurityAnswerService;

/**
 * 用户安全问题答案 服务层实现
 *
 * @author ruoyi
 */
@Service
public class SysUserSecurityAnswerServiceImpl implements ISysUserSecurityAnswerService
{
    @Autowired
    private SysUserSecurityAnswerMapper answerMapper;

    /**
     * 查询用户的安全问题答案
     *
     * @param userId 用户ID
     * @return 用户安全问题答案列表
     */
    @Override
    public List<SysUserSecurityAnswer> selectAnswerByUserId(Long userId)
    {
        return answerMapper.selectAnswerByUserId(userId);
    }

    /**
     * 查询用户已设置的问题数量
     *
     * @param userId 用户ID
     * @return 已设置问题数量
     */
    @Override
    public int selectAnswerCountByUserId(Long userId)
    {
        return answerMapper.selectAnswerCountByUserId(userId);
    }

    /**
     * 设置用户安全问题答案
     *
     * @param userId 用户ID
     * @param answers 安全问题答案列表
     * @return 结果
     */
    @Override
    @Transactional
    public int setUserSecurityAnswers(Long userId, List<SysUserSecurityAnswer> answers)
    {
        // 先删除用户现有的安全问题答案
        answerMapper.deleteAnswerByUserId(userId);

        // 插入新的答案
        int result = 0;
        for (SysUserSecurityAnswer answer : answers)
        {
            if (StringUtils.isNotNull(userId) && StringUtils.isNotNull(answer.getQuestionId())
                && StringUtils.isNotEmpty(answer.getAnswer()))
            {
                String normalizedAnswer = StringUtils.trim(answer.getAnswer());
                if (StringUtils.isEmpty(normalizedAnswer))
                {
                    continue;
                }
                answer.setUserId(userId);
                answer.setAnswer(SecurityUtils.encryptPassword(normalizedAnswer));
                result += answerMapper.insertAnswer(answer);
            }
        }
        return result;
    }

    /**
     * 验证用户安全问题答案是否正确
     *
     * @param userId 用户ID
     * @param questionId 问题ID
     * @param answer 答案
     * @return 是否正确
     */
    @Override
    public boolean verifyAnswer(Long userId, Long questionId, String answer)
    {
        String normalizedAnswer = StringUtils.trim(answer);
        if (StringUtils.isEmpty(normalizedAnswer))
        {
            return false;
        }
        SysUserSecurityAnswer existingAnswer = answerMapper.selectAnswerForVerify(userId, questionId);
        if (existingAnswer == null || StringUtils.isEmpty(existingAnswer.getAnswer()))
        {
            return false;
        }
        String storedAnswer = existingAnswer.getAnswer();
        if (isEncodedAnswer(storedAnswer))
        {
            return SecurityUtils.matchesPassword(normalizedAnswer, storedAnswer);
        }
        boolean matched = StringUtils.equals(normalizedAnswer, storedAnswer);
        if (matched)
        {
            existingAnswer.setAnswer(SecurityUtils.encryptPassword(normalizedAnswer));
            answerMapper.updateAnswer(existingAnswer);
        }
        return matched;
    }

    private boolean isEncodedAnswer(String storedAnswer)
    {
        return StringUtils.startsWithAny(storedAnswer, "$2a$", "$2b$", "$2y$");
    }

    /**
     * 删除用户安全问题答案
     *
     * @param answerId 答案ID
     * @return 结果
     */
    @Override
    public int deleteAnswerById(Long answerId)
    {
        return answerMapper.deleteAnswerById(answerId);
    }

    /**
     * 删除用户的所有安全问题答案
     *
     * @param userId 用户ID
     * @return 结果
     */
    @Override
    public int deleteAnswerByUserId(Long userId)
    {
        return answerMapper.deleteAnswerByUserId(userId);
    }
}
