package com.ruoyi.web.controller.system;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.system.domain.SysYebaoOrder;
import com.ruoyi.system.service.ISysYebaoOrderService;

@RestController
@RequestMapping("/system/yebao/order")
public class SysYebaoOrderController extends BaseController
{
    @Autowired
    private ISysYebaoOrderService yebaoOrderService;

    @PreAuthorize("@ss.hasPermi('system:yebao:order:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysYebaoOrder order)
    {
        startPage();
        List<SysYebaoOrder> list = yebaoOrderService.selectYebaoOrderList(order);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('system:yebao:order:query')")
    @GetMapping(value = "/{orderId}")
    public AjaxResult getInfo(@PathVariable Long orderId)
    {
        return success(yebaoOrderService.selectYebaoOrderById(orderId));
    }
}
