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
import com.ruoyi.system.domain.SysUserRecharge;
import com.ruoyi.system.service.ISysUserRechargeService;

/**
 * User recharge management.
 */
@RestController
@RequestMapping("/system/recharge")
public class SysUserRechargeController extends BaseController
{
    @Autowired
    private ISysUserRechargeService rechargeService;

    @GetMapping("/list")
    @PreAuthorize("@ss.hasPermi('operation:recharge:list')")
    public TableDataInfo list(SysUserRecharge recharge)
    {
        startPage();
        List<SysUserRecharge> list = rechargeService.selectRechargeList(recharge);
        return getDataTable(list);
    }

    @GetMapping("/{rechargeId}")
    @PreAuthorize("@ss.hasPermi('operation:recharge:list')")
    public AjaxResult getInfo(@PathVariable Long rechargeId)
    {
        return success(rechargeService.selectRechargeById(rechargeId));
    }

    @PutMapping
    @PreAuthorize("@ss.hasPermi('operation:recharge:edit')")
    @Log(title = "User recharge review", businessType = BusinessType.UPDATE)
    public AjaxResult audit(@RequestBody SysUserRecharge recharge)
    {
        recharge.setReviewTime(new Date());
        recharge.setReviewUserId(SecurityUtils.getUserId());
        recharge.setReviewUserName(SecurityUtils.getUsername());
        return toAjax(rechargeService.reviewRecharge(recharge));
    }

    @DeleteMapping("/{rechargeIds}")
    @PreAuthorize("@ss.hasPermi('operation:recharge:remove')")
    @Log(title = "User recharge delete", businessType = BusinessType.DELETE)
    public AjaxResult remove(@PathVariable Long[] rechargeIds)
    {
        return toAjax(rechargeService.deleteRechargeByIds(rechargeIds));
    }
}
