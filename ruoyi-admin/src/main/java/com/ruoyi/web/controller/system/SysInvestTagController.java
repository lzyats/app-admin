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
import com.ruoyi.system.domain.SysInvestTag;
import com.ruoyi.system.service.ISysInvestTagService;

@RestController
@RequestMapping("/system/invest/tag")
public class SysInvestTagController extends BaseController
{
    @Autowired
    private ISysInvestTagService investTagService;

    @PreAuthorize("@ss.hasPermi('system:invest:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysInvestTag tag)
    {
        startPage();
        List<SysInvestTag> list = investTagService.selectInvestTagList(tag);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('system:invest:list')")
    @GetMapping("/{tagId}")
    public AjaxResult getInfo(@PathVariable Long tagId)
    {
        return success(investTagService.selectInvestTagById(tagId));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:add')")
    @Log(title = "投资产品标签", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysInvestTag tag)
    {
        tag.setCreateBy(getUsername());
        return toAjax(investTagService.insertInvestTag(tag));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:edit')")
    @Log(title = "投资产品标签", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysInvestTag tag)
    {
        tag.setUpdateBy(getUsername());
        return toAjax(investTagService.updateInvestTag(tag));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:remove')")
    @Log(title = "投资产品标签", businessType = BusinessType.DELETE)
    @DeleteMapping("/{tagIds}")
    public AjaxResult remove(@PathVariable Long[] tagIds)
    {
        return toAjax(investTagService.deleteInvestTagByIds(tagIds));
    }
}
