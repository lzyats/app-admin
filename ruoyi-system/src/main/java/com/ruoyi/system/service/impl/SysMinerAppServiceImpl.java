package com.ruoyi.system.service.impl;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Comparator;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.entity.SysUserWallet;
import com.ruoyi.common.core.domain.entity.SysUserWalletLog;
import com.ruoyi.common.core.text.Convert;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysMiner;
import com.ruoyi.system.domain.SysMinerExchangeLog;
import com.ruoyi.system.domain.SysMinerRewardLog;
import com.ruoyi.system.domain.SysUserMiner;
import com.ruoyi.system.domain.SysUserMinerRun;
import com.ruoyi.system.domain.SysUserWagWallet;
import com.ruoyi.system.mapper.SysMinerExchangeLogMapper;
import com.ruoyi.system.mapper.SysMinerMapper;
import com.ruoyi.system.mapper.SysMinerRewardLogMapper;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.mapper.SysUserMinerMapper;
import com.ruoyi.system.mapper.SysUserMinerRunMapper;
import com.ruoyi.system.mapper.SysUserWagWalletMapper;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysMinerAppService;
import com.ruoyi.system.service.ISysUserService;
import com.ruoyi.system.service.ISysUserWalletLogService;
import com.ruoyi.system.service.ISysUserWalletService;

@Service
public class SysMinerAppServiceImpl implements ISysMinerAppService
{
    private static final long ONE_DAY_MS = 24L * 60L * 60L * 1000L;
    private static final String CACHE_KEY_ACTIVE_MINERS = "miner:active:list";
    private static final Integer CACHE_EXPIRE_MINUTES = 30;
    private static final String CACHE_KEY_OVERVIEW_PREFIX = "miner:overview:";
    private static final String CACHE_KEY_REWARD_LOGS_PREFIX = "miner:rewardLogs:";
    private static final Integer CACHE_EXPIRE_SHORT_MINUTES = 5;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ISysUserWalletService walletService;

    @Autowired
    private ISysUserWalletLogService walletLogService;

    @Autowired
    private SysMinerMapper minerMapper;

    @Autowired
    private RedisCache redisCache;

    @Autowired
    private SysUserMapper sysUserMapper;

    @Autowired
    private SysUserMinerMapper userMinerMapper;

    @Autowired
    private SysUserMinerRunMapper runMapper;

    @Autowired
    private SysUserWagWalletMapper wagWalletMapper;

    @Autowired
    private SysMinerRewardLogMapper rewardLogMapper;

    @Autowired
    private SysMinerExchangeLogMapper exchangeLogMapper;

    @Override
    public Map<String, Object> getOverview(Long userId)
    {
        String cacheKey = CACHE_KEY_OVERVIEW_PREFIX + userId;
        Map<String, Object> cached = redisCache.getCacheObject(cacheKey);
        if (cached != null)
        {
            return cached;
        }
        Map<String, Object> result = new LinkedHashMap<>();
        SysUserWagWallet wagWallet = ensureWagWallet(userId);
        result.put("availableWag", safeDouble(wagWallet.getAvailableWag()));
        result.put("wagToUsdRate", readDouble("app.miner.wagToUsdRate", 0.001D));

        int investMode = Convert.toInt(configService.selectConfigByKey("app.currency.investMode"), 1);
        String targetCurrency = investMode == 1 ? "CNY" : "USD";
        result.put("targetCurrency", targetCurrency);

        SysUserMiner current = userMinerMapper.selectCurrentUserMiner(userId);
        if (current != null && current.getUserMinerId() != null && current.getUserMinerId() > 0)
        {
            result.put("currentMiner", buildMinerMap(current));
        }
        else
        {
            result.put("currentMiner", null);
        }

        SysUserMinerRun run = runMapper.selectLatestRunByUserId(userId);
        if (run != null && run.getRunId() != null && run.getRunId() > 0)
        {
            result.put("run", buildRunMap(run));
        }
        else
        {
            result.put("run", null);
        }

        redisCache.setCacheObject(cacheKey, result, CACHE_EXPIRE_SHORT_MINUTES, TimeUnit.MINUTES);
        return result;
    }

    @Override
    public List<Map<String, Object>> listAvailableMiners(Long userId)
    {
        SysUser user = sysUserMapper.selectUserBaseById(userId);
        if (user == null)
        {
            throw new ServiceException("用户不存在。");
        }
        int userLevel = user.getLevel() != null ? user.getLevel()
                : (user.getUserLevel() != null ? user.getUserLevel() : 0);

        SysMiner query = new SysMiner();
        query.setStatus("0");
        List<SysMiner> miners = getActiveMinersCached(query);
        List<Map<String, Object>> result = new ArrayList<>();
        if (miners == null || miners.isEmpty())
        {
            return result;
        }

        for (SysMiner miner : miners)
        {
            if (miner == null || miner.getMinerId() == null)
            {
                continue;
            }
            int minLevel = miner.getMinUserLevel() == null ? 0 : miner.getMinUserLevel();
            minLevel = Math.max(0, minLevel);
            int maxLevel = miner.getMaxUserLevel() == null ? 999 : miner.getMaxUserLevel();
            maxLevel = maxLevel <= 0 ? 999 : maxLevel;
            boolean eligible = userLevel >= minLevel && userLevel <= maxLevel;
            SysUserMiner owned = userMinerMapper.selectUserMinerByUserAndMiner(userId, miner.getMinerId());
            boolean isOwned = owned != null && owned.getUserMinerId() != null && owned.getUserMinerId() > 0;
            boolean isCurrent = owned != null ? StringUtils.equals(owned.getIsCurrent(), "1") : false;
            boolean canClaim = eligible && !isOwned;
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("minerId", miner.getMinerId());
            item.put("minerName", miner.getMinerName());
            item.put("minerLevel", miner.getMinerLevel());
            item.put("power", miner.getPower());
            item.put("wagPerDay", safeDouble(miner.getWagPerDay()));
            item.put("coverImage", miner.getCoverImage());
            item.put("remark", miner.getRemark());
            item.put("minUserLevel", minLevel);
            item.put("maxUserLevel", maxLevel);
            item.put("eligible", eligible);
            item.put("canClaim", canClaim);
            item.put("owned", isOwned);
            item.put("isCurrent", isCurrent);
            result.add(item);
        }
        return result;
    }

    private List<SysMiner> getActiveMinersCached(SysMiner query)
    {
        List<SysMiner> cached = redisCache.getCacheObject(CACHE_KEY_ACTIVE_MINERS);
        if (cached != null)
        {
            return cached;
        }
        List<SysMiner> list = minerMapper.selectMinerList(query);
        if (list == null)
        {
            list = new ArrayList<>();
        }
        Collections.sort(list, Comparator
                .comparing((SysMiner m) -> m == null || m.getMinerLevel() == null ? 0 : m.getMinerLevel())
                .thenComparing(m -> m == null || m.getSortOrder() == null ? 0 : m.getSortOrder())
                .thenComparing(m -> m == null || m.getMinerId() == null ? 0L : m.getMinerId()));
        redisCache.setCacheObject(CACHE_KEY_ACTIVE_MINERS, list, CACHE_EXPIRE_MINUTES, TimeUnit.MINUTES);
        return list;
    }

    @Override
    @Transactional
    public Map<String, Object> claimMiner(Long userId, Long minerId)
    {
        if (minerId == null || minerId <= 0)
        {
            throw new ServiceException("矿机ID不能为空。");
        }

        SysUser user = sysUserMapper.selectUserBaseByIdForUpdate(userId);
        if (user == null)
        {
            throw new ServiceException("用户不存在。");
        }
        int userLevel = user.getLevel() != null ? user.getLevel()
                : (user.getUserLevel() != null ? user.getUserLevel() : 0);

        SysMiner miner = minerMapper.selectMinerById(minerId);
        if (miner == null || !"0".equals(StringUtils.trim(miner.getStatus())))
        {
            throw new ServiceException("矿机不存在或已停用。");
        }
        int minLevel = miner.getMinUserLevel() == null ? 0 : miner.getMinUserLevel();
        minLevel = Math.max(0, minLevel);
        int maxLevel = miner.getMaxUserLevel() == null ? 999 : miner.getMaxUserLevel();
        maxLevel = maxLevel <= 0 ? 999 : maxLevel;
        if (userLevel < minLevel || userLevel > maxLevel)
        {
            throw new ServiceException("当前等级不可领取该矿机。");
        }

        Date now = new Date();
        SysUserMiner existing = userMinerMapper.selectUserMinerByUserAndMiner(userId, minerId);
        Long currentUserMinerId;
        if (existing != null && existing.getUserMinerId() != null && existing.getUserMinerId() > 0)
        {
            currentUserMinerId = existing.getUserMinerId();
            if (StringUtils.equals(StringUtils.trim(existing.getIsCurrent()), "1"))
            {
                SysUserMinerRun activeRun = runMapper.selectActiveRunByUserIdForUpdate(userId);
                if (activeRun != null && activeRun.getRunId() != null && activeRun.getRunId() > 0
                        && activeRun.getMinerId() != null && activeRun.getUserMinerId() != null
                        && activeRun.getMinerId().longValue() == minerId.longValue()
                        && activeRun.getUserMinerId().longValue() == currentUserMinerId.longValue())
                {
                    return getOverview(userId);
                }
            }
        }
        else
        {
            SysUserMiner userMiner = new SysUserMiner();
            userMiner.setUserId(userId);
            userMiner.setMinerId(minerId);
            userMiner.setIsCurrent("1");
            userMiner.setClaimTime(now);
            userMiner.setActiveTime(now);
            userMiner.setTotalOutputWag(0D);
            userMiner.setStatus("0");
            userMinerMapper.insertUserMiner(userMiner);
            currentUserMinerId = userMiner.getUserMinerId();
        }
        if (currentUserMinerId == null || currentUserMinerId <= 0)
        {
            throw new ServiceException("领取失败，请稍后重试。");
        }

        userMinerMapper.updateUserCurrentMiner(userId, currentUserMinerId, now);
        runMapper.markRunEndedByUserId(userId, now);

        ensureWagWallet(userId);
        SysUserMinerRun run = buildNewRun(userId, currentUserMinerId, minerId, miner, now);
        runMapper.insertRun(run);

        SysMinerRewardLog startLog = new SysMinerRewardLog();
        startLog.setUserId(userId);
        startLog.setMinerId(minerId);
        startLog.setUserMinerId(currentUserMinerId);
        startLog.setRunId(run.getRunId());
        startLog.setRewardMode(run.getRewardMode());
        startLog.setAction("START");
        startLog.setWagAmount(0D);
        startLog.setPeriodStart(run.getStartTime());
        startLog.setPeriodEnd(run.getCycleEndTime());
        rewardLogMapper.insertRewardLog(startLog);

        evictMinerCaches(userId);
        return getOverview(userId);
    }

    @Override
    @Transactional
    public Map<String, Object> collectIfNeeded(Long userId)
    {
        Date now = new Date();
        SysUserMinerRun run = runMapper.selectActiveRunByUserIdForUpdate(userId);
        if (run == null || run.getRunId() == null || run.getRunId() <= 0)
        {
            return getOverview(userId);
        }
        if (!"1".equals(StringUtils.trim(run.getRunStatus())))
        {
            return getOverview(userId);
        }
        double produced = safeDouble(run.getProducedWag());
        if (produced <= 0D)
        {
            return getOverview(userId);
        }

        SysUserWagWallet wallet = ensureWagWalletForUpdate(userId);
        wallet.setAvailableWag(safeDouble(wallet.getAvailableWag()) + produced);
        wallet.setTotalEarnedWag(safeDouble(wallet.getTotalEarnedWag()) + produced);
        wagWalletMapper.updateWallet(wallet);

        SysUserMiner userMiner = userMinerMapper.selectUserMinerById(run.getUserMinerId());
        if (userMiner != null && userMiner.getUserMinerId() != null)
        {
            userMiner.setTotalOutputWag(safeDouble(userMiner.getTotalOutputWag()) + produced);
            userMinerMapper.updateUserMiner(userMiner);
        }

        SysMinerRewardLog log = new SysMinerRewardLog();
        log.setUserId(userId);
        log.setMinerId(run.getMinerId());
        log.setUserMinerId(run.getUserMinerId());
        log.setRunId(run.getRunId());
        log.setRewardMode(run.getRewardMode());
        log.setAction("MANUAL_COLLECT");
        log.setWagAmount(produced);
        log.setPeriodStart(run.getStartTime());
        log.setPeriodEnd(run.getCycleEndTime());
        rewardLogMapper.insertRewardLog(log);

        resetRunForNextCycle(run, now);
        run.setCollectTime(now);
        runMapper.updateRun(run);

        evictMinerCaches(userId);
        return getOverview(userId);
    }

    @Override
    @Transactional
    public Map<String, Object> exchangeWag(Long userId, String requestNo, double wagAmount)
    {
        String req = StringUtils.trim(requestNo);
        if (StringUtils.isEmpty(req))
        {
            throw new ServiceException("请求号不能为空。");
        }
        if (wagAmount <= 0D)
        {
            throw new ServiceException("兑换数量必须大于0。");
        }

        SysMinerExchangeLog existed = exchangeLogMapper.selectByRequestNo(req);
        if (existed != null && existed.getExchangeId() != null && existed.getExchangeId() > 0)
        {
            Map<String, Object> resp = new LinkedHashMap<>();
            resp.put("requestNo", existed.getRequestNo());
            resp.put("wagAmount", safeDouble(existed.getWagAmount()));
            resp.put("rate", safeDouble(existed.getRate()));
            resp.put("targetCurrency", existed.getTargetCurrency());
            resp.put("targetAmount", safeDouble(existed.getTargetAmount()));
            resp.put("status", existed.getStatus());
            return resp;
        }

        double wagToUsdRate = readDouble("app.miner.wagToUsdRate", 0.001D);
        int investMode = Convert.toInt(configService.selectConfigByKey("app.currency.investMode"), 1);
        double usdRate = readDouble("app.currency.usdRate", 7D);
        String targetCurrency = investMode == 1 ? "CNY" : "USD";

        SysMinerExchangeLog log = new SysMinerExchangeLog();
        log.setUserId(userId);
        log.setRequestNo(req);
        log.setWagAmount(wagAmount);
        log.setRate(wagToUsdRate);
        log.setTargetCurrency(targetCurrency);
        log.setTargetAmount(0D);
        log.setStatus("2");
        exchangeLogMapper.insertExchangeLog(log);

        try
        {
            SysUserWagWallet wagWallet = ensureWagWalletForUpdate(userId);
            double available = safeDouble(wagWallet.getAvailableWag());
            if (available < wagAmount)
            {
                throw new ServiceException("WAG余额不足。");
            }

            wagWallet.setAvailableWag(round8(available - wagAmount));
            wagWallet.setTotalExchangedWag(safeDouble(wagWallet.getTotalExchangedWag()) + wagAmount);
            wagWalletMapper.updateWallet(wagWallet);

            double usdAmount = round8(wagAmount * wagToUsdRate);
            double targetAmount = investMode == 1 ? round8(usdAmount * usdRate) : usdAmount;

            SysUserWallet currencyWallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(userId, targetCurrency);
            if (currencyWallet == null || currencyWallet.getWalletId() == null)
            {
                currencyWallet = new SysUserWallet();
                currencyWallet.setUserId(userId);
                currencyWallet.setCurrencyType(targetCurrency);
                currencyWallet.setTotalInvest(0D);
                currencyWallet.setAvailableBalance(0D);
                currencyWallet.setUsdExchangeQuota(0D);
                currencyWallet.setFrozenAmount(0D);
                currencyWallet.setProfitAmount(0D);
                currencyWallet.setPendingAmount(0D);
                currencyWallet.setTotalRecharge(0D);
                currencyWallet.setTotalWithdraw(0D);
                walletService.insertWallet(currencyWallet);
                currencyWallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(userId, targetCurrency);
            }

            double before = safeDouble(currencyWallet.getAvailableBalance());
            double delta = round2(targetAmount);
            double after = round2(before + delta);
            currencyWallet.setAvailableBalance(after);
            walletService.updateWallet(currencyWallet);

            SysUserWalletLog walletLog = new SysUserWalletLog();
            walletLog.setUserId(userId);
            walletLog.setWalletId(currencyWallet.getWalletId());
            walletLog.setCurrencyType(targetCurrency);
            walletLog.setAmount(delta);
            walletLog.setType("other");
            walletLog.setStatus("success");
            walletLog.setBalanceBefore(before);
            walletLog.setBalanceAfter(after);
            walletLog.setOrderNo(req);
            walletLog.setOperatorName(SecurityUtils.getUsername());
            walletLog.setRemark("WAG exchange");
            walletLogService.insertLog(walletLog);

            log.setTargetAmount(targetAmount);
            log.setStatus("0");
            exchangeLogMapper.updateExchangeLog(log);
            evictMinerCaches(userId);
        }
        catch (Exception e)
        {
            log.setStatus("1");
            log.setErrorMsg(StringUtils.left(String.valueOf(e.getMessage()), 480));
            exchangeLogMapper.updateExchangeLog(log);
            if (e instanceof ServiceException)
            {
                throw (ServiceException) e;
            }
            throw new ServiceException("兑换失败。");
        }

        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("requestNo", log.getRequestNo());
        resp.put("wagAmount", safeDouble(log.getWagAmount()));
        resp.put("rate", safeDouble(log.getRate()));
        resp.put("targetCurrency", log.getTargetCurrency());
        resp.put("targetAmount", safeDouble(log.getTargetAmount()));
        resp.put("status", log.getStatus());
        return resp;
    }

    @Override
    public List<Map<String, Object>> listRewardLogs(Long userId)
    {
        String cacheKey = CACHE_KEY_REWARD_LOGS_PREFIX + userId;
        List<Map<String, Object>> cached = redisCache.getCacheObject(cacheKey);
        if (cached != null)
        {
            return cached;
        }
        SysMinerRewardLog query = new SysMinerRewardLog();
        query.setUserId(userId);
        List<SysMinerRewardLog> list = rewardLogMapper.selectRewardLogList(query);
        List<Map<String, Object>> result = new ArrayList<>();
        if (list == null)
        {
            return result;
        }
        for (SysMinerRewardLog item : list)
        {
            if (item == null)
            {
                continue;
            }
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("logId", item.getLogId());
            row.put("minerId", item.getMinerId());
            row.put("userMinerId", item.getUserMinerId());
            row.put("runId", item.getRunId());
            row.put("rewardMode", item.getRewardMode());
            row.put("action", item.getAction());
            row.put("wagAmount", safeDouble(item.getWagAmount()));
            row.put("periodStart", item.getPeriodStart());
            row.put("periodEnd", item.getPeriodEnd());
            row.put("createTime", item.getCreateTime());
            row.put("remark", item.getRemark());
            result.add(row);
        }
        redisCache.setCacheObject(cacheKey, result, CACHE_EXPIRE_SHORT_MINUTES, TimeUnit.MINUTES);
        return result;
    }

    @Override
    public List<Map<String, Object>> listExchangeLogs(Long userId)
    {
        SysMinerExchangeLog query = new SysMinerExchangeLog();
        query.setUserId(userId);
        List<SysMinerExchangeLog> list = exchangeLogMapper.selectExchangeLogList(query);
        List<Map<String, Object>> result = new ArrayList<>();
        if (list == null)
        {
            return result;
        }
        for (SysMinerExchangeLog item : list)
        {
            if (item == null)
            {
                continue;
            }
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("exchangeId", item.getExchangeId());
            row.put("requestNo", item.getRequestNo());
            row.put("wagAmount", safeDouble(item.getWagAmount()));
            row.put("rate", safeDouble(item.getRate()));
            row.put("targetCurrency", item.getTargetCurrency());
            row.put("targetAmount", safeDouble(item.getTargetAmount()));
            row.put("status", item.getStatus());
            row.put("errorMsg", item.getErrorMsg());
            row.put("createTime", item.getCreateTime());
            row.put("updateTime", item.getUpdateTime());
            result.add(row);
        }
        return result;
    }

    private SysUserWagWallet ensureWagWallet(Long userId)
    {
        SysUserWagWallet wallet = wagWalletMapper.selectByUserId(userId);
        if (wallet != null)
        {
            return wallet;
        }
        SysUserWagWallet init = new SysUserWagWallet();
        init.setUserId(userId);
        init.setAvailableWag(0D);
        init.setTotalEarnedWag(0D);
        init.setTotalExchangedWag(0D);
        wagWalletMapper.insertWallet(init);
        return wagWalletMapper.selectByUserId(userId);
    }

    private SysUserWagWallet ensureWagWalletForUpdate(Long userId)
    {
        SysUserWagWallet wallet = wagWalletMapper.selectByUserIdForUpdate(userId);
        if (wallet != null)
        {
            return wallet;
        }
        SysUserWagWallet init = new SysUserWagWallet();
        init.setUserId(userId);
        init.setAvailableWag(0D);
        init.setTotalEarnedWag(0D);
        init.setTotalExchangedWag(0D);
        wagWalletMapper.insertWallet(init);
        return wagWalletMapper.selectByUserIdForUpdate(userId);
    }

    private SysUserMinerRun buildNewRun(Long userId, Long userMinerId, Long minerId, SysMiner miner, Date now)
    {
        SysUserMinerRun run = new SysUserMinerRun();
        run.setUserId(userId);
        run.setUserMinerId(userMinerId);
        run.setMinerId(minerId);
        run.setRewardMode(normalizeRewardMode(readString("app.miner.rewardMode", "AUTO")));
        run.setRunStatus("0");
        run.setStartTime(now);
        run.setCycleEndTime(new Date(now.getTime() + ONE_DAY_MS));
        run.setLastCalcTime(now);
        run.setCycleWag(safeDouble(miner == null ? null : miner.getWagPerDay()));
        run.setProducedWag(0D);
        run.setCreditedFlag("0");
        run.setVersion(0);
        return run;
    }

    private void resetRunForNextCycle(SysUserMinerRun run, Date now)
    {
        SysMiner miner = minerMapper.selectMinerById(run.getMinerId());
        run.setRewardMode(normalizeRewardMode(readString("app.miner.rewardMode", "AUTO")));
        run.setRunStatus("0");
        run.setStartTime(now);
        run.setCycleEndTime(new Date(now.getTime() + ONE_DAY_MS));
        run.setLastCalcTime(now);
        run.setCycleWag(safeDouble(miner == null ? null : miner.getWagPerDay()));
        run.setProducedWag(0D);
        run.setCreditedFlag("0");
        run.setVersion(run.getVersion() == null ? 0 : run.getVersion() + 1);
    }

    private Map<String, Object> buildMinerMap(SysUserMiner miner)
    {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("userMinerId", miner.getUserMinerId());
        map.put("minerId", miner.getMinerId());
        map.put("minerName", miner.getMinerName());
        map.put("minerLevel", miner.getMinerLevel());
        map.put("power", miner.getPower());
        map.put("wagPerDay", safeDouble(miner.getWagPerDay()));
        map.put("coverImage", miner.getCoverImage());
        map.put("totalOutputWag", safeDouble(miner.getTotalOutputWag()));
        map.put("isCurrent", StringUtils.equals(miner.getIsCurrent(), "1"));
        return map;
    }

    private Map<String, Object> buildRunMap(SysUserMinerRun run)
    {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("runId", run.getRunId());
        map.put("userMinerId", run.getUserMinerId());
        map.put("minerId", run.getMinerId());
        map.put("rewardMode", run.getRewardMode());
        map.put("runStatus", run.getRunStatus());
        map.put("startTime", run.getStartTime());
        map.put("cycleEndTime", run.getCycleEndTime());
        map.put("lastCalcTime", run.getLastCalcTime());
        map.put("cycleWag", safeDouble(run.getCycleWag()));
        map.put("producedWag", safeDouble(run.getProducedWag()));
        map.put("creditedFlag", run.getCreditedFlag());
        map.put("collectTime", run.getCollectTime());
        return map;
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

    private double readDouble(String key, double defaultValue)
    {
        return Convert.toDouble(configService.selectConfigByKey(key), defaultValue);
    }

    private double safeDouble(Double value)
    {
        return value == null ? 0D : value;
    }

    private double round8(double value)
    {
        return java.math.BigDecimal.valueOf(value).setScale(8, java.math.RoundingMode.DOWN).doubleValue();
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


    private double round2(double value)
    {
        return java.math.BigDecimal.valueOf(value).setScale(2, java.math.RoundingMode.HALF_UP).doubleValue();
    }
}
