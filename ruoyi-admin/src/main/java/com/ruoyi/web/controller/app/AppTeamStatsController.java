package com.ruoyi.web.controller.app;

import java.math.BigDecimal;
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
import com.ruoyi.system.domain.SysTeamStatUser;
import com.ruoyi.system.service.ISysTeamStatService;
import com.ruoyi.system.service.ISysUserService;

@RestController
@RequestMapping("/app/team/stats")
public class AppTeamStatsController
{
    @Autowired
    private ISysTeamStatService teamStatService;

    @Autowired
    private ISysUserService userService;

    @GetMapping("/me")
    public AjaxResult me()
    {
        Long userId = SecurityUtils.getUserId();
        SysUser user = userService.selectUserBaseById(userId);

        SysTeamStatUser query = new SysTeamStatUser();
        query.setUserId(userId);
        List<SysTeamStatUser> list = teamStatService.selectTeamStatUserList(query);
        SysTeamStatUser stat = list == null || list.isEmpty() ? null : list.get(0);

        int directTotal = stat == null || stat.getDirectUserCount() == null ? 0 : stat.getDirectUserCount();
        int directValid = stat == null || stat.getDirectValidUserCount() == null ? 0 : stat.getDirectValidUserCount();
        int teamTotal = stat == null || stat.getTeamUserCount() == null ? 0 : stat.getTeamUserCount();
        int teamValid = stat == null || stat.getTeamValidUserCount() == null ? 0 : stat.getTeamValidUserCount();
        double directValidRate = directTotal <= 0 ? 0D : (double) directValid / (double) directTotal;
        double teamValidRate = teamTotal <= 0 ? 0D : (double) teamValid / (double) teamTotal;

        Map<String, Object> data = new HashMap<String, Object>();
        data.put("userId", userId);
        data.put("inviteCode", user == null ? "" : user.getInviteCode());
        data.put("userLevel", user == null || user.getLevel() == null ? 0 : user.getLevel());
        data.put("teamLeaderLevel", user == null || user.getTeamLeaderLevel() == null ? 0 : user.getTeamLeaderLevel());
        data.put("totalAsset", stat == null || stat.getTeamTotalAsset() == null ? BigDecimal.ZERO : stat.getTeamTotalAsset());
        data.put("totalIncome", stat == null || stat.getTeamTotalInvest() == null ? BigDecimal.ZERO : stat.getTeamTotalInvest());
        data.put("directTotalCount", directTotal);
        data.put("directValidCount", directValid);
        data.put("directValidRate", directValidRate);
        data.put("teamTotalCount", teamTotal);
        data.put("teamValidCount", teamValid);
        data.put("teamValidRate", teamValidRate);
        data.put("calcDate", stat == null ? null : stat.getCalcDate());
        return AjaxResult.success(data);
    }
}
