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
import com.ruoyi.system.domain.SysInvestProduct;
import com.ruoyi.system.service.ISysInvestProductService;

@RestController
@RequestMapping("/system/invest/product")
public class SysInvestProductController extends BaseController
{
    @Autowired
    private ISysInvestProductService productService;

    @PreAuthorize("@ss.hasPermi('system:invest:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysInvestProduct product)
    {
        startPage();
        List<SysInvestProduct> list = productService.selectInvestProductList(product);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('system:invest:list')")
    @GetMapping("/{productId}")
    public AjaxResult getInfo(@PathVariable Long productId)
    {
        return success(productService.selectInvestProductById(productId));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:add')")
    @Log(title = "投资产品", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysInvestProduct product)
    {
        product.setCreateBy(getUsername());
        return toAjax(productService.insertInvestProduct(product));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:edit')")
    @Log(title = "投资产品", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysInvestProduct product)
    {
        product.setUpdateBy(getUsername());
        return toAjax(productService.updateInvestProduct(product));
    }

    @PreAuthorize("@ss.hasPermi('system:invest:remove')")
    @Log(title = "投资产品", businessType = BusinessType.DELETE)
    @DeleteMapping("/{productIds}")
    public AjaxResult remove(@PathVariable Long[] productIds)
    {
        return toAjax(productService.deleteInvestProductByIds(productIds));
    }
}
