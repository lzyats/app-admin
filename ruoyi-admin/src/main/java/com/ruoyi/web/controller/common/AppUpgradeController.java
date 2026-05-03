package com.ruoyi.web.controller.common;

import java.util.HashMap;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.service.ISysConfigService;

@RestController
@RequestMapping("/app/upgrade")
public class AppUpgradeController
{
    private static final String UPGRADE_CONFIG_KEY = "app.upgrade.config";

    @Autowired
    private ISysConfigService configService;

    @GetMapping("/config")
    public AjaxResult config()
    {
        String raw = normalizeConfigValue(configService.selectConfigByKey(UPGRADE_CONFIG_KEY));
        if (StringUtils.isEmpty(raw))
        {
            return AjaxResult.success(defaultData());
        }

        try
        {
            JSONObject json = JSONObject.parseObject(raw);
            Map<String, Object> data = defaultData();
            String appUrl = StringUtils.nvl(json.getString("appUrl"), "");
            data.put("appUrl", StringUtils.trim(appUrl));
            data.put("androidVersion", StringUtils.trim(json.getString("androidVersion")));
            data.put("androidApkUrl", StringUtils.trim(json.getString("androidApkUrl")));
            data.put("iosVersion", StringUtils.trim(json.getString("iosVersion")));
            data.put("iosInstallUrl", StringUtils.trim(json.getString("iosInstallUrl")));
            data.put("forceUpgrade", json.getBooleanValue("forceUpgrade"));
            data.put("releaseNote", StringUtils.trim(json.getString("releaseNote")));
            return AjaxResult.success(data);
        }
        catch (Exception e)
        {
            return AjaxResult.error("升级配置格式错误，请检查参数键 " + UPGRADE_CONFIG_KEY);
        }
    }

    private Map<String, Object> defaultData()
    {
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("configKey", UPGRADE_CONFIG_KEY);
        data.put("appUrl", "");
        data.put("androidVersion", "");
        data.put("androidApkUrl", "");
        data.put("iosVersion", "");
        data.put("iosInstallUrl", "");
        data.put("forceUpgrade", false);
        data.put("releaseNote", "");
        return data;
    }

    private String normalizeConfigValue(String value)
    {
        String trimmed = StringUtils.trim(value);
        if (StringUtils.isEmpty(trimmed))
        {
            return StringUtils.EMPTY;
        }
        if (!(trimmed.startsWith("{") || trimmed.startsWith("[")))
        {
            return trimmed;
        }
        try
        {
            JSONObject json = JSONObject.parseObject(trimmed);
            return json.toJSONString();
        }
        catch (Exception e)
        {
            return trimmed;
        }
    }
}

