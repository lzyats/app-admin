package com.ruoyi.web.controller.app;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.security.crypto.ApiCryptoService;
import com.ruoyi.system.service.ISysMinerAppService;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/app/miner")
public class AppMinerController extends BaseController
{
    @Autowired
    private ISysMinerAppService minerAppService;

    @Autowired
    private ApiCryptoService apiCryptoService;

    @Autowired
    private ObjectMapper objectMapper;

    @GetMapping("/overview")
    public AjaxResult overview()
    {
        Long userId = SecurityUtils.getUserId();
        return success(minerAppService.getOverview(userId));
    }

    @GetMapping("/available")
    public AjaxResult available()
    {
        Long userId = SecurityUtils.getUserId();
        return success(minerAppService.listAvailableMiners(userId));
    }

    @PostMapping("/claim")
    public AjaxResult claim(@RequestBody(required = false) Map<String, Object> body)
    {
        Map<String, Object> req = resolveBody(body);
        Long minerId = toLong(req.get("minerId"));
        Long userId = SecurityUtils.getUserId();
        return success(minerAppService.claimMiner(userId, minerId));
    }

    @PostMapping("/collect")
    public AjaxResult collect()
    {
        Long userId = SecurityUtils.getUserId();
        return success(minerAppService.collectIfNeeded(userId));
    }

    @PostMapping("/exchange")
    public AjaxResult exchange(@RequestBody(required = false) Map<String, Object> body)
    {
        Map<String, Object> req = resolveBody(body);
        String requestNo = req.get("requestNo") == null ? null : String.valueOf(req.get("requestNo"));
        double wagAmount = toDouble(req.get("wagAmount"));
        Long userId = SecurityUtils.getUserId();
        return success(minerAppService.exchangeWag(userId, requestNo, wagAmount));
    }

    @GetMapping("/reward/logs")
    public AjaxResult rewardLogs()
    {
        Long userId = SecurityUtils.getUserId();
        List<Map<String, Object>> list = minerAppService.listRewardLogs(userId);
        return success(list);
    }

    @GetMapping("/exchange/logs")
    public AjaxResult exchangeLogs()
    {
        Long userId = SecurityUtils.getUserId();
        List<Map<String, Object>> list = minerAppService.listExchangeLogs(userId);
        return success(list);
    }

    private Map<String, Object> resolveBody(Map<String, Object> body)
    {
        if (body == null)
        {
            return new LinkedHashMap<>();
        }
        Object dataNode = body.get("data");
        if (dataNode instanceof String cipherText && StringUtils.isNotBlank(cipherText))
        {
            try
            {
                String plain = apiCryptoService.decryptText(cipherText);
                if (StringUtils.isBlank(plain))
                {
                    return body;
                }
                return objectMapper.readValue(plain, new TypeReference<Map<String, Object>>() {});
            }
            catch (Exception ignored)
            {
                return body;
            }
        }
        return body;
    }

    private Long toLong(Object value)
    {
        if (value == null)
        {
            return null;
        }
        try
        {
            return Long.valueOf(String.valueOf(value));
        }
        catch (Exception ignored)
        {
            return null;
        }
    }

    private double toDouble(Object value)
    {
        if (value == null)
        {
            return 0D;
        }
        try
        {
            return Double.parseDouble(String.valueOf(value));
        }
        catch (Exception ignored)
        {
            return 0D;
        }
    }
}
