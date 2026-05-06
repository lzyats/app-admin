package com.ruoyi.quartz.task;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.ruoyi.system.service.ISysLevelTrialTemplateService;

@Component("levelTrialTask")
public class LevelTrialTask
{
    @Autowired
    private ISysLevelTrialTemplateService levelTrialTemplateService;

    public void expireTrialCards()
    {
        levelTrialTemplateService.expireDueTrialCards();
    }
}
