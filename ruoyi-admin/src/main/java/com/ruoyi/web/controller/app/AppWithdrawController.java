package com.ruoyi.web.controller.app;

import java.util.Date;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.security.crypto.ApiCryptoService;
import com.ruoyi.system.domain.SysUserWithdraw;
import com.ruoyi.system.service.ISysUserWithdrawService;
import tools.jackson.databind.ObjectMapper;

/**
 * APP withdraw entry.
 */
@RestController
@RequestMapping("/app/withdraw")
public class AppWithdrawController extends BaseController
{
    @Autowired
    private ISysUserWithdrawService withdrawService;

    @Autowired
    private ApiCryptoService apiCryptoService;

    @Autowired
    private ObjectMapper objectMapper;

    @PostMapping("/submit")
    @Log(title = "提现申请", businessType = BusinessType.INSERT)
    public AjaxResult submit(@RequestBody(required = false) Map<String, Object> bodyMap)
    {
        SysUserWithdraw withdraw = resolveWithdrawBody(bodyMap);
        withdraw.setUserId(getUserId());
        withdraw.setUserName(getUsername());
        return toAjax(withdrawService.insertWithdraw(withdraw));
    }

    @GetMapping("/list")
    public TableDataInfo list(SysUserWithdraw withdraw)
    {
        startPage();
        withdraw.setUserId(getUserId());
        List<SysUserWithdraw> list = withdrawService.selectWithdrawList(withdraw);
        return getDataTable(list);
    }

    private SysUserWithdraw resolveWithdrawBody(Map<String, Object> bodyMap)
    {
        if (bodyMap == null || bodyMap.isEmpty())
        {
            return new SysUserWithdraw();
        }

        Object encryptedData = bodyMap.get("data");
        if (encryptedData instanceof String encryptedText && StringUtils.isNotBlank(encryptedText))
        {
            try
            {
                String plainJson = apiCryptoService.decryptText(encryptedText);
                return objectMapper.readValue(plainJson, SysUserWithdraw.class);
            }
            catch (Exception e)
            {
                throw new RuntimeException("提现请求解密失败", e);
            }
        }

        SysUserWithdraw withdraw = new SysUserWithdraw();
        withdraw.setAmount(parseAmount(bodyMap));
        withdraw.setCurrencyType(readString(bodyMap, "currencyType", "currency_type"));
        withdraw.setWithdrawMethod(readString(bodyMap, "withdrawMethod", "withdraw_method"));
        withdraw.setBankCardId(parseLong(bodyMap.get("bankCardId")));
        withdraw.setRequestNo(readString(bodyMap, "requestNo", "request_no"));
        withdraw.setOrderNo(readString(bodyMap, "orderNo", "order_no"));
        withdraw.setRemark(readString(bodyMap, "remark"));
        return withdraw;
    }

    private Double parseAmount(Map<String, Object> bodyMap)
    {
        Object[] keys = new Object[] { "amount", "withdrawAmount", "money" };
        for (Object key : keys)
        {
            Object value = bodyMap.get(String.valueOf(key));
            Double parsed = parseDouble(value);
            if (parsed != null)
            {
                return parsed;
            }
        }
        return null;
    }

    private Double parseDouble(Object value)
    {
        if (value == null)
        {
            return null;
        }
        String raw = value.toString().trim().replace(",", "");
        if (StringUtils.isEmpty(raw))
        {
            return null;
        }
        try
        {
            return Double.valueOf(raw);
        }
        catch (Exception ignored)
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
        String raw = value.toString().trim();
        if (StringUtils.isEmpty(raw))
        {
            return null;
        }
        try
        {
            return Long.valueOf(raw);
        }
        catch (Exception ignored)
        {
            return null;
        }
    }

    private String readString(Map<String, Object> bodyMap, String... keys)
    {
        if (bodyMap == null || keys == null)
        {
            return null;
        }
        for (String key : keys)
        {
            Object value = bodyMap.get(key);
            if (value != null)
            {
                String text = value.toString().trim();
                if (StringUtils.isNotEmpty(text))
                {
                    return text;
                }
            }
        }
        return null;
    }
}
