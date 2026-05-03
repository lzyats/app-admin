package com.ruoyi.system.service.impl;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.core.text.Convert;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysMiner;
import com.ruoyi.system.domain.SysMinerRewardLog;
import com.ruoyi.system.domain.SysUserMiner;
import com.ruoyi.system.domain.SysUserMinerRun;
import com.ruoyi.system.domain.SysUserWagWallet;
import com.ruoyi.system.mapper.SysMinerMapper;
import com.ruoyi.system.mapper.SysMinerRewardLogMapper;
import com.ruoyi.system.mapper.SysUserMinerMapper;
import com.ruoyi.system.mapper.SysUserMinerRunMapper;
import com.ruoyi.system.mapper.SysUserWagWalletMapper;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysMinerRunService;

@Service
public class SysMinerRunServiceImpl implements ISysMinerRunService
{
    private static final long ONE_DAY_MS = 24L * 60L * 60L * 1000L;
    private static final String CACHE_KEY_OVERVIEW_PREFIX = "miner:overview:";
    private static final String CACHE_KEY_REWARD_LOGS_PREFIX = "miner:rewardLogs:";

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private SysMinerMapper minerMapper;

    @Autowired
    private SysUserMinerMapper userMinerMapper;

    @Autowired
    private SysUserMinerRunMapper runMapper;

    @Autowired
    private SysUserWagWalletMapper wagWalletMapper;

    @Autowired
    private SysMinerRewardLogMapper rewardLogMapper;

    @Autowired
    private RedisCache redisCache;

    @Override
    @Transactional
    public void settleMinerRuns()
    {
        Date now = new Date();
        List<SysUserMinerRun> runs = runMapper.selectRunsForCalc(now, 200);
        if (runs == null || runs.isEmpty())
        {
            return;
        }
        for (SysUserMinerRun snapshot : runs)
        {
            if (snapshot == null || snapshot.getRunId() == null || snapshot.getRunId() <= 0)
            {
                continue;
            }
            finalizeIfDue(snapshot.getRunId(), now);
        }
    }

    private void finalizeIfDue(Long runId, Date now)
    {
        SysUserMinerRun run = runMapper.selectRunByIdForUpdate(runId);
        if (run == null || run.getRunId() == null || run.getRunId() <= 0)
        {
            return;
        }
        if (!"0".equals(StringUtils.trim(run.getRunStatus())))
        {
            return;
        }

        Date end = run.getCycleEndTime();
        if (end == null)
        {
            return;
        }
        if (now.getTime() < end.getTime())
        {
            return;
        }
        finalizeCycle(run, now);
    }

    private void finalizeCycle(SysUserMinerRun run, Date now)
    {
        if (!"0".equals(StringUtils.trim(run.getRunStatus())))
        {
            return;
        }

        Date boundary = run.getCycleEndTime() != null ? run.getCycleEndTime() : now;
        double cycleWag = safeDouble(run.getCycleWag());
        if (cycleWag <= 0D)
        {
            run.setRunStatus("2");
            runMapper.updateRun(run);
            return;
        }

        String rewardMode = StringUtils.trim(run.getRewardMode());
        boolean auto = "A".equalsIgnoreCase(rewardMode);

        if (auto)
        {
            creditWag(run.getUserId(), cycleWag);

            SysUserMiner userMiner = userMinerMapper.selectUserMinerById(run.getUserMinerId());
            if (userMiner != null && userMiner.getUserMinerId() != null)
            {
                userMiner.setTotalOutputWag(safeDouble(userMiner.getTotalOutputWag()) + cycleWag);
                userMinerMapper.updateUserMiner(userMiner);
            }

            SysMinerRewardLog log = new SysMinerRewardLog();
            log.setUserId(run.getUserId());
            log.setMinerId(run.getMinerId());
            log.setUserMinerId(run.getUserMinerId());
            log.setRunId(run.getRunId());
            log.setRewardMode(run.getRewardMode());
            log.setAction("AUTO_CREDIT");
            log.setWagAmount(cycleWag);
            log.setPeriodStart(run.getStartTime());
            log.setPeriodEnd(run.getCycleEndTime());
            rewardLogMapper.insertRewardLog(log);

            resetRun(run, boundary);
            runMapper.updateRun(run);
            evictMinerCaches(run.getUserId());
            return;
        }

        run.setProducedWag(cycleWag);
        run.setRunStatus("1");
        run.setLastCalcTime(boundary);
        run.setVersion(run.getVersion() == null ? 0 : run.getVersion() + 1);
        runMapper.updateRun(run);

        SysMinerRewardLog log = new SysMinerRewardLog();
        log.setUserId(run.getUserId());
        log.setMinerId(run.getMinerId());
        log.setUserMinerId(run.getUserMinerId());
        log.setRunId(run.getRunId());
        log.setRewardMode(run.getRewardMode());
        log.setAction("CYCLE_FINISH");
        log.setWagAmount(cycleWag);
        log.setPeriodStart(run.getStartTime());
        log.setPeriodEnd(run.getCycleEndTime());
        log.setRemark("pending collect");
        rewardLogMapper.insertRewardLog(log);
        evictMinerCaches(run.getUserId());
    }

    private void resetRun(SysUserMinerRun run, Date now)
    {
        if (now == null)
        {
            now = new Date();
        }
        SysMiner miner = minerMapper.selectMinerById(run.getMinerId());
        run.setRewardMode(normalizeRewardMode(readString("app.miner.rewardMode", "AUTO")));
        run.setRunStatus("0");
        run.setStartTime(now);
        run.setCycleEndTime(new Date(now.getTime() + ONE_DAY_MS));
        run.setLastCalcTime(now);
        run.setCycleWag(safeDouble(miner == null ? null : miner.getWagPerDay()));
        run.setProducedWag(0D);
        run.setCreditedFlag("0");
        run.setCollectTime(null);
        run.setVersion(run.getVersion() == null ? 0 : run.getVersion() + 1);
    }

    private void creditWag(Long userId, double wagAmount)
    {
        if (userId == null || userId <= 0 || wagAmount <= 0D)
        {
            return;
        }
        SysUserWagWallet wallet = wagWalletMapper.selectByUserIdForUpdate(userId);
        if (wallet == null)
        {
            SysUserWagWallet init = new SysUserWagWallet();
            init.setUserId(userId);
            init.setAvailableWag(0D);
            init.setTotalEarnedWag(0D);
            init.setTotalExchangedWag(0D);
            wagWalletMapper.insertWallet(init);
            wallet = wagWalletMapper.selectByUserIdForUpdate(userId);
            if (wallet == null)
            {
                throw new ServiceException("WAG钱包初始化失败。");
            }
        }
        wallet.setAvailableWag(round8(safeDouble(wallet.getAvailableWag()) + wagAmount));
        wallet.setTotalEarnedWag(round8(safeDouble(wallet.getTotalEarnedWag()) + wagAmount));
        wagWalletMapper.updateWallet(wallet);
    }

    private void evictMinerCaches(Long userId)
    {
        if (userId == null || userId <= 0)
        {
            return;
        }
        redisCache.deleteObject(CACHE_KEY_OVERVIEW_PREFIX + userId);
        redisCache.deleteObject(CACHE_KEY_REWARD_LOGS_PREFIX + userId);
    }

    private String normalizeRewardMode(String value)
    {
        String raw = StringUtils.trim(value).toUpperCase();
        return "MANUAL".equals(raw) ? "M" : "A";
    }

    private String readString(String key, String defaultValue)
    {
        String raw = Convert.toStr(configService.selectConfigByKey(key));
        raw = StringUtils.trim(raw);
        return StringUtils.isEmpty(raw) ? defaultValue : raw;
    }

    private double safeDouble(Double value)
    {
        return value == null ? 0D : value;
    }

    private double round8(double value)
    {
        return BigDecimal.valueOf(value).setScale(8, java.math.RoundingMode.DOWN).doubleValue();
    }
}
