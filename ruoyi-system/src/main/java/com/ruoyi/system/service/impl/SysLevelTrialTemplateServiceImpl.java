package com.ruoyi.system.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysLevelTrialTemplate;
import com.ruoyi.system.mapper.SysLevelTrialTemplateMapper;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.service.ISysLevelTrialTemplateService;

@Service
public class SysLevelTrialTemplateServiceImpl implements ISysLevelTrialTemplateService
{
    @Autowired
    private SysLevelTrialTemplateMapper trialTemplateMapper;

    @Autowired
    private SysUserMapper userMapper;

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
            throw new ServiceException("等级体验券模板不存在");
        }
        if (userIds == null || userIds.isEmpty())
        {
            throw new ServiceException("请选择发放用户");
        }
        int count = 0;
        for (Long userId : userIds)
        {
            SysUser user = userMapper.selectUserById(userId);
            if (user == null)
            {
                continue;
            }
            count += trialTemplateMapper.insertUserTrial(trialId, userId, user.getUserName(),
                StringUtils.isBlank(grantType) ? "MANUAL" : grantType, template.getValidDays(), operator, remark);
        }
        return count;
    }
}
