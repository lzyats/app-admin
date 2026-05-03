package com.ruoyi.quartz.task;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.ruoyi.system.service.ISysMinerRunService;

@Component("minerTask")
public class MinerTask
{
    @Autowired
    private ISysMinerRunService minerRunService;

    public void settle()
    {
        minerRunService.settleMinerRuns();
    }
}

