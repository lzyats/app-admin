package com.ruoyi.web.controller.app;

import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.SysUserWithdraw;
import com.ruoyi.system.service.ISysUserWithdrawService;

/**
 * APP withdraw entry.
 */
@RestController
@RequestMapping("/app/withdraw")
public class AppWithdrawController extends BaseController
{
    @Autowired
    private ISysUserWithdrawService withdrawService;

    @PostMapping("/submit")
    @Log(title = "提现申请", businessType = BusinessType.INSERT)
    public AjaxResult submit(@RequestBody SysUserWithdraw withdraw)
    {
        withdraw.setUserId(getUserId());
        withdraw.setUserName(getUsername());
        return toAjax(withdrawService.insertWithdraw(withdraw));
    }

    @GetMapping("/list")
    public TableDataInfo list(SysUserWithdraw withdraw)
    {
        startPage();
        withdraw.setUserId(getUserId());
        List<SysUserWithdraw> list = withdrawService.selectWithdrawList(withdraw);
        return getDataTable(list);
    }
}
