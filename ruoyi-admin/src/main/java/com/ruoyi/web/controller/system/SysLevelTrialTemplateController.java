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
import com.ruoyi.system.domain.SysLevelTrialTemplate;
import com.ruoyi.system.service.ISysLevelTrialTemplateService;

@RestController
@RequestMapping("/system/invest/trial")
public class SysLevelTrialTemplateController extends BaseController
{
    @Autowired
    private ISysLevelTrialTemplateService trialTemplateService;

    @PreAuthorize("@ss.hasPermi('system:invest:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysLevelTrialTemplate template)
    {
        startPage();
        List<SysLevelTrialTemplate> list = trialTemplateService.selectLevelTrialTemplateList(template);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('system:invest:list')")
    @GetMapping("/{trialId}")
    public AjaxResult getInfo(@PathVariable Long trialId)
    {
        return success(trialTemplateService.selectLevelTrialTemplateById(trialId));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:add')")
    @Log(title = "等级体验券模板", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysLevelTrialTemplate template)
    {
        template.setCreateBy(getUsername());
        return toAjax(trialTemplateService.insertLevelTrialTemplate(template));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:edit')")
    @Log(title = "等级体验券模板", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysLevelTrialTemplate template)
    {
        template.setUpdateBy(getUsername());
        return toAjax(trialTemplateService.updateLevelTrialTemplate(template));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:remove')")
    @Log(title = "等级体验券模板", businessType = BusinessType.DELETE)
    @DeleteMapping("/{trialIds}")
    public AjaxResult remove(@PathVariable Long[] trialIds)
    {
        return toAjax(trialTemplateService.deleteLevelTrialTemplateByIds(trialIds));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:grant')")
    @Log(title = "等级体验券发放", businessType = BusinessType.UPDATE)
    @PostMapping("/grant")
    public AjaxResult grant(@RequestBody TrialGrantBody body)
    {
        int rows = trialTemplateService.grantTrialToUsers(body.getTrialId(), body.getUserIds(),
            body.getGrantType(), getUsername(), body.getRemark());
        return success("已发放" + rows + "张");
    }

    public static class TrialGrantBody
    {
        private Long trialId;
        private List<Long> userIds;
        private String grantType;
        private String remark;

        public Long getTrialId()
        {
            return trialId;
        }

        public void setTrialId(Long trialId)
        {
            this.trialId = trialId;
        }

        public List<Long> getUserIds()
        {
            return userIds;
        }

        public void setUserIds(List<Long> userIds)
        {
            this.userIds = userIds;
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
