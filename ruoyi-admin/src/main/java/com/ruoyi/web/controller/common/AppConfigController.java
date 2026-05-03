package com.ruoyi.web.controller.common;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.constant.CacheConstants;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.core.text.Convert;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysConfig;
import com.ruoyi.system.service.ISysConfigService;

/**
 * APP 配置接口
 */
@RestController
@RequestMapping("/app/config")
public class AppConfigController
{
    private static final String APP_CONFIG_LIST_CACHE_KEY = CacheConstants.APP_CONFIG_KEY + "list";

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private RedisCache redisCache;

    @GetMapping("/bootstrap")
    public AjaxResult bootstrap()
    {
        Map<String, Object> data = new LinkedHashMap<String, Object>();
        for (SysConfig config : loadAppConfigList())
        {
            String configKey = StringUtils.trim(config.getConfigKey());
            if (isExcludedBasicConfigKey(configKey))
            {
                continue;
            }
            String configValue = normalizeConfigValue(config.getConfigValue());
            data.put(configKey, configValue);
        }
        return AjaxResult.success(data);
    }

    @GetMapping("/options")
    public AjaxResult options()
    {
        List<Map<String, Object>> data = new ArrayList<Map<String, Object>>();
        for (SysConfig config : loadAppConfigList())
        {
            if (isExcludedBasicConfigKey(config == null ? null : config.getConfigKey()))
            {
                continue;
            }
            data.add(buildOption(config));
        }
        return AjaxResult.success(data);
    }

    @GetMapping("/list")
    public AjaxResult list()
    {
        SysConfig query = new SysConfig();
        query.setIsAppConfig("1");
        List<SysConfig> configs = configService.selectConfigList(query);
        if (configs == null)
        {
            configs = new ArrayList<SysConfig>();
        }
        configs.removeIf(config -> config == null || isExcludedBasicConfigKey(config.getConfigKey()));
        configs.sort((left, right) ->
        {
            Long leftId = left == null ? null : left.getConfigId();
            Long rightId = right == null ? null : right.getConfigId();
            if (leftId == null && rightId == null)
            {
                return 0;
            }
            if (leftId == null)
            {
                return 1;
            }
            if (rightId == null)
            {
                return -1;
            }
            return leftId.compareTo(rightId);
        });
        return AjaxResult.success(configs);
    }

    @PreAuthorize("@ss.hasPermi('system:config:edit')")
    @PostMapping("/save")
    public AjaxResult save(@RequestBody Map<String, Object> body)
    {
        List<SysConfig> configs = new ArrayList<SysConfig>();
        Object optionsObj = body.get("options");
        if (optionsObj instanceof List)
        {
            @SuppressWarnings("unchecked")
            List<Object> optionList = (List<Object>) optionsObj;
            for (Object optionObj : optionList)
            {
                if (!(optionObj instanceof Map))
                {
                    continue;
                }
                @SuppressWarnings("unchecked")
                Map<String, Object> option = (Map<String, Object>) optionObj;
                String configKey = StringUtils.trim((String) option.get("configKey"));
                if (StringUtils.isEmpty(configKey))
                {
                    continue;
                }
                if (isExcludedBasicConfigKey(configKey))
                {
                    continue;
                }
                SysConfig config = new SysConfig();
                config.setConfigKey(configKey);
                config.setConfigName(StringUtils.trim((String) option.get("configName")));
                config.setConfigValue(normalizeConfigValue(StringUtils.trim((String) option.get("configValue"))));
                config.setConfigType("N");
                config.setIsAppConfig(normalizeAppFlag(option.get("isAppConfig")));
                config.setRemark(StringUtils.trim((String) option.get("remark")));
                configs.add(config);
            }
        }

        if (configs.isEmpty())
        {
            return AjaxResult.error("No config data to save.");
        }

        int rows = configService.batchSaveConfig(SecurityUtils.getUsername(), configs);
        redisCache.deleteObject(APP_CONFIG_LIST_CACHE_KEY);
        return AjaxResult.success(rows);
    }

    private List<SysConfig> loadAppConfigList()
    {
        try
        {
            String cached = StringUtils.trim(Convert.toStr(redisCache.getCacheObject(APP_CONFIG_LIST_CACHE_KEY)));
            if (StringUtils.isNotEmpty(cached))
            {
                List<SysConfig> configs = JSON.parseArray(cached, SysConfig.class);
                if (configs != null && !configs.isEmpty())
                {
                    normalizeConfigList(configs);
                    return configs;
                }
            }
        }
        catch (Exception e)
        {
            // ignore cache read failure
        }

        SysConfig query = new SysConfig();
        query.setIsAppConfig("1");
        List<SysConfig> configs = configService.selectConfigList(query);
        if (configs == null)
        {
            configs = new ArrayList<SysConfig>();
        }
        configs.removeIf(config -> config == null || isExcludedBasicConfigKey(config.getConfigKey()));
        normalizeConfigList(configs);
        configs.sort((left, right) ->
        {
            Long leftId = left == null ? null : left.getConfigId();
            Long rightId = right == null ? null : right.getConfigId();
            if (leftId == null && rightId == null)
            {
                return 0;
            }
            if (leftId == null)
            {
                return 1;
            }
            if (rightId == null)
            {
                return -1;
            }
            return leftId.compareTo(rightId);
        });

        try
        {
            redisCache.setCacheObject(APP_CONFIG_LIST_CACHE_KEY, JSON.toJSONString(configs));
        }
        catch (Exception e)
        {
            // ignore cache write failure
        }
        return configs;
    }

    private Map<String, Object> buildOption(SysConfig config)
    {
        Map<String, Object> option = new LinkedHashMap<String, Object>();
        option.put("item", config.getConfigKey());
        option.put("configKey", config.getConfigKey());
        option.put("name", config.getConfigName());
        String value = normalizeConfigValue(config.getConfigValue());
        option.put("defaultValue", value);
        option.put("currentValue", value);
        option.put("remark", config.getRemark());
        option.put("isAppConfig", config.getIsAppConfig());
        option.put("valueType", inferValueType(config));
        return option;
    }

    private String inferValueType(SysConfig config)
    {
        if (config == null)
        {
            return "text";
        }
        String item = StringUtils.trim(config.getConfigKey());
        String value = StringUtils.trim(config.getConfigValue());
        if (StringUtils.equals(item, "signRewardType") || StringUtils.equals(item, "investCurrencyMode"))
        {
            return "select";
        }
        if (StringUtils.equals(item, "inviteRewardRule"))
        {
            return "json";
        }
        if (isStrictBooleanValue(value))
        {
            return "bool";
        }
        if (isNumericLike(value))
        {
            return "number";
        }
        if (looksLikeJson(value))
        {
            return "json";
        }
        return "text";
    }

    private boolean isStrictBooleanValue(String value)
    {
        String lowerValue = StringUtils.trim(value).toLowerCase();
        return "true".equals(lowerValue) || "false".equals(lowerValue);
    }

    private boolean isNumericLike(String value)
    {
        if (StringUtils.isEmpty(value))
        {
            return false;
        }
        try
        {
            Double.parseDouble(value);
            return true;
        }
        catch (Exception e)
        {
            return false;
        }
    }

    private boolean looksLikeJson(String value)
    {
        if (StringUtils.isEmpty(value))
        {
            return false;
        }
        String trimmed = StringUtils.trim(value);
        return trimmed.startsWith("{") || trimmed.startsWith("[");
    }

    private String normalizeAppFlag(Object value)
    {
        if (value == null)
        {
            return "1";
        }
        String raw = StringUtils.trim(String.valueOf(value));
        if (StringUtils.isEmpty(raw))
        {
            return "1";
        }
        return "0".equals(raw) ? "0" : "1";
    }

    private void normalizeConfigList(List<SysConfig> configs)
    {
        if (configs == null || configs.isEmpty())
        {
            return;
        }
        for (SysConfig config : configs)
        {
            if (config == null)
            {
                continue;
            }
            config.setConfigKey(StringUtils.trim(config.getConfigKey()));
            config.setConfigName(StringUtils.trim(config.getConfigName()));
            config.setConfigValue(normalizeConfigValue(config.getConfigValue()));
            config.setRemark(StringUtils.trim(config.getRemark()));
        }
    }

    private boolean isExcludedBasicConfigKey(String configKey)
    {
        String key = StringUtils.trim(configKey);
        return StringUtils.equals(key, "app.download.url")
            || StringUtils.equals(key, "app.upgrade.config")
            || StringUtils.equals(key, "app.sign.continuousRewardRule");
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
            Object parsed = JSON.parse(trimmed);
            return JSON.toJSONString(parsed);
        }
        catch (Exception e)
        {
            return trimmed;
        }
    }
}
