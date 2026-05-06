package com.ruoyi.system.service.impl;

import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.time.LocalDateTime;
import java.time.ZoneId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysLevelTrialTemplate;
import com.ruoyi.system.mapper.SysCardPackageMapper;
import com.ruoyi.system.mapper.SysLevelTrialTemplateMapper;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.service.ISysLevelTrialTemplateService;
import com.ruoyi.system.service.ISysUserApiService;

@Service
public class SysLevelTrialTemplateServiceImpl implements ISysLevelTrialTemplateService
{
    @Autowired
    private SysLevelTrialTemplateMapper trialTemplateMapper;

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private SysCardPackageMapper cardPackageMapper;

    @Autowired
    private ISysUserApiService userApiService;

    @Override
    public SysLevelTrialTemplate selectLevelTrialTemplateById(Long trialId)
    {
        return trialTemplateMapper.selectLevelTrialTemplateById(trialId);
    }

    @Override
    public List<SysLevelTrialTemplate> selectLevelTrialTemplateList(SysLevelTrialTemplate template)
    {
        return trialTemplateMapper.selectLevelTrialTemplateList(template);
    }

    @Override
    public int insertLevelTrialTemplate(SysLevelTrialTemplate template)
    {
        return trialTemplateMapper.insertLevelTrialTemplate(template);
    }

    @Override
    public int updateLevelTrialTemplate(SysLevelTrialTemplate template)
    {
        return trialTemplateMapper.updateLevelTrialTemplate(template);
    }

    @Override
    public int deleteLevelTrialTemplateByIds(Long[] trialIds)
    {
        return trialTemplateMapper.deleteLevelTrialTemplateByIds(trialIds);
    }

    @Override
    @Transactional
    public int grantTrialToUsers(Long trialId, List<Long> userIds, String grantType, String operator, String remark)
    {
        SysLevelTrialTemplate template = trialTemplateMapper.selectLevelTrialTemplateById(trialId);
        if (template == null)
        {
            throw new ServiceException("体验卡模板不存在");
        }
        if (userIds == null || userIds.isEmpty())
        {
            throw new ServiceException("请选择发放用户");
        }

        Set<Long> uniqueUserIds = new LinkedHashSet<Long>(userIds);
        List<Long> eligibleUserIds = new ArrayList<Long>();
        for (Long userId : uniqueUserIds)
        {
            if (userId == null || userId <= 0L)
            {
                continue;
            }
            SysUser user = userMapper.selectUserById(userId);
            if (user == null)
            {
                continue;
            }
            if (trialTemplateMapper.countUserTrialByTrialAndUser(trialId, userId) > 0)
            {
                throw new ServiceException("当前用户已领取过该体验卡，不能重复发放");
            }
            eligibleUserIds.add(userId);
        }
        if (eligibleUserIds.isEmpty())
        {
            throw new ServiceException("发放目标不存在或已失效");
        }

        Integer totalCount = template.getTotalCount() == null ? 0 : template.getTotalCount();
        Integer receivedCount = template.getReceivedCount() == null ? 0 : template.getReceivedCount();
        if (totalCount > 0 && receivedCount + eligibleUserIds.size() > totalCount)
        {
            throw new ServiceException("发放数量超过模板总数");
        }

        int count = 0;
        for (Long userId : eligibleUserIds)
        {
            SysUser user = userMapper.selectUserById(userId);
            if (user == null)
            {
                continue;
            }
            try
            {
                count += trialTemplateMapper.insertUserTrial(trialId, userId, user.getUserName(),
                    StringUtils.isBlank(grantType) ? "MANUAL" : grantType, template.getValidDays(), operator, remark);
            }
            catch (DuplicateKeyException ex)
            {
                throw new ServiceException("当前用户已领取过该体验卡，不能重复发放");
            }
        }
        if (count > 0)
        {
            trialTemplateMapper.increaseReceivedCount(trialId, count);
        }
        return count;
    }

    @Override
    @Transactional
    public Map<String, Object> useTrialCard(Long userId, Long userTrialId, String operatorName)
    {
        return startTrialCard(userId, userTrialId, operatorName);
    }

    @Override
    @Transactional
    public Map<String, Object> startTrialCard(Long userId, Long userTrialId, String operatorName)
    {
        if (userId == null || userId <= 0L)
        {
            throw new ServiceException("用户不存在");
        }
        if (userTrialId == null || userTrialId <= 0L)
        {
            throw new ServiceException("体验卡ID不能为空");
        }

        Date now = new Date();
        SysUser user = userMapper.selectUserBaseByIdForUpdate(userId);
        if (user == null)
        {
            throw new ServiceException("用户不存在");
        }
        int currentUserLevel = resolveUserLevel(user);

        Map<String, Object> activeTrialCard = cardPackageMapper.selectActiveTrialCardByUserIdForUpdate(userId);
        if (activeTrialCard != null && !activeTrialCard.isEmpty())
        {
            Long activeUserTrialId = parseLong(activeTrialCard.get("user_trial_id"), 0L);
            Date activeEndTime = toDate(activeTrialCard.get("end_time"));
            if (activeEndTime != null && !activeEndTime.after(now))
            {
                expireTrialCard(activeTrialCard, now, operatorName);
                activeTrialCard = null;
            }
            else if (activeUserTrialId != null && activeUserTrialId.longValue() == userTrialId.longValue())
            {
                return buildTrialCardResult(cardPackageMapper.selectTrialCardByIdForUpdate(userTrialId));
            }
            else
            {
                throw new ServiceException("当前已有使用中的体验卡，请先等待到期");
            }
        }

        Map<String, Object> trialCard = cardPackageMapper.selectTrialCardByIdForUpdate(userTrialId);
        if (trialCard == null || trialCard.isEmpty())
        {
            throw new ServiceException("体验卡不存在");
        }
        Long cardUserId = parseLong(trialCard.get("user_id"), 0L);
        if (cardUserId == null || !cardUserId.equals(userId))
        {
            throw new ServiceException("该体验卡不属于当前用户");
        }

        String status = String.valueOf(trialCard.get("status"));
        if ("1".equals(status))
        {
            Date endTime = toDate(trialCard.get("end_time"));
            if (endTime != null && endTime.after(now))
            {
                return buildTrialCardResult(trialCard);
            }
            expireTrialCard(trialCard, now, operatorName);
            throw new ServiceException("当前体验卡已到期，请刷新后重试");
        }
        if (!"0".equals(status))
        {
            throw new ServiceException("当前体验卡不可使用");
        }

        SysLevelTrialTemplate template = trialTemplateMapper.selectLevelTrialTemplateById(parseLong(trialCard.get("trial_id"), 0L));
        if (template == null)
        {
            throw new ServiceException("体验卡模板不存在");
        }
        String templateWindowMessage = validateTemplateStartWindow(template, now);
        if (templateWindowMessage != null)
        {
            throw new ServiceException(templateWindowMessage);
        }

        Integer currentLevel = template.getTrialLevel();
        Integer validDays = template.getValidDays();
        if (currentLevel == null || currentLevel <= 0)
        {
            throw new ServiceException("体验卡等级配置异常");
        }
        if (validDays == null || validDays <= 0)
        {
            throw new ServiceException("体验卡有效期配置异常");
        }

        Date endTime = new Date(now.getTime() + validDays.longValue() * 24L * 60L * 60L * 1000L);
        int updated = cardPackageMapper.updateTrialCardUse(userTrialId, currentUserLevel, currentLevel, now, endTime, operatorName, "体验卡使用中");
        if (updated <= 0)
        {
            throw new ServiceException("体验卡使用失败，请稍后重试");
        }

        userMapper.updateUserLevelValue(userId, currentLevel);
        userApiService.evictUserCache(userId);

        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("userTrialId", userTrialId);
        result.put("trialId", template.getTrialId());
        result.put("cardId", template.getTrialId());
        result.put("originalLevel", currentUserLevel);
        result.put("currentLevel", currentLevel);
        result.put("status", "1");
        result.put("isUsing", 1);
        result.put("startTime", now);
        result.put("endTime", endTime);
        result.put("remainingSeconds", calcRemainingSeconds(endTime));
        result.put("cardName", template.getTrialName());
        return result;
    }

    @Override
    @Transactional
    public Map<String, Object> endTrialCard(Long userId, Long userTrialId, String operatorName)
    {
        if (userId == null || userId <= 0L)
        {
            throw new ServiceException("用户不存在");
        }
        if (userTrialId == null || userTrialId <= 0L)
        {
            throw new ServiceException("体验卡ID不能为空");
        }

        Date now = new Date();
        SysUser user = userMapper.selectUserBaseByIdForUpdate(userId);
        if (user == null)
        {
            throw new ServiceException("用户不存在");
        }

        Map<String, Object> trialCard = cardPackageMapper.selectTrialCardByIdForUpdate(userTrialId);
        if (trialCard == null || trialCard.isEmpty())
        {
            throw new ServiceException("体验卡不存在");
        }

        Long cardUserId = parseLong(trialCard.get("user_id"), 0L);
        if (cardUserId == null || !cardUserId.equals(userId))
        {
            throw new ServiceException("该体验卡不属于当前用户");
        }

        String status = String.valueOf(trialCard.get("status"));
        if (!"1".equals(status))
        {
            throw new ServiceException("当前体验卡未处于使用中");
        }

        Date endTime = toDate(trialCard.get("end_time"));
        if (endTime != null && !endTime.after(now))
        {
            expireTrialCard(trialCard, now, operatorName);
            throw new ServiceException("当前体验卡已到期，请刷新后查看");
        }

        Integer originalLevel = parseInt(trialCard.get("original_level"), null);
        if (originalLevel != null)
        {
            userMapper.updateUserLevelValue(userId, originalLevel);
            userApiService.evictUserCache(userId);
        }

        cardPackageMapper.updateTrialCardExpired(userTrialId, operatorName, "用户手动结束体验卡");

        Map<String, Object> result = buildTrialCardResult(cardPackageMapper.selectTrialCardByIdForUpdate(userTrialId));
        result.put("status", "2");
        result.put("isUsing", 0);
        result.put("remainingSeconds", 0);
        return result;
    }

    @Override
    @Transactional
    public int expireDueTrialCards()
    {
        Date now = new Date();
        int total = 0;

        List<Map<String, Object>> expiredActiveCards = cardPackageMapper.selectExpiredTrialCards(now, 200);
        for (Map<String, Object> trialCard : expiredActiveCards)
        {
            expireTrialCard(trialCard, now, "SYSTEM");
            total++;
        }

        List<Map<String, Object>> expiredUnstartedCards = cardPackageMapper.selectExpiredUnstartedTrialCards(now, 200);
        for (Map<String, Object> trialCard : expiredUnstartedCards)
        {
            if (trialCard == null || trialCard.isEmpty())
            {
                continue;
            }
            Long userTrialId = parseLong(trialCard.get("userTrialId"), 0L);
            if (userTrialId == null || userTrialId <= 0L)
            {
                userTrialId = parseLong(trialCard.get("user_trial_id"), 0L);
            }
            if (userTrialId == null || userTrialId <= 0L)
            {
                continue;
            }
            cardPackageMapper.updateTrialCardExpired(userTrialId, "SYSTEM", "体验卡模板到期");
            total++;
        }

        return total;
    }

    private String validateTemplateStartWindow(SysLevelTrialTemplate template, Date now)
    {
        if (template == null || now == null)
        {
            return "体验卡模板不存在";
        }
        if (!"0".equals(String.valueOf(template.getStatus())))
        {
            return "体验卡模板已停用";
        }
        Date startTime = template.getValidStartTime();
        if (startTime != null && startTime.after(now))
        {
            return "体验卡未到启用时间";
        }
        Date endTime = template.getValidEndTime();
        if (endTime != null && !endTime.after(now))
        {
            return "体验卡已过启用时间";
        }
        return null;
    }

    private void expireTrialCard(Map<String, Object> trialCard, Date now, String operatorName)
    {
        if (trialCard == null || trialCard.isEmpty())
        {
            return;
        }
        Long userTrialId = parseLong(trialCard.get("user_trial_id"), 0L);
        Long userId = parseLong(trialCard.get("user_id"), 0L);
        Integer originalLevel = parseInt(trialCard.get("original_level"), null);
        Integer currentLevel = parseInt(trialCard.get("current_level"), null);
        if (userTrialId == null || userTrialId <= 0L)
        {
            return;
        }

        SysUser user = userId == null || userId <= 0L ? null : userMapper.selectUserBaseByIdForUpdate(userId);
        boolean hasOtherActiveTrialCard = false;
        if (userId != null && userId > 0L)
        {
            List<Map<String, Object>> activeTrialCards = cardPackageMapper.selectActiveTrialCardsByUserIdForUpdate(userId, userTrialId);
            hasOtherActiveTrialCard = activeTrialCards != null && !activeTrialCards.isEmpty();
        }

        if (user != null && !hasOtherActiveTrialCard)
        {
            int liveLevel = resolveUserLevel(user);
            if (currentLevel != null && liveLevel == currentLevel.intValue() && originalLevel != null)
            {
                userMapper.updateUserLevelValue(userId, originalLevel);
                userApiService.evictUserCache(userId);
            }
        }

        cardPackageMapper.updateTrialCardExpired(userTrialId, operatorName, "体验卡到期");
    }

    private Map<String, Object> buildTrialCardResult(Map<String, Object> row)
    {
        Map<String, Object> result = new LinkedHashMap<String, Object>();
        if (row == null)
        {
            return result;
        }
        result.put("userTrialId", row.get("user_trial_id"));
        result.put("trialId", row.get("trial_id"));
        result.put("cardId", row.get("trial_id"));
        result.put("originalLevel", row.get("original_level"));
        result.put("currentLevel", row.get("current_level"));
        result.put("status", row.get("status"));
        result.put("isUsing", "1".equals(String.valueOf(row.get("status"))) ? 1 : 0);
        result.put("startTime", row.get("start_time"));
        result.put("endTime", row.get("end_time"));
        result.put("remainingSeconds", calcRemainingSeconds(toDate(row.get("end_time"))));
        result.put("cardName", row.get("card_name"));
        return result;
    }

    private int calcRemainingSeconds(Date endTime)
    {
        if (endTime == null)
        {
            return 0;
        }
        long diff = endTime.getTime() - System.currentTimeMillis();
        if (diff <= 0L)
        {
            return 0;
        }
        return (int) (diff / 1000L);
    }

    private Date toDate(Object value)
    {
        if (value == null)
        {
            return null;
        }
        if (value instanceof Date date)
        {
            return date;
        }
        if (value instanceof LocalDateTime localDateTime)
        {
            return Date.from(localDateTime.atZone(ZoneId.systemDefault()).toInstant());
        }
        if (value instanceof Number number)
        {
            long time = number.longValue();
            if (time > 0L)
            {
                return new Date(time);
            }
            return null;
        }
        String text = String.valueOf(value).trim();
        if (StringUtils.isEmpty(text))
        {
            return null;
        }
        try
        {
            return Date.from(LocalDateTime.parse(text).atZone(ZoneId.systemDefault()).toInstant());
        }
        catch (Exception e)
        {
            try
            {
                return new Date(Long.parseLong(text));
            }
            catch (Exception ignored)
            {
                return null;
            }
        }
    }

    private int resolveUserLevel(SysUser user)
    {
        if (user == null)
        {
            return 0;
        }
        Integer level = user.getLevel();
        if (level != null && level > 0)
        {
            return level;
        }
        Integer userLevel = user.getUserLevel();
        return userLevel == null ? 0 : userLevel;
    }

    private Long parseLong(Object value, Long defaultValue)
    {
        if (value == null)
        {
            return defaultValue;
        }
        try
        {
            String text = String.valueOf(value).trim();
            if (text.isEmpty() || "null".equalsIgnoreCase(text))
            {
                return defaultValue;
            }
            return Long.valueOf(text);
        }
        catch (Exception e)
        {
            return defaultValue;
        }
    }

    private Integer parseInt(Object value, Integer defaultValue)
    {
        if (value == null)
        {
            return defaultValue;
        }
        try
        {
            String text = String.valueOf(value).trim();
            if (text.isEmpty() || "null".equalsIgnoreCase(text))
            {
                return defaultValue;
            }
            return Integer.valueOf(text);
        }
        catch (Exception e)
        {
            return defaultValue;
        }
    }
}
