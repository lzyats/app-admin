package com.ruoyi.web.controller.app;

import java.util.Collections;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.framework.security.crypto.ApiCryptoService;
import com.ruoyi.system.service.ISysYebaoOrderService;
import tools.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/app/yebao")
public class AppYebaoController extends BaseController
{
    @Autowired
    private ISysYebaoOrderService yebaoOrderService;

    @Autowired
    private ApiCryptoService apiCryptoService;

    @Autowired
    private ObjectMapper objectMapper;

    @GetMapping("/my")
    public AjaxResult my()
    {
        Long userId = getLoginUser().getUserId();
        return success(yebaoOrderService.selectAppYebaoDetail(userId));
    }

    @PostMapping("/purchase")
    public AjaxResult purchase(@RequestBody Map<String, Object> body)
    {
        Long userId = getLoginUser().getUserId();
        Map<String, Object> payload = normalizePayload(body);
        Integer shares = resolveShares(payload);
        if (shares == null || shares <= 0)
        {
            throw new ServiceException("购买份数不能为空");
        }
        return success(yebaoOrderService.purchase(userId, shares, null));
    }

    @GetMapping("/orders")
    public AjaxResult orders()
    {
        Long userId = getLoginUser().getUserId();
        return success(yebaoOrderService.selectAppYebaoOrderList(userId));
    }

    @GetMapping("/incomes")
    public AjaxResult incomes()
    {
        Long userId = getLoginUser().getUserId();
        return success(yebaoOrderService.selectAppYebaoIncomeLogList(userId));
    }

    @PostMapping("/redeem")
    public AjaxResult redeem(@RequestBody Map<String, Object> body)
    {
        Long userId = getLoginUser().getUserId();
        Map<String, Object> payload = normalizePayload(body);
        Long orderId = resolveOrderId(payload);
        if (orderId == null || orderId <= 0)
        {
            throw new ServiceException("订单ID不能为空");
        }
        return success(yebaoOrderService.redeem(userId, orderId));
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> normalizePayload(Map<String, Object> body)
    {
        if (body == null || body.isEmpty())
        {
            return Collections.emptyMap();
        }
        Object data = body.get("data");
        if (data instanceof Map)
        {
            return (Map<String, Object>) data;
        }
        if (data != null)
        {
            String text = data.toString().trim();
            if (!text.isEmpty())
            {
                try
                {
                    String plainJson = apiCryptoService.decryptText(text);
                    Map<String, Object> payload = objectMapper.readValue(plainJson, Map.class);
                    if (payload != null)
                    {
                        return payload;
                    }
                }
                catch (Exception ignored)
                {
                }
            }
        }
        return body;
    }

    private Integer resolveShares(Map<String, Object> body)
    {
        Integer shares = parseInt(body.get("shares"));
        if (shares != null)
        {
            return shares;
        }
        shares = parseInt(body.get("share"));
        if (shares != null)
        {
            return shares;
        }
        shares = parseInt(body.get("purchaseShares"));
        if (shares != null)
        {
            return shares;
        }
        return parseInt(body.get("count"));
    }

    private Long resolveOrderId(Map<String, Object> body)
    {
        Long orderId = parseLong(body.get("orderId"));
        if (orderId != null)
        {
            return orderId;
        }
        orderId = parseLong(body.get("order_id"));
        if (orderId != null)
        {
            return orderId;
        }
        return parseLong(body.get("id"));
    }

    private Integer parseInt(Object value)
    {
        if (value == null)
        {
            return null;
        }
        if (value instanceof Number)
        {
            return ((Number) value).intValue();
        }
        try
        {
            return Integer.parseInt(value.toString().trim());
        }
        catch (Exception e)
        {
            return null;
        }
    }

    private Long parseLong(Object value)
    {
        if (value == null)
        {
            return null;
        }
        if (value instanceof Number)
        {
            return ((Number) value).longValue();
        }
        try
        {
            return Long.parseLong(value.toString().trim());
        }
        catch (Exception e)
        {
            return null;
        }
    }
}
