package com.ruoyi.web.controller.app;

import java.util.Collections;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.security.crypto.ApiCryptoService;
import com.ruoyi.system.service.ISysYebaoOrderService;
import com.ruoyi.system.service.ISysUserService;
import tools.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/app/yebao")
public class AppYebaoController extends BaseController
{
    private static final String PURCHASE_LOCK_KEY = "app:yebao:purchase:lock:";
    private static final String PURCHASE_RESULT_KEY = "app:yebao:purchase:result:";

    @Autowired
    private ISysYebaoOrderService yebaoOrderService;

    @Autowired
    private ApiCryptoService apiCryptoService;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    @Autowired
    private ISysUserService userService;

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
        String clientReqNo = resolveClientReqNo(payload);
        if (shares == null || shares <= 0)
        {
            throw new ServiceException("购买份数不能为空");
        }
        String payPwd = resolvePayPwd(payload);
        validatePayPassword(userId, payPwd);
        if (clientReqNo == null || clientReqNo.trim().isEmpty())
        {
            throw new ServiceException("请求流水不能为空");
        }
        String reqNo = clientReqNo.trim();
        String lockKey = PURCHASE_LOCK_KEY + userId + ":" + reqNo;
        String resultKey = PURCHASE_RESULT_KEY + userId + ":" + reqNo;
        String cached = stringRedisTemplate.opsForValue().get(resultKey);
        if (cached != null && !cached.trim().isEmpty())
        {
            return success(parseInt(cached));
        }
        Boolean locked = stringRedisTemplate.opsForValue().setIfAbsent(lockKey, "1", 10, TimeUnit.SECONDS);
        if (locked == null || !locked)
        {
            throw new ServiceException("订单提交处理中，请勿重复提交");
        }
        try
        {
            int rows = yebaoOrderService.purchase(userId, shares, null, reqNo);
            stringRedisTemplate.opsForValue().set(resultKey, String.valueOf(rows), 10, TimeUnit.MINUTES);
            return success(rows);
        }
        finally
        {
            stringRedisTemplate.delete(lockKey);
        }
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

    private String resolveClientReqNo(Map<String, Object> body)
    {
        Object reqNo = body.get("clientReqNo");
        if (reqNo == null)
        {
            reqNo = body.get("client_req_no");
        }
        if (reqNo == null)
        {
            reqNo = body.get("requestNo");
        }
        return reqNo == null ? null : reqNo.toString().trim();
    }

    private String resolvePayPwd(Map<String, Object> body)
    {
        Object value = body.get("payPwd");
        if (value == null)
        {
            value = body.get("payPassword");
        }
        if (value == null)
        {
            value = body.get("password");
        }
        return value == null ? null : value.toString().trim();
    }

    private void validatePayPassword(Long userId, String payPwd)
    {
        SysUser user = userService.selectUserById(userId);
        if (user == null)
        {
            throw new ServiceException("用户不存在");
        }
        if (StringUtils.isBlank(user.getPayPassword()))
        {
            throw new ServiceException("支付密码未设置");
        }
        if (StringUtils.isBlank(payPwd) || !SecurityUtils.matchesPassword(payPwd, user.getPayPassword()))
        {
            throw new ServiceException("支付密码错误");
        }
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
