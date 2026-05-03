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
import com.ruoyi.system.domain.SysYebaoConfig;
import com.ruoyi.system.service.ISysYebaoConfigService;

@RestController
@RequestMapping("/system/yebao/config")
public class SysYebaoConfigController extends BaseController
{
    @Autowired
    private ISysYebaoConfigService yebaoConfigService;

    @PreAuthorize("@ss.hasPermi('system:yebao:config:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysYebaoConfig config)
    {
        startPage();
        List<SysYebaoConfig> list = yebaoConfigService.selectYebaoConfigList(config);
        return getDataTable(list);
    }

    @GetMapping(value = "/{configId}")
    public AjaxResult getInfo(@PathVariable Long configId)
    {
        return success(yebaoConfigService.selectYebaoConfigById(configId));
    }

    @PreAuthorize("@ss.hasPermi('system:yebao:config:add')")
    @Log(title = "余额宝配置", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysYebaoConfig config)
    {
        config.setCreateBy(getUsername());
        return toAjax(yebaoConfigService.insertYebaoConfig(config));
    }

    @PreAuthorize("@ss.hasPermi('system:yebao:config:edit')")
    @Log(title = "余额宝配置", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysYebaoConfig config)
    {
        config.setUpdateBy(getUsername());
        return toAjax(yebaoConfigService.updateYebaoConfig(config));
    }

    @PreAuthorize("@ss.hasPermi('system:yebao:config:remove')")
    @Log(title = "余额宝配置", businessType = BusinessType.DELETE)
    @DeleteMapping("/{configIds}")
    public AjaxResult remove(@PathVariable Long[] configIds)
    {
        return toAjax(yebaoConfigService.deleteYebaoConfigByIds(configIds));
    }
}
