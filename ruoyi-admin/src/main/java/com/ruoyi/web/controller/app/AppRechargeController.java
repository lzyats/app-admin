package com.ruoyi.web.controller.app;

import java.util.Map;
import java.util.List;
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
import com.ruoyi.system.domain.SysUserRecharge;
import com.ruoyi.system.service.ISysUserRechargeService;
import tools.jackson.databind.ObjectMapper;

/**
 * APP recharge entry.
 */
@RestController
@RequestMapping("/app/recharge")
public class AppRechargeController extends BaseController
{
    @Autowired
    private ISysUserRechargeService rechargeService;

    @Autowired
    private ApiCryptoService apiCryptoService;

    @Autowired
    private ObjectMapper objectMapper;

    @PostMapping("/submit")
    @Log(title = "User recharge submit", businessType = BusinessType.INSERT)
    public AjaxResult submit(@RequestBody(required = false) Map<String, Object> bodyMap)
    {
        SysUserRecharge recharge = resolveRechargeBody(bodyMap);
        recharge.setUserId(getUserId());
        recharge.setUserName(getUsername());
        return toAjax(rechargeService.insertRecharge(recharge));
    }

    @GetMapping("/list")
    public TableDataInfo list(SysUserRecharge recharge)
    {
        startPage();
        recharge.setUserId(getUserId());
        List<SysUserRecharge> list = rechargeService.selectRechargeList(recharge);
        return getDataTable(list);
    }

    private SysUserRecharge resolveRechargeBody(Map<String, Object> bodyMap)
    {
        if (bodyMap == null || bodyMap.isEmpty())
        {
            return new SysUserRecharge();
        }

        Object encryptedData = bodyMap.get("data");
        if (encryptedData instanceof String encryptedText && StringUtils.isNotBlank(encryptedText))
        {
            try
            {
                String plainJson = apiCryptoService.decryptText(encryptedText);
                return objectMapper.readValue(plainJson, SysUserRecharge.class);
            }
            catch (Exception e)
            {
                throw new RuntimeException("充值请求解密失败", e);
            }
        }

        SysUserRecharge recharge = new SysUserRecharge();
        recharge.setAmount(parseAmount(bodyMap));
        recharge.setCurrencyType(readString(bodyMap, "currencyType", "currency_type"));
        recharge.setRechargeMethod(readString(bodyMap, "rechargeMethod", "recharge_method"));
        recharge.setRemark(readString(bodyMap, "remark"));
        recharge.setOrderNo(readString(bodyMap, "orderNo", "order_no"));
        return recharge;
    }

    private Double parseAmount(Map<String, Object> bodyMap)
    {
        Object[] keys = new Object[] { "amount", "rechargeAmount", "money" };
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
