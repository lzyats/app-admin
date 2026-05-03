package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysLevelTrialTemplate;

public interface ISysLevelTrialTemplateService
{
    SysLevelTrialTemplate selectLevelTrialTemplateById(Long trialId);

    List<SysLevelTrialTemplate> selectLevelTrialTemplateList(SysLevelTrialTemplate template);

    int insertLevelTrialTemplate(SysLevelTrialTemplate template);

    int updateLevelTrialTemplate(SysLevelTrialTemplate template);

    int deleteLevelTrialTemplateByIds(Long[] trialIds);

    int grantTrialToUsers(Long trialId, List<Long> userIds, String grantType, String operator, String remark);
}
