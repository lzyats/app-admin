package com.ruoyi.web.controller.system;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.GoogleVerifyRequired;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.service.ISysInvestOrderService;

@RestController
@RequestMapping("/system/invest/order")
public class SysInvestOrderController extends BaseController
{
    @Autowired
    private ISysInvestOrderService investOrderService;

    @PreAuthorize("@ss.hasPermi('system:yebao:order:list')")
    @GetMapping("/list")
    public TableDataInfo list(String orderNo, Long userId, String userName, String productName, String status)
    {
        startPage();
        List<Map<String, Object>> list = investOrderService.selectAdminOrderList(orderNo, userId, userName, productName, status);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('system:yebao:order:query')")
    @GetMapping("/{orderId}")
    public AjaxResult getInfo(@PathVariable Long orderId)
    {
        return success(investOrderService.selectAdminOrderById(orderId));
    }

    @PreAuthorize("@ss.hasPermi('system:yebao:order:query')")
    @GetMapping("/detail/{orderId}")
    public AjaxResult getDetail(@PathVariable Long orderId)
    {
        return success(investOrderService.selectAdminOrderDetail(orderId));
    }

    @PreAuthorize("@ss.hasPermi('system:yebao:order:list')")
    @GoogleVerifyRequired
    @Log(title = "投资订单", businessType = BusinessType.UPDATE)
    @PostMapping("/redeem")
    public AjaxResult redeem(@RequestBody Map<String, Object> body)
    {
        Long orderId = parseLong(body.get("orderId"), 0L);
        String confirmText = String.valueOf(body.get("confirmText"));
        if (orderId == null || orderId <= 0L)
        {
            return AjaxResult.error("订单ID不能为空");
        }
        if (StringUtils.isBlank(confirmText))
        {
            return AjaxResult.error("请输入确认文案");
        }
        return toAjax(investOrderService.redeemByAdmin(orderId, confirmText, getUsername()));
    }

    @PreAuthorize("@ss.hasPermi('system:yebao:order:list')")
    @GoogleVerifyRequired
    @Log(title = "投资订单", businessType = BusinessType.UPDATE)
    @PostMapping("/settle")
    public AjaxResult settle(@RequestBody Map<String, Object> body)
    {
        Long orderId = parseLong(body.get("orderId"), 0L);
        String confirmText = String.valueOf(body.get("confirmText"));
        if (orderId == null || orderId <= 0L)
        {
            return AjaxResult.error("订单ID不能为空");
        }
        if (StringUtils.isBlank(confirmText))
        {
            return AjaxResult.error("请输入确认文案");
        }
        return toAjax(investOrderService.settleByAdmin(orderId, confirmText, getUsername()));
    }

    private Long parseLong(Object value, Long defaultValue)
    {
        if (value == null)
        {
            return defaultValue;
        }
        if (value instanceof Number)
        {
            return ((Number) value).longValue();
        }
        try
        {
            return Long.parseLong(String.valueOf(value).trim());
        }
        catch (Exception e)
        {
            return defaultValue;
        }
    }
}
