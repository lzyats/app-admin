package com.ruoyi.web.controller.system;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestBody;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.SysTeamLevel;
import com.ruoyi.system.service.ISysTeamLevelService;

@RestController
@RequestMapping("/system/teamLevel")
public class SysTeamLevelController extends BaseController
{
    @Autowired
    private ISysTeamLevelService teamLevelService;

    @PreAuthorize("@ss.hasPermi('system:teamLevel:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysTeamLevel teamLevel)
    {
        startPage();
        List<SysTeamLevel> list = teamLevelService.selectTeamLevelList(teamLevel);
        return getDataTable(list);
    }

    @GetMapping("/{teamLevelId}")
    public AjaxResult getInfo(@PathVariable Long teamLevelId)
    {
        return success(teamLevelService.selectTeamLevelById(teamLevelId));
    }

    @PreAuthorize("@ss.hasPermi('system:teamLevel:add')")
    @Log(title = "团队等级", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysTeamLevel teamLevel)
    {
        teamLevel.setCreateBy(getUsername());
        return toAjax(teamLevelService.insertTeamLevel(teamLevel));
    }

    @PreAuthorize("@ss.hasPermi('system:teamLevel:edit')")
    @Log(title = "团队等级", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysTeamLevel teamLevel)
    {
        teamLevel.setUpdateBy(getUsername());
        return toAjax(teamLevelService.updateTeamLevel(teamLevel));
    }

    @PreAuthorize("@ss.hasPermi('system:teamLevel:remove')")
    @Log(title = "团队等级", businessType = BusinessType.DELETE)
    @DeleteMapping("/{teamLevelIds}")
    public AjaxResult remove(@PathVariable Long[] teamLevelIds)
    {
        return toAjax(teamLevelService.deleteTeamLevelByIds(teamLevelIds));
    }

    @PreAuthorize("@ss.hasPermi('system:teamLevel:edit')")
    @Log(title = "团队等级自动升级校验", businessType = BusinessType.UPDATE)
    @PostMapping("/checkUpgrade")
    public AjaxResult checkUpgrade(@RequestParam("userId") Long userId)
    {
        boolean upgraded = teamLevelService.checkAndUpgradeUserTeamLevel(userId);
        return success(upgraded ? "已升级团队长级别" : "未达到升级条件");
    }
}
