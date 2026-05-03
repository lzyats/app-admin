package com.ruoyi.web.controller.system;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Date;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysTeamStatEvent;
import com.ruoyi.system.domain.SysTeamStatUser;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysTeamStatService;

@RestController
@RequestMapping("/system/teamStats")
public class SysTeamStatController extends BaseController
{
    private static final String CONFIG_LAST_CALC_DATE = "team.stats.last.calc.date";

    @Autowired
    private ISysTeamStatService teamStatService;

    @Autowired
    private ISysConfigService configService;

    @PreAuthorize("@ss.hasPermi('system:teamStats:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysTeamStatUser query)
    {
        startPage();
        List<SysTeamStatUser> list = teamStatService.selectTeamStatUserList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('system:teamStats:list')")
    @GetMapping("/event/list")
    public TableDataInfo eventList(SysTeamStatEvent query)
    {
        startPage();
        List<SysTeamStatEvent> list = teamStatService.selectTeamStatEventList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('system:teamStats:list')")
    @GetMapping("/config")
    public AjaxResult config()
    {
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("calcDepth", teamStatService.getCalcDepth());
        data.put("lastCalcDate", configService.selectConfigByKey(CONFIG_LAST_CALC_DATE));
        return success(data);
    }

    @PreAuthorize("@ss.hasPermi('system:teamStats:rebuild')")
    @Log(title = "团队统计重算", businessType = BusinessType.UPDATE)
    @PostMapping("/rebuild")
    public AjaxResult rebuild(@RequestParam(value = "statDate", required = false) String statDate)
    {
        Date targetDate = null;
        if (StringUtils.isNotBlank(statDate))
        {
            targetDate = DateUtils.parseDate(statDate);
        }
        teamStatService.rebuildDailyStats(targetDate);
        return success("团队统计重算完成");
    }
}
