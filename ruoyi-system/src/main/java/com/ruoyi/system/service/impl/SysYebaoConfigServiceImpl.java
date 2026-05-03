package com.ruoyi.system.service.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.constant.CacheConstants;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysYebaoConfig;
import com.ruoyi.system.mapper.SysYebaoConfigMapper;
import com.ruoyi.system.service.ISysYebaoConfigService;

@Service
public class SysYebaoConfigServiceImpl implements ISysYebaoConfigService
{
    private static final Logger logger = LoggerFactory.getLogger(SysYebaoConfigServiceImpl.class);

    private static final String CACHE_LIST_KEY = CacheConstants.YEBAO_CONFIG_KEY + "list";
    private static final String CACHE_ALL_KEY = CacheConstants.YEBAO_CONFIG_KEY + "all";
    private static final String CACHE_CURRENT_KEY = CacheConstants.YEBAO_CONFIG_KEY + "current";
    private static final String CACHE_ID_PREFIX = CacheConstants.YEBAO_CONFIG_KEY + "id:";

    @Autowired
    private SysYebaoConfigMapper yebaoConfigMapper;

    @Autowired
    private RedisCache redisCache;

    @PostConstruct
    public void init()
    {
        loadingYebaoConfigCache();
    }

    @Override
    public List<SysYebaoConfig> selectYebaoConfigList(SysYebaoConfig config)
    {
        String cacheKey = buildListCacheKey(config);
        try
        {
            String cached = redisCache.getCacheObject(cacheKey);
            if (StringUtils.isNotBlank(cached))
            {
                return JSON.parseArray(cached, SysYebaoConfig.class);
            }
        }
        catch (Exception e)
        {
            logger.debug("Read yebao config list cache failed, fallback to db: {}", e.getMessage());
        }

        List<SysYebaoConfig> list = yebaoConfigMapper.selectYebaoConfigList(config);
        try
        {
            redisCache.setCacheObject(cacheKey, JSON.toJSONString(list == null ? new ArrayList<>() : list));
        }
        catch (Exception e)
        {
            logger.debug("Write yebao config list cache failed: {}", e.getMessage());
        }
        return list;
    }

    @Override
    public List<SysYebaoConfig> selectYebaoConfigAll()
    {
        try
        {
            String cached = redisCache.getCacheObject(CACHE_ALL_KEY);
            if (StringUtils.isNotBlank(cached))
            {
                return JSON.parseArray(cached, SysYebaoConfig.class);
            }
        }
        catch (Exception e)
        {
            logger.debug("Read yebao config all cache failed, fallback to db: {}", e.getMessage());
        }

        List<SysYebaoConfig> list = yebaoConfigMapper.selectYebaoConfigAll();
        try
        {
            redisCache.setCacheObject(CACHE_ALL_KEY, JSON.toJSONString(list == null ? new ArrayList<>() : list));
        }
        catch (Exception e)
        {
            logger.debug("Write yebao config all cache failed: {}", e.getMessage());
        }
        return list;
    }

    @Override
    public SysYebaoConfig selectYebaoConfigById(Long configId)
    {
        if (configId == null)
        {
            return null;
        }
        String cacheKey = CACHE_ID_PREFIX + configId;
        try
        {
            String cached = redisCache.getCacheObject(cacheKey);
            if (StringUtils.isNotBlank(cached))
            {
                return JSON.parseObject(cached, SysYebaoConfig.class);
            }
        }
        catch (Exception e)
        {
            logger.debug("Read yebao config by id cache failed, fallback to db: {}", e.getMessage());
        }

        SysYebaoConfig config = yebaoConfigMapper.selectYebaoConfigById(configId);
        if (config != null)
        {
            try
            {
                redisCache.setCacheObject(cacheKey, JSON.toJSONString(config));
            }
            catch (Exception e)
            {
                logger.debug("Write yebao config by id cache failed: {}", e.getMessage());
            }
        }
        return config;
    }

    @Override
    public SysYebaoConfig selectCurrentYebaoConfig()
    {
        try
        {
            String cached = redisCache.getCacheObject(CACHE_CURRENT_KEY);
            if (StringUtils.isNotBlank(cached))
            {
                return JSON.parseObject(cached, SysYebaoConfig.class);
            }
        }
        catch (Exception e)
        {
            logger.warn("Read current yebao config cache failed, fallback to db: {}", e.getMessage());
        }

        try
        {
            SysYebaoConfig config = yebaoConfigMapper.selectCurrentYebaoConfig();
            if (config != null)
            {
                redisCache.setCacheObject(CACHE_CURRENT_KEY, JSON.toJSONString(config));
            }
            return config;
        }
        catch (Exception e)
        {
            logger.warn("Select current yebao config failed, return null: {}", e.getMessage());
            return null;
        }
    }

    @Override
    public int insertYebaoConfig(SysYebaoConfig config)
    {
        int row;
        try
        {
            row = yebaoConfigMapper.insertYebaoConfig(config);
        }
        catch (DataAccessException e)
        {
            throw wrapYebaoConfigDataAccessException(e);
        }
        if (row > 0)
        {
            resetYebaoConfigCache();
        }
        return row;
    }

    @Override
    public int updateYebaoConfig(SysYebaoConfig config)
    {
        int row;
        try
        {
            row = yebaoConfigMapper.updateYebaoConfig(config);
        }
        catch (DataAccessException e)
        {
            throw wrapYebaoConfigDataAccessException(e);
        }
        if (row == 0 && config != null && config.getConfigId() != null)
        {
            // MySQL 在“值未变化”场景可能返回 0，避免前端误报“操作失败”
            SysYebaoConfig exists = yebaoConfigMapper.selectYebaoConfigById(config.getConfigId());
            if (exists != null)
            {
                row = 1;
            }
            else
            {
                throw new ServiceException("余额宝配置不存在或已被删除，无法更新。");
            }
        }
        if (row > 0)
        {
            resetYebaoConfigCache();
        }
        return row;
    }

    @Override
    public int deleteYebaoConfigById(Long configId)
    {
        int row = yebaoConfigMapper.deleteYebaoConfigById(configId);
        if (row > 0)
        {
            resetYebaoConfigCache();
        }
        return row;
    }

    @Override
    public int deleteYebaoConfigByIds(Long[] configIds)
    {
        int row = yebaoConfigMapper.deleteYebaoConfigByIds(configIds);
        if (row > 0)
        {
            resetYebaoConfigCache();
        }
        return row;
    }

    public void loadingYebaoConfigCache()
    {
        try
        {
            List<SysYebaoConfig> configs = yebaoConfigMapper.selectYebaoConfigAll();
            if (configs == null)
            {
                configs = new ArrayList<>();
            }
            redisCache.setCacheObject(CACHE_ALL_KEY, JSON.toJSONString(configs));
            for (SysYebaoConfig config : configs)
            {
                if (config != null && config.getConfigId() != null)
                {
                    redisCache.setCacheObject(CACHE_ID_PREFIX + config.getConfigId(), JSON.toJSONString(config));
                }
            }
            SysYebaoConfig current = yebaoConfigMapper.selectCurrentYebaoConfig();
            if (current != null)
            {
                redisCache.setCacheObject(CACHE_CURRENT_KEY, JSON.toJSONString(current));
            }
        }
        catch (Exception e)
        {
            logger.warn("Load yebao config cache failed: {}", e.getMessage());
        }
    }

    public void clearYebaoConfigCache()
    {
        try
        {
            Collection<String> keys = redisCache.keys(CacheConstants.YEBAO_CONFIG_KEY + "*");
            if (keys != null && !keys.isEmpty())
            {
                redisCache.deleteObject(keys);
            }
        }
        catch (Exception e)
        {
            logger.warn("Clear yebao config cache failed: {}", e.getMessage());
        }
    }

    public void resetYebaoConfigCache()
    {
        clearYebaoConfigCache();
        loadingYebaoConfigCache();
    }

    private String buildListCacheKey(SysYebaoConfig config)
    {
        if (config == null)
        {
            return CACHE_LIST_KEY + ":all";
        }
        return CACHE_LIST_KEY + ":" + StringUtils.defaultString(config.getConfigName()) + ":"
            + StringUtils.defaultString(config.getAnnualRate() == null ? null : String.valueOf(config.getAnnualRate())) + ":"
            + StringUtils.defaultString(config.getUnitAmount() == null ? null : String.valueOf(config.getUnitAmount())) + ":"
            + StringUtils.defaultString(config.getStatus());
    }

    private ServiceException wrapYebaoConfigDataAccessException(DataAccessException e)
    {
        String message = e.getMostSpecificCause() != null ? e.getMostSpecificCause().getMessage() : e.getMessage();
        String lowerMessage = message == null ? "" : message.toLowerCase();
        if (lowerMessage.contains("growth_value_per_unit"))
        {
            return new ServiceException(
                "每份成长值保存失败：请确认数据库字段 sys_yebao_config.growth_value_per_unit 为 DECIMAL(10,4)，并重启后端服务后重试。");
        }
        return new ServiceException("余额宝配置保存失败：" + StringUtils.defaultString(message, "数据库写入异常"));
    }
}
