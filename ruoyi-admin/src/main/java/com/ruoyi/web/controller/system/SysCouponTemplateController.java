package com.ruoyi.web.controller.system;

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
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.SysCouponGrantRequest;
import com.ruoyi.system.domain.SysCouponTemplate;
import com.ruoyi.system.service.ISysCouponTemplateService;

@RestController
@RequestMapping("/system/invest/coupon")
public class SysCouponTemplateController extends BaseController
{
    @Autowired
    private ISysCouponTemplateService couponTemplateService;

    @PreAuthorize("@ss.hasPermi('system:invest:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysCouponTemplate template)
    {
        startPage();
        List<SysCouponTemplate> list = couponTemplateService.selectCouponTemplateList(template);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('system:invest:grant')")
    @GetMapping("/audience/list")
    public TableDataInfo audienceList(SysCouponGrantRequest request)
    {
        startPage();
        List<SysUser> list = couponTemplateService.selectCouponAudienceList(request);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('system:invest:list')")
    @GetMapping("/{couponId}")
    public AjaxResult getInfo(@PathVariable Long couponId)
    {
        return success(couponTemplateService.selectCouponTemplateById(couponId));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:add')")
    @Log(title = "优惠券模板管理", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysCouponTemplate template)
    {
        template.setCreateBy(getUsername());
        return toAjax(couponTemplateService.insertCouponTemplate(template));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:edit')")
    @Log(title = "优惠券模板管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysCouponTemplate template)
    {
        template.setUpdateBy(getUsername());
        return toAjax(couponTemplateService.updateCouponTemplate(template));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:remove')")
    @Log(title = "优惠券模板管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{couponIds}")
    public AjaxResult remove(@PathVariable Long[] couponIds)
    {
        return toAjax(couponTemplateService.deleteCouponTemplateByIds(couponIds));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:grant')")
    @Log(title = "优惠券发放", businessType = BusinessType.UPDATE)
    @PostMapping("/grant")
    public AjaxResult grant(@RequestBody SysCouponGrantRequest request)
    {
        if (request.getCouponId() == null || request.getCouponId() <= 0L)
        {
            return AjaxResult.error("模板ID不能为空");
        }
        int rows = couponTemplateService.grantCouponToUsers(request.getCouponId(), request, getUsername());
        return success("已发放 " + rows + " 张");
    }
}