package com.ruoyi.quartz.task;

import java.util.Date;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.ruoyi.system.service.ISysTeamStatService;

@Component("teamStatTask")
public class TeamStatTask
{
    @Autowired
    private ISysTeamStatService teamStatService;

    /**
     * 默认重算昨天的数据
     */
    public void rebuildYesterday()
    {
        teamStatService.rebuildDailyStats(null);
    }

    /**
     * 重算指定日期（yyyy-MM-dd）
     */
    public void rebuildByDate(String statDate)
    {
        Date parsed = com.ruoyi.common.utils.DateUtils.parseDate(statDate);
        teamStatService.rebuildDailyStats(parsed);
    }
}
