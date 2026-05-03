package com.ruoyi.system.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.system.domain.SysMiner;
import com.ruoyi.system.mapper.SysMinerMapper;
import com.ruoyi.system.service.ISysMinerService;

@Service
public class SysMinerServiceImpl implements ISysMinerService
{
    private static final String CACHE_KEY_ACTIVE_MINERS = "miner:active:list";

    @Autowired
    private SysMinerMapper minerMapper;

    @Autowired
    private RedisCache redisCache;

    @Override
    public SysMiner selectMinerById(Long minerId)
    {
        return minerMapper.selectMinerById(minerId);
    }

    @Override
    public List<SysMiner> selectMinerList(SysMiner miner)
    {
        return minerMapper.selectMinerList(miner);
    }

    @Override
    public int insertMiner(SysMiner miner)
    {
        int rows = minerMapper.insertMiner(miner);
        if (rows > 0)
        {
            clearCache();
        }
        return rows;
    }

    @Override
    public int updateMiner(SysMiner miner)
    {
        int rows = minerMapper.updateMiner(miner);
        if (rows > 0)
        {
            clearCache();
        }
        return rows;
    }

    @Override
    public int deleteMinerByIds(Long[] minerIds)
    {
        int rows = minerMapper.deleteMinerByIds(minerIds);
        if (rows > 0)
        {
            clearCache();
        }
        return rows;
    }

    private void clearCache()
    {
        redisCache.deleteObject(CACHE_KEY_ACTIVE_MINERS);
    }
}
