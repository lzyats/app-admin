package com.ruoyi.web.controller.app;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUserPointAccount;
import com.ruoyi.common.core.domain.entity.SysUserPointLog;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.system.service.ISysUserPointLogService;
import com.ruoyi.system.service.ISysUserPointService;

/**
 * APP 积分入口
 */
@RestController
@RequestMapping("/app/point")
public class AppPointController extends BaseController {
    @Autowired
    private ISysUserPointService pointService;

    @Autowired
    private ISysUserPointLogService pointLogService;

    @GetMapping("/account")
    public AjaxResult account() {
        SysUserPointAccount account = pointService.ensurePointAccount(getUserId(), getUsername());
        return AjaxResult.success(account);
    }

    @GetMapping("/log/list")
    public TableDataInfo logList(SysUserPointLog pointLog) {
        startPage();
        pointLog.setUserId(getUserId());
        List<SysUserPointLog> list = pointLogService.selectPointLogList(pointLog);
        return getDataTable(list);
    }
}
