package com.ruoyi.system.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysLevelTrialTemplate;

public interface SysLevelTrialTemplateMapper
{
    SysLevelTrialTemplate selectLevelTrialTemplateById(Long trialId);

    List<SysLevelTrialTemplate> selectLevelTrialTemplateList(SysLevelTrialTemplate template);

    int insertLevelTrialTemplate(SysLevelTrialTemplate template);

    int updateLevelTrialTemplate(SysLevelTrialTemplate template);

    int deleteLevelTrialTemplateById(Long trialId);

    int deleteLevelTrialTemplateByIds(Long[] trialIds);

    int insertUserTrial(@Param("trialId") Long trialId, @Param("userId") Long userId,
                        @Param("userName") String userName, @Param("grantType") String grantType,
                        @Param("validDays") Integer validDays, @Param("operator") String operator,
                        @Param("remark") String remark);
}
