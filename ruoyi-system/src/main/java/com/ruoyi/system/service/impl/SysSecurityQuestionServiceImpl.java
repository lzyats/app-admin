package com.ruoyi.system.service.impl;

import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.system.domain.SysSecurityQuestion;
import com.ruoyi.system.mapper.SysSecurityQuestionMapper;
import com.ruoyi.system.service.ISysSecurityQuestionService;

/**
 * 安全问题 服务层实现
 *
 * @author ruoyi
 */
@Service
public class SysSecurityQuestionServiceImpl implements ISysSecurityQuestionService
{
    @Autowired
    private SysSecurityQuestionMapper questionMapper;

    @Autowired
    private RedisCache redisCache;

    private static final String CACHE_KEY_PREFIX = "security:questions:";
    private static final Integer CACHE_EXPIRE_DAYS = 1;

    /**
     * 查询安全问题
     *
     * @param questionId 问题ID
     * @return 安全问题
     */
    @Override
    public SysSecurityQuestion selectQuestionById(Long questionId)
    {
        return questionMapper.selectQuestionById(questionId);
    }

    /**
     * 查询所有可用的安全问题
     *
     * @return 安全问题列表
     */
    @Override
    public List<SysSecurityQuestion> selectQuestionAll()
    {
        return selectQuestionAll("zh-CN");
    }

    /**
     * 查询所有可用的安全问题（支持多语言）
     *
     * @param lang 语言代码（zh-CN, en-US）
     * @return 安全问题列表
     */
    @Override
    public List<SysSecurityQuestion> selectQuestionAll(String lang)
    {
        String cacheKey = CACHE_KEY_PREFIX + (lang != null ? lang : "zh-CN");
        
        // 从缓存获取
        List<SysSecurityQuestion> questions = redisCache.getCacheObject(cacheKey);
        if (questions != null)
        {
            return questions;
        }

        // 从数据库获取
        questions = questionMapper.selectQuestionAll();
        
        // 处理多语言
        if ("en-US".equals(lang))
        {
            // 英文翻译
            Map<String, String> englishQuestions = Map.ofEntries(
                Map.entry("FATHER_BIRTHDAY", "What is your father's birthday?"),
                Map.entry("MOTHER_BIRTHDAY", "What is your mother's birthday?"),
                Map.entry("FIRST_PET_NAME", "What is the name of your first pet?"),
                Map.entry("FIRST_TEACHER", "What is the name of your elementary school teacher?"),
                Map.entry("BIRTH_CITY", "Where were you born?"),
                Map.entry("FAVORITE_BOOK", "What is your favorite book?"),
                Map.entry("FAVORITE_MOVIE", "What is your favorite movie?"),
                Map.entry("BEST_FRIEND", "What is the name of your best friend?"),
                Map.entry("FIRST_JOB", "What was your first job?"),
                Map.entry("DREAM_CITY", "What city do you most want to live in?"),
                Map.entry("CHILDHOOD_NICKNAME", "What was your childhood nickname?"),
                Map.entry("FIRST_LOVE", "Who was your first love?")
            );
            
            for (SysSecurityQuestion question : questions)
            {
                String englishText = englishQuestions.get(question.getQuestionCode());
                if (englishText != null)
                {
                    question.setQuestionText(englishText);
                }
            }
        }

        // 存入缓存，过期时间1天
        redisCache.setCacheObject(cacheKey, questions, CACHE_EXPIRE_DAYS, TimeUnit.DAYS);
        
        return questions;
    }

    /**
     * 查询安全问题列表
     *
     * @param question 安全问题信息
     * @return 安全问题集合
     */
    @Override
    public List<SysSecurityQuestion> selectQuestionList(SysSecurityQuestion question)
    {
        return questionMapper.selectQuestionList(question);
    }

    /**
     * 新增安全问题
     *
     * @param question 安全问题
     * @return 结果
     */
    @Override
    public int insertQuestion(SysSecurityQuestion question)
    {
        int result = questionMapper.insertQuestion(question);
        if (result > 0)
        {
            clearCache();
        }
        return result;
    }

    /**
     * 修改安全问题
     *
     * @param question 安全问题
     * @return 结果
     */
    @Override
    public int updateQuestion(SysSecurityQuestion question)
    {
        int result = questionMapper.updateQuestion(question);
        if (result > 0)
        {
            clearCache();
        }
        return result;
    }

    /**
     * 删除安全问题
     *
     * @param questionId 问题ID
     * @return 结果
     */
    @Override
    public int deleteQuestionById(Long questionId)
    {
        int result = questionMapper.deleteQuestionById(questionId);
        if (result > 0)
        {
            clearCache();
        }
        return result;
    }

    /**
     * 批量删除安全问题
     *
     * @param questionIds 需要删除的问题ID
     * @return 结果
     */
    @Override
    public int deleteQuestionByIds(Long[] questionIds)
    {
        int result = questionMapper.deleteQuestionByIds(questionIds);
        if (result > 0)
        {
            clearCache();
        }
        return result;
    }

    /**
     * 清除安全问题缓存
     */
    @Override
    public void clearCache()
    {
        // 清除所有语言的缓存
        redisCache.deleteObject(CACHE_KEY_PREFIX + "zh-CN");
        redisCache.deleteObject(CACHE_KEY_PREFIX + "en-US");
    }
}