package com.ruoyi.web.controller.app;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
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
import com.ruoyi.system.domain.SysUserBankCard;
import com.ruoyi.system.service.ISysUserBankCardService;
import tools.jackson.databind.ObjectMapper;

/**
 * APP bank card entry.
 */
@RestController
@RequestMapping("/app/bankCard")
public class AppBankCardController extends BaseController
{
    @Autowired
    private ISysUserBankCardService bankCardService;

    @Autowired
    private ApiCryptoService apiCryptoService;

    @Autowired
    private ObjectMapper objectMapper;

    @GetMapping("/list")
    public TableDataInfo list(SysUserBankCard bankCard)
    {
        startPage();
        bankCard.setUserId(getUserId());
        List<SysUserBankCard> list = bankCardService.selectBankCardList(bankCard);
        return getDataTable(list);
    }

    @PostMapping
    @Log(title = "Bank card bind", businessType = BusinessType.INSERT)
    public AjaxResult add(@RequestBody(required = false) Map<String, Object> bodyMap)
    {
        SysUserBankCard bankCard = resolveBankCardBody(bodyMap);
        bankCard.setUserId(getUserId());
        bankCard.setUserName(getUsername());
        bankCard.setCreateBy(getUsername());
        bankCard.setUpdateBy(getUsername());
        return toAjax(bankCardService.insertBankCard(bankCard));
    }

    @PostMapping("/delete")
    @Log(title = "Bank card delete", businessType = BusinessType.DELETE)
    public AjaxResult delete(@RequestBody SysUserBankCard bankCard)
    {
        if (bankCard == null || bankCard.getBankCardId() == null)
        {
            return AjaxResult.error("Bank card ID cannot be empty.");
        }
        SysUserBankCard existing = bankCardService.selectBankCardById(bankCard.getBankCardId());
        if (existing == null || !getUserId().equals(existing.getUserId()))
        {
            return AjaxResult.error("Bank card does not exist.");
        }
        return toAjax(bankCardService.deleteBankCardById(bankCard.getBankCardId()));
    }

    private SysUserBankCard resolveBankCardBody(Map<String, Object> bodyMap)
    {
        if (bodyMap == null || bodyMap.isEmpty())
        {
            return new SysUserBankCard();
        }

        Object encryptedData = bodyMap.get("data");
        if (encryptedData instanceof String encryptedText && StringUtils.isNotBlank(encryptedText))
        {
            try
            {
                String plainJson = apiCryptoService.decryptText(encryptedText);
                return objectMapper.readValue(plainJson, SysUserBankCard.class);
            }
            catch (Exception e)
            {
                throw new RuntimeException("银行卡请求解密失败", e);
            }
        }

        Map<String, Object> normalized = new HashMap<>();
        normalized.put("bankCardId", firstNonNull(bodyMap, "bankCardId", "bank_card_id"));
        normalized.put("userId", firstNonNull(bodyMap, "userId", "user_id"));
        normalized.put("userName", firstNonNull(bodyMap, "userName", "user_name"));
        normalized.put("currencyType", firstNonNull(bodyMap, "currencyType", "currency_type"));
        normalized.put("bankName", firstNonNull(bodyMap, "bankName", "bank_name"));
        normalized.put("accountNo", firstNonNull(bodyMap, "accountNo", "account_no"));
        normalized.put("accountName", firstNonNull(bodyMap, "accountName", "account_name"));
        normalized.put("walletAddress", firstNonNull(bodyMap, "walletAddress", "wallet_address"));
        normalized.put("remark", firstNonNull(bodyMap, "remark"));
        return objectMapper.convertValue(normalized, SysUserBankCard.class);
    }

    private Object firstNonNull(Map<String, Object> bodyMap, String... keys)
    {
        for (String key : keys)
        {
            if (bodyMap.containsKey(key) && bodyMap.get(key) != null)
            {
                return bodyMap.get(key);
            }
        }
        return null;
    }
}
