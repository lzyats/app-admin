package com.ruoyi.web.controller.system;

import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
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
import com.ruoyi.system.domain.SysAppRealNameAuth;
import com.ruoyi.system.service.ISysAppRealNameAuthService;

/**
 * APP实名认证 信息操作处理
 *
 * @author ruoyi
 */
@RestController
@RequestMapping("/system/realNameAuth")
public class SysAppRealNameAuthController extends BaseController
{
    @Autowired
    private ISysAppRealNameAuthService authService;

    @PostMapping
    @PreAuthorize("@ss.hasPermi('system:realNameAuth:add')")
    @Log(title = "实名认证", businessType = BusinessType.INSERT)
    public AjaxResult add(@RequestBody SysAppRealNameAuth auth)
    {
        return toAjax(authService.insertAuth(auth));
    }

    @GetMapping("/list")
    @PreAuthorize("@ss.hasPermi('system:realNameAuth:list')")
    public TableDataInfo list(SysAppRealNameAuth auth)
    {
        startPage();
        List<SysAppRealNameAuth> list = authService.selectAuthList(auth);
        return getDataTable(list);
    }

    @GetMapping(value = "/{authId}")
    @PreAuthorize("@ss.hasPermi('system:realNameAuth:query')")
    public AjaxResult getInfo(@PathVariable Long authId)
    {
        return success(authService.selectAuthById(authId));
    }

    @PutMapping
    @PreAuthorize("@ss.hasPermi('system:realNameAuth:edit')")
    @Log(title = "实名认证审核", businessType = BusinessType.UPDATE)
    public AjaxResult edit(@RequestBody SysAppRealNameAuth auth)
    {
        auth.setReviewTime(new Date());
        auth.setReviewUserId(SecurityUtils.getUserId());
        auth.setReviewUserName(SecurityUtils.getUsername());
        return toAjax(authService.updateAuth(auth));
    }

    @DeleteMapping("/{authIds}")
    @PreAuthorize("@ss.hasPermi('system:realNameAuth:remove')")
    @Log(title = "实名认证", businessType = BusinessType.DELETE)
    public AjaxResult remove(@PathVariable Long[] authIds)
    {
        return toAjax(authService.deleteAuthByIds(authIds));
    }
}