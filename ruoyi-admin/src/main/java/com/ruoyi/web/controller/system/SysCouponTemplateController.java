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
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
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

    @PreAuthorize("@ss.hasPermi('system:invest:list')")
    @GetMapping("/{couponId}")
    public AjaxResult getInfo(@PathVariable Long couponId)
    {
        return success(couponTemplateService.selectCouponTemplateById(couponId));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:add')")
    @Log(title = "优惠券模板", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysCouponTemplate template)
    {
        template.setCreateBy(getUsername());
        return toAjax(couponTemplateService.insertCouponTemplate(template));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:edit')")
    @Log(title = "优惠券模板", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysCouponTemplate template)
    {
        template.setUpdateBy(getUsername());
        return toAjax(couponTemplateService.updateCouponTemplate(template));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:remove')")
    @Log(title = "优惠券模板", businessType = BusinessType.DELETE)
    @DeleteMapping("/{couponIds}")
    public AjaxResult remove(@PathVariable Long[] couponIds)
    {
        return toAjax(couponTemplateService.deleteCouponTemplateByIds(couponIds));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:grant')")
    @Log(title = "优惠券发放", businessType = BusinessType.UPDATE)
    @PostMapping("/grant")
    public AjaxResult grant(@RequestBody CouponGrantBody body)
    {
        int rows = couponTemplateService.grantCouponToUsers(body.getCouponId(), body.getUserIds(), body.getLevel(),
            body.getGrantType(), getUsername(), body.getRemark());
        return success("已发放" + rows + "张");
    }

    public static class CouponGrantBody
    {
        private Long couponId;
        private List<Long> userIds;
        private Integer level;
        private String grantType;
        private String remark;

        public Long getCouponId()
        {
            return couponId;
        }

        public void setCouponId(Long couponId)
        {
            this.couponId = couponId;
        }

        public List<Long> getUserIds()
        {
            return userIds;
        }

        public void setUserIds(List<Long> userIds)
        {
            this.userIds = userIds;
        }

        public Integer getLevel()
        {
            return level;
        }

        public void setLevel(Integer level)
        {
            this.level = level;
        }

        public String getGrantType()
        {
            return grantType;
        }

        public void setGrantType(String grantType)
        {
            this.grantType = grantType;
        }

        public String getRemark()
        {
            return remark;
        }

        public void setRemark(String remark)
        {
            this.remark = remark;
        }
    }
}
