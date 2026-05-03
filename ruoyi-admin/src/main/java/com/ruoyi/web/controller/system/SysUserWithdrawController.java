package com.ruoyi.web.controller.system;

import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.domain.SysUserWithdraw;
import com.ruoyi.system.service.ISysUserWithdrawService;

/**
 * User withdraw management.
 */
@RestController
@RequestMapping("/system/withdraw")
public class SysUserWithdrawController extends BaseController
{
    @Autowired
    private ISysUserWithdrawService withdrawService;

    @GetMapping("/list")
    @PreAuthorize("@ss.hasPermi('operation:withdraw:list')")
    public TableDataInfo list(SysUserWithdraw withdraw)
    {
        startPage();
        List<SysUserWithdraw> list = withdrawService.selectWithdrawList(withdraw);
        return getDataTable(list);
    }

    @GetMapping("/{withdrawId}")
    @PreAuthorize("@ss.hasPermi('operation:withdraw:list')")
    public AjaxResult getInfo(@PathVariable Long withdrawId)
    {
        return success(withdrawService.selectWithdrawById(withdrawId));
    }

    @PutMapping
    @PreAuthorize("@ss.hasPermi('operation:withdraw:edit')")
    @Log(title = "提现审核", businessType = BusinessType.UPDATE)
    public AjaxResult audit(@RequestBody SysUserWithdraw withdraw)
    {
        withdraw.setReviewTime(new Date());
        withdraw.setReviewUserId(SecurityUtils.getUserId());
        withdraw.setReviewUserName(SecurityUtils.getUsername());
        return toAjax(withdrawService.reviewWithdraw(withdraw));
    }

    @DeleteMapping("/{withdrawIds}")
    @PreAuthorize("@ss.hasPermi('operation:withdraw:remove')")
    @Log(title = "提现删除", businessType = BusinessType.DELETE)
    public AjaxResult remove(@PathVariable Long[] withdrawIds)
    {
        return toAjax(withdrawService.deleteWithdrawByIds(withdrawIds));
    }
}
