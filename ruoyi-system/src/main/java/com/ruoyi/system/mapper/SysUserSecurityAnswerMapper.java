package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.SysUserSecurityAnswer;
import org.apache.ibatis.annotations.Param;

/**
 * 用户安全问题答案 数据层
 *
 * @author ruoyi
 */
public interface SysUserSecurityAnswerMapper
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
     * 新增用户安全问题答案
     *
     * @param answer 用户安全问题答案
     * @return 结果
     */
    public int insertAnswer(SysUserSecurityAnswer answer);

    /**
     * 修改用户安全问题答案
     *
     * @param answer 用户安全问题答案
     * @return 结果
     */
    public int updateAnswer(SysUserSecurityAnswer answer);

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

    /**
     * 批量删除用户安全问题答案
     *
     * @param answerIds 需要删除的答案ID
     * @return 结果
     */
    public int deleteAnswerByIds(Long[] answerIds);

    /**
     * 验证用户安全问题答案是否正确
     *
     * @param userId 用户ID
     * @param questionId 问题ID
     * @param answer 答案
     * @return 是否正确
     */
    public SysUserSecurityAnswer selectAnswerForVerify(@Param("userId") Long userId, @Param("questionId") Long questionId);
}
