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
import com.ruoyi.system.domain.SysNewsCategory;
import com.ruoyi.system.service.ISysNewsCategoryService;

@RestController
@RequestMapping("/system/news/category")
public class SysNewsCategoryController extends BaseController
{
    @Autowired
    private ISysNewsCategoryService newsCategoryService;

    @PreAuthorize("@ss.hasPermi('system:news:category:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysNewsCategory category)
    {
        startPage();
        List<SysNewsCategory> list = newsCategoryService.selectNewsCategoryList(category);
        return getDataTable(list);
    }

    @GetMapping("/listAll")
    public AjaxResult listAll()
    {
        return success(newsCategoryService.selectNewsCategoryAll());
    }

    @GetMapping(value = "/{categoryId}")
    public AjaxResult getInfo(@PathVariable Long categoryId)
    {
        return success(newsCategoryService.selectNewsCategoryById(categoryId));
    }

    @PreAuthorize("@ss.hasPermi('system:news:category:add')")
    @Log(title = "新闻分类", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysNewsCategory category)
    {
        category.setCreateBy(getUsername());
        return toAjax(newsCategoryService.insertNewsCategory(category));
    }

    @PreAuthorize("@ss.hasPermi('system:news:category:edit')")
    @Log(title = "新闻分类", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysNewsCategory category)
    {
        category.setUpdateBy(getUsername());
        return toAjax(newsCategoryService.updateNewsCategory(category));
    }

    @PreAuthorize("@ss.hasPermi('system:news:category:remove')")
    @Log(title = "新闻分类", businessType = BusinessType.DELETE)
    @DeleteMapping("/{categoryIds}")
    public AjaxResult remove(@PathVariable Long[] categoryIds)
    {
        return toAjax(newsCategoryService.deleteNewsCategoryByIds(categoryIds));
    }
}
