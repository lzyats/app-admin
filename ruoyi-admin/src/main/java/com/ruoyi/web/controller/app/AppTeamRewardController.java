package com.ruoyi.web.controller.app;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.SysTeamLevel;
import com.ruoyi.system.service.ISysTeamLevelService;
import com.ruoyi.system.service.ISysUserService;

@RestController
@RequestMapping("/app/team/reward")
public class AppTeamRewardController
{
    @Autowired
    private ISysTeamLevelService teamLevelService;

    @Autowired
    private ISysUserService userService;

    @GetMapping("/info")
    public AjaxResult info()
    {
        Long userId = SecurityUtils.getUserId();
        teamLevelService.checkAndUpgradeUserTeamLevel(userId);
        SysUser user = userService.selectUserBaseById(userId);
        List<SysTeamLevel> rules = teamLevelService.selectEnabledOptionsCached();

        Map<String, Object> data = new HashMap<String, Object>();
        data.put("currentTeamLeaderLevel", user == null || user.getTeamLeaderLevel() == null ? 0 : user.getTeamLeaderLevel());
        data.put("currentUserLevel", user == null || user.getLevel() == null ? 0 : user.getLevel());
        data.put("rules", rules);
        return AjaxResult.success(data);
    }
}
