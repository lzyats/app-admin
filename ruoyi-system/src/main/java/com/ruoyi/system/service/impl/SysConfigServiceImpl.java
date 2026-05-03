package com.ruoyi.system.service.impl;

import java.util.Collection;
import java.util.List;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.constant.CacheConstants;
import com.ruoyi.common.constant.UserConstants;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.core.text.Convert;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysConfig;
import com.ruoyi.system.mapper.SysConfigMapper;
import com.ruoyi.system.service.ISysConfigService;

/**
 * 参数配置 服务实现
 *
 * 读取优先走 Redis，Redis 异常时自动回源数据库。
 * 写入、修改、删除后统一重建缓存，保持 APP 配置与后台配置一致。
 *
 * @author ruoyi
 */
@Service
public class SysConfigServiceImpl implements ISysConfigService
{
    @Autowired
    private SysConfigMapper configMapper;

    @Autowired
    private RedisCache redisCache;

    /**
     * 服务启动后预热配置缓存
     */
    @PostConstruct
    public void init()
    {
        loadingConfigCache();
    }

    /**
     * 根据配置ID查询参数配置
     */
    @Override
    public SysConfig selectConfigById(Long configId)
    {
        SysConfig config = new SysConfig();
        config.setConfigId(configId);
        return configMapper.selectConfig(config);
    }

    /**
     * 根据配置键名查询参数值
     */
    @Override
    public String selectConfigByKey(String configKey)
    {
        String cacheKey = getCacheKey(configKey);
        try
        {
            String configValue = Convert.toStr(redisCache.getCacheObject(cacheKey));
            if (StringUtils.isNotEmpty(configValue))
            {
                return normalizeConfigValue(configValue);
            }
        }
        catch (Exception e)
        {
            // Redis 异常时直接回源数据库
        }

        SysConfig query = new SysConfig();
        query.setConfigKey(configKey);
        SysConfig retConfig = configMapper.selectConfig(query);
        if (StringUtils.isNotNull(retConfig))
        {
            try
            {
                String configValue = normalizeConfigValue(retConfig.getConfigValue());
                redisCache.setCacheObject(cacheKey, configValue);
            }
            catch (Exception e)
            {
                // 缓存写入失败不影响主流程
            }
            return normalizeConfigValue(retConfig.getConfigValue());
        }
        return StringUtils.EMPTY;
    }

    /**
     * 获取验证码开关
     */
    @Override
    public boolean selectCaptchaEnabled()
    {
        String captchaEnabled = selectConfigByKey("sys.account.captchaEnabled");
        if (StringUtils.isEmpty(captchaEnabled))
        {
            return true;
        }
        return Convert.toBool(captchaEnabled);
    }

    /**
     * 查询参数配置列表
     */
    @Override
    public List<SysConfig> selectConfigList(SysConfig config)
    {
        return configMapper.selectConfigList(config);
    }

    /**
     * 新增参数配置
     */
    @Override
    public int insertConfig(SysConfig config)
    {
        int row = configMapper.insertConfig(config);
        if (row > 0)
        {
            resetConfigCache();
        }
        return row;
    }

    /**
     * 修改参数配置
     */
    @Override
    public int updateConfig(SysConfig config)
    {
        SysConfig temp = selectConfigById(config.getConfigId());
        if (temp != null && !StringUtils.equals(temp.getConfigKey(), config.getConfigKey()))
        {
            try
            {
                redisCache.deleteObject(getCacheKey(temp.getConfigKey()));
            }
            catch (Exception e)
            {
                // 忽略旧缓存删除失败
            }
        }
        int row = configMapper.updateConfig(config);
        if (row > 0)
        {
            resetConfigCache();
        }
        return row;
    }

    /**
     * 批量保存参数配置，最后统一刷新缓存。
     */
    @Override
    public int batchSaveConfig(String operator, List<SysConfig> configs)
    {
        if (configs == null || configs.isEmpty())
        {
            return 0;
        }

        int rows = 0;
        for (SysConfig config : configs)
        {
            if (config == null || StringUtils.isBlank(config.getConfigKey()))
            {
                continue;
            }

            SysConfig query = new SysConfig();
            query.setConfigKey(config.getConfigKey());
            SysConfig existing = configMapper.selectConfig(query);
            if (existing != null)
            {
                config.setConfigId(existing.getConfigId());
                if (StringUtils.isBlank(config.getConfigType()))
                {
                    config.setConfigType(existing.getConfigType());
                }
                if (StringUtils.isBlank(config.getIsAppConfig()))
                {
                    config.setIsAppConfig(existing.getIsAppConfig());
                }
                config.setUpdateBy(operator);
                rows += configMapper.updateConfig(config);
            }
            else
            {
                if (StringUtils.isBlank(config.getConfigType()))
                {
                    config.setConfigType("N");
                }
                if (StringUtils.isBlank(config.getIsAppConfig()))
                {
                    config.setIsAppConfig("0");
                }
                config.setCreateBy(operator);
                rows += configMapper.insertConfig(config);
            }
        }

        if (rows > 0)
        {
            resetConfigCache();
        }
        return rows;
    }

    /**
     * 批量删除参数信息
     */
    @Override
    public void deleteConfigByIds(Long[] configIds)
    {
        for (Long configId : configIds)
        {
            SysConfig config = selectConfigById(configId);
            if (config == null)
            {
                continue;
            }
            if (StringUtils.equals(UserConstants.YES, config.getConfigType()))
            {
                throw new ServiceException(String.format("内置参数【%s】不能删除", config.getConfigKey()));
            }
            configMapper.deleteConfigById(configId);
        }
        resetConfigCache();
    }

    /**
     * 重建参数缓存
     */
    @Override
    public void loadingConfigCache()
    {
        List<SysConfig> configsList = configMapper.selectConfigList(new SysConfig());
        for (SysConfig config : configsList)
        {
            try
            {
                redisCache.setCacheObject(getCacheKey(config.getConfigKey()), normalizeConfigValue(config.getConfigValue()));
            }
            catch (Exception e)
            {
                // 忽略单个缓存写入失败
            }
        }

        try
        {
            SysConfig query = new SysConfig();
            query.setIsAppConfig("1");
            List<SysConfig> appConfigs = configMapper.selectConfigList(query);
            if (appConfigs == null)
            {
                appConfigs = new java.util.ArrayList<SysConfig>();
            }
            for (SysConfig config : appConfigs)
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
            redisCache.setCacheObject(CacheConstants.APP_CONFIG_KEY + "list", JSON.toJSONString(appConfigs));
        }
        catch (Exception e)
        {
            // 忽略 APP 配置预热失败
        }
    }

    /**
     * 清空参数缓存
     */
    @Override
    public void clearConfigCache()
    {
        try
        {
            Collection<String> keys = redisCache.keys(CacheConstants.SYS_CONFIG_KEY + "*");
            Collection<String> appKeys = redisCache.keys(CacheConstants.APP_CONFIG_KEY + "*");
            if (keys != null && !keys.isEmpty())
            {
                redisCache.deleteObject(keys);
            }
            if (appKeys != null && !appKeys.isEmpty())
            {
                redisCache.deleteObject(appKeys);
            }
        }
        catch (Exception e)
        {
            // Redis 不可用时忽略
        }
    }

    /**
     * 重置参数缓存
     */
    @Override
    public void resetConfigCache()
    {
        clearConfigCache();
        loadingConfigCache();
    }

    /**
     * 校验参数键名是否唯一
     */
    @Override
    public boolean checkConfigKeyUnique(SysConfig config)
    {
        Long configId = StringUtils.isNull(config.getConfigId()) ? -1L : config.getConfigId();
        SysConfig info = configMapper.checkConfigKeyUnique(config.getConfigKey());
        if (StringUtils.isNotNull(info) && info.getConfigId().longValue() != configId.longValue())
        {
            return UserConstants.NOT_UNIQUE;
        }
        return UserConstants.UNIQUE;
    }

    /**
     * 获取缓存键
     */
    private String getCacheKey(String configKey)
    {
        return CacheConstants.SYS_CONFIG_KEY + configKey;
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
