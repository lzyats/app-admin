package com.ruoyi.system.service.impl;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.core.domain.entity.SysUserSignLog;
import com.ruoyi.common.core.domain.entity.SysUserWallet;
import com.ruoyi.common.core.domain.entity.SysUserWalletLog;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import com.ruoyi.system.mapper.SysUserSignLogMapper;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysUserPointService;
import com.ruoyi.system.service.ISysUserSignService;
import com.ruoyi.system.service.ISysUserWalletLogService;
import com.ruoyi.system.service.ISysUserWalletService;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 用户签到服务实现
 */
@Service
public class SysUserSignServiceImpl implements ISysUserSignService {
    private static final String CACHE_KEY_PREFIX = "app:sign:today:";
    private static final String LOCK_KEY_PREFIX = "app:sign:lock:";
    private static final String HISTORY_CACHE_PREFIX = "app:sign:history:";

    @Autowired
    private SysUserSignLogMapper signLogMapper;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ISysUserPointService pointService;

    @Autowired
    private ISysUserWalletService walletService;

    @Autowired
    private ISysUserWalletLogService walletLogService;

    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    private volatile boolean signLogTableReady = false;

    @Override
    public Map<String, Object> getTodayStatus(Long userId, String userName) {
        if (userId == null || userId <= 0) {
            return buildEmptyStatus();
        }
        ensureSignLogTable();
        final String today = DateUtils.getDate();
        final String cacheKey = buildStatusCacheKey(userId);
        String cached = stringRedisTemplate.opsForValue().get(cacheKey);
        if (StringUtils.isNotBlank(cached)) {
            try {
                Map<String, Object> cachedMap = JSON.parseObject(cached, Map.class);
                cachedMap.put("records", loadHistory(userId));
                return cachedMap;
            } catch (Exception ignored) {
                stringRedisTemplate.delete(cacheKey);
            }
        }
        Map<String, Object> status = buildStatus(userId, today);
        cacheStatus(userId, status, false);
        return status;
    }

    @Override
    @Transactional
    public Map<String, Object> signToday(Long userId, String userName) {
        if (userId == null || userId <= 0) {
            return buildEmptyStatus();
        }
        ensureSignLogTable();
        final String today = DateUtils.getDate();
        final String lockKey = buildLockKey(userId);
        Boolean locked = stringRedisTemplate.opsForValue().setIfAbsent(lockKey, "1", 10, TimeUnit.SECONDS);
        if (locked == null || !locked) {
            throw new IllegalStateException("签到处理中，请稍后重试。");
        }
        try {
            Map<String, Object> current = getTodayStatus(userId, userName);
            if (Boolean.TRUE.equals(current.get("signedToday"))) {
                return current;
            }

            SysUserSignLog latest = signLogMapper.selectLatestSignLogByUserId(userId);
            SysUserSignLog todayLog = signLogMapper.selectSignLogByUserIdAndSignDate(userId, today);
            if (todayLog != null) {
                Map<String, Object> existing = buildStatus(userId, today);
                cacheStatus(userId, existing, true);
                return existing;
            }

            int consecutiveDays = calculateConsecutiveDays(latest, today) + 1;
            BigDecimal rewardAmount = resolveRewardAmount(consecutiveDays);
            String rewardType = normalizeRewardType(readString("app.sign.rewardType", "POINT"));
            String sourceNo = generateSourceNo();
            Date now = new Date();
            Date signDate = DateUtils.toDate(LocalDate.now());
            if ("MONEY".equalsIgnoreCase(rewardType)) {
                applyMoneyReward(userId, userName, rewardAmount, sourceNo, now);
            } else {
                applyPointReward(userId, userName, rewardAmount, sourceNo, now);
            }

            SysUserSignLog signLog = new SysUserSignLog();
            signLog.setUserId(userId);
            signLog.setUserName(userName);
            signLog.setSignDate(signDate);
            signLog.setConsecutiveDays(consecutiveDays);
            signLog.setRewardType(rewardType);
            signLog.setRewardAmount(rewardAmount.setScale(2, RoundingMode.HALF_UP).doubleValue());
            signLog.setSourceType("sign");
            signLog.setSourceNo(sourceNo);
            signLog.setStatus("success");
            signLog.setRemark("Daily sign-in reward");
            signLog.setCreateTime(now);
            signLog.setUpdateTime(now);
            signLogMapper.insertSignLog(signLog);

            Map<String, Object> response = buildStatus(userId, today);
            response.put("signedToday", true);
            response.put("consecutiveDays", consecutiveDays);
            response.put("rewardType", rewardType);
            response.put("rewardAmount", rewardAmount.setScale(2, RoundingMode.HALF_UP).doubleValue());
            response.put("rewardLabel", rewardLabel(rewardType));
            response.put("records", mergeLatestRecord(signLog, response));
            cacheStatus(userId, response, true);
            return response;
        } finally {
            stringRedisTemplate.delete(lockKey);
        }
    }

    @Override
    public List<SysUserSignLog> selectSignLogList(SysUserSignLog signLog) {
        return signLogMapper.selectSignLogList(signLog);
    }

    private Map<String, Object> buildStatus(Long userId, String today) {
        ensureSignLogTable();
        SysUserSignLog latest = signLogMapper.selectLatestSignLogByUserId(userId);
        SysUserSignLog todayLog = signLogMapper.selectSignLogByUserIdAndSignDate(userId, today);
        boolean signedToday = todayLog != null;
        int consecutiveDays = signedToday
            ? safeInt(todayLog.getConsecutiveDays())
            : calculateConsecutiveDays(latest, today);
        String rewardType = normalizeRewardType(readString("app.sign.rewardType", "POINT"));
        BigDecimal rewardAmount = signedToday && todayLog.getRewardAmount() != null
            ? BigDecimal.valueOf(todayLog.getRewardAmount())
            : resolveRewardAmount(consecutiveDays + 1);
        List<SysUserSignLog> records = loadHistory(userId);
        Map<String, Object> result = new LinkedHashMap<String, Object>();
        result.put("signedToday", signedToday);
        result.put("consecutiveDays", consecutiveDays);
        result.put("rewardType", rewardType);
        result.put("rewardAmount", rewardAmount.setScale(2, RoundingMode.HALF_UP).doubleValue());
        result.put("rewardLabel", rewardLabel(rewardType));
        result.put("records", records);
        return result;
    }

    @SuppressWarnings("unchecked")
    private List<SysUserSignLog> loadHistory(Long userId) {
        String historyKey = buildHistoryCacheKey(userId);
        String cached = stringRedisTemplate.opsForValue().get(historyKey);
        if (StringUtils.isNotBlank(cached)) {
            try {
                return JSON.parseArray(cached, SysUserSignLog.class);
            } catch (Exception ignored) {
                stringRedisTemplate.delete(historyKey);
            }
        }
        List<SysUserSignLog> records = signLogMapper.selectRecentSignLogList(userId, 10);
        if (records == null) {
            records = Collections.emptyList();
        }
        cacheHistory(userId, records);
        return records;
    }

    private List<SysUserSignLog> mergeLatestRecord(SysUserSignLog signLog, Map<String, Object> response) {
        List<SysUserSignLog> records = new ArrayList<SysUserSignLog>();
        records.add(signLog);
        Object rawRecords = response.get("records");
        if (rawRecords instanceof List<?>) {
            for (Object item : (List<?>) rawRecords) {
                if (item instanceof SysUserSignLog) {
                    SysUserSignLog log = (SysUserSignLog) item;
                    if (!StringUtils.equals(signLog.getSourceNo(), log.getSourceNo())) {
                        records.add(log);
                    }
                }
            }
        }
        if (records.size() > 10) {
            return new ArrayList<SysUserSignLog>(records.subList(0, 10));
        }
        return records;
    }

    private void applyPointReward(Long userId, String userName, BigDecimal rewardAmount, String sourceNo, Date now) {
        long points = rewardAmount.setScale(0, RoundingMode.HALF_UP).longValue();
        if (points <= 0) {
            points = 1L;
        }
        pointService.grantPoints(userId, userName, points, "sign", null, sourceNo, "Daily sign-in reward");
    }

    private void applyMoneyReward(Long userId, String userName, BigDecimal rewardAmount, String sourceNo, Date now) {
        SysUserWallet wallet = ensureWalletForUpdate(userId, userName, "CNY");
        BigDecimal before = moneyOf(wallet.getAvailableBalance());
        BigDecimal after = before.add(rewardAmount).setScale(2, RoundingMode.HALF_UP);
        wallet.setAvailableBalance(after.doubleValue());
        wallet.setUpdateTime(now);
        walletService.updateWallet(wallet);

        SysUserWalletLog log = new SysUserWalletLog();
        log.setUserId(wallet.getUserId());
        log.setWalletId(wallet.getWalletId());
        log.setCurrencyType(wallet.getCurrencyType());
        log.setAmount(rewardAmount.doubleValue());
        log.setType("sign_reward");
        log.setStatus("success");
        log.setBalanceBefore(before.doubleValue());
        log.setBalanceAfter(after.doubleValue());
        log.setOrderNo(sourceNo);
        log.setOperatorName(userName);
        log.setRemark("Daily sign-in reward");
        log.setCreateTime(now);
        log.setUpdateTime(now);
        walletLogService.insertLog(log);
    }

    private SysUserWallet ensureWalletForUpdate(Long userId, String userName, String currencyType) {
        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(userId, currencyType);
        if (wallet != null) {
            return wallet;
        }
        SysUserWallet created = new SysUserWallet();
        created.setUserId(userId);
        created.setUserName(userName);
        created.setCurrencyType(currencyType);
        created.setTotalInvest(0D);
        created.setAvailableBalance(0D);
        created.setUsdExchangeQuota(0D);
        created.setFrozenAmount(0D);
        created.setProfitAmount(0D);
        created.setPendingAmount(0D);
        created.setTotalRecharge(0D);
        created.setTotalWithdraw(0D);
        created.setCreateTime(new Date());
        created.setUpdateTime(new Date());
        walletService.insertWallet(created);
        return walletService.selectWalletByUserIdAndCurrencyTypeForUpdate(userId, currencyType);
    }

    private int calculateConsecutiveDays(SysUserSignLog latest, String today) {
        if (latest == null || latest.getSignDate() == null) {
            return 0;
        }
        String latestDate = DateUtils.dateTime(latest.getSignDate());
        String yesterday = DateUtils.dateTime(DateUtils.toDate(LocalDate.now().minusDays(1)));
        if (StringUtils.equals(latestDate, yesterday)) {
            return safeInt(latest.getConsecutiveDays());
        }
        if (StringUtils.equals(latestDate, today)) {
            return safeInt(latest.getConsecutiveDays());
        }
        return 0;
    }

    private BigDecimal resolveRewardAmount(int consecutiveDays) {
        List<RewardRule> rules = parseRewardRules(readString("app.sign.continuousRewardRule", "[]"));
        if (rules.isEmpty()) {
            return moneyOf(readDouble("app.sign.rewardAmount", 1.0D));
        }
        RewardRule selected = rules.get(0);
        for (RewardRule rule : rules) {
            if (consecutiveDays >= rule.day) {
                selected = rule;
            } else {
                break;
            }
        }
        return selected.amount;
    }

    private List<RewardRule> parseRewardRules(String raw) {
        if (StringUtils.isBlank(raw)) {
            return Collections.emptyList();
        }
        try {
            JSONArray array = JSON.parseArray(raw);
            if (array == null || array.isEmpty()) {
                return Collections.emptyList();
            }
            List<RewardRule> rules = new ArrayList<RewardRule>();
            for (int i = 0; i < array.size(); i++) {
                JSONObject object = array.getJSONObject(i);
                if (object == null) {
                    continue;
                }
                int day = object.getIntValue("day");
                BigDecimal amount = moneyOf(object.getBigDecimal("amount") == null ? 0D : object.getBigDecimal("amount").doubleValue());
                if (day > 0) {
                    rules.add(new RewardRule(day, amount));
                }
            }
            rules.sort(Comparator.comparingInt(rule -> rule.day));
            return rules;
        } catch (Exception ignored) {
            return Collections.emptyList();
        }
    }

    private String rewardLabel(String rewardType) {
        return "POINT".equalsIgnoreCase(rewardType) ? "积分" : "元";
    }

    private void cacheStatus(Long userId, Map<String, Object> status, boolean signedToday) {
        String cacheKey = buildStatusCacheKey(userId);
        String json = JSON.toJSONString(status);
        long ttl = signedToday ? secondsUntilTomorrow() : TimeUnit.MINUTES.toSeconds(5);
        stringRedisTemplate.opsForValue().set(cacheKey, json, ttl, TimeUnit.SECONDS);
        cacheHistory(userId, castRecords(status.get("records")));
    }

    private void cacheHistory(Long userId, List<SysUserSignLog> records) {
        if (records == null) {
            return;
        }
        String historyKey = buildHistoryCacheKey(userId);
        stringRedisTemplate.opsForValue().set(historyKey, JSON.toJSONString(records), 30, TimeUnit.MINUTES);
    }

    @SuppressWarnings("unchecked")
    private List<SysUserSignLog> castRecords(Object records) {
        if (records instanceof List<?>) {
            List<SysUserSignLog> list = new ArrayList<SysUserSignLog>();
            for (Object item : (List<?>) records) {
                if (item instanceof SysUserSignLog) {
                    list.add((SysUserSignLog) item);
                } else if (item instanceof Map) {
                    list.add(JSON.parseObject(JSON.toJSONString(item), SysUserSignLog.class));
                }
            }
            return list;
        }
        return Collections.emptyList();
    }

    private Map<String, Object> buildEmptyStatus() {
        Map<String, Object> empty = new LinkedHashMap<String, Object>();
        empty.put("signedToday", false);
        empty.put("consecutiveDays", 0);
        empty.put("rewardType", normalizeRewardType(readString("app.sign.rewardType", "POINT")));
        empty.put("rewardAmount", readDouble("app.sign.rewardAmount", 1.0D));
        empty.put("rewardLabel", rewardLabel((String) empty.get("rewardType")));
        empty.put("records", Collections.emptyList());
        return empty;
    }

    private String buildStatusCacheKey(Long userId) {
        return CACHE_KEY_PREFIX + userId + ":" + DateUtils.getDate();
    }

    private String buildHistoryCacheKey(Long userId) {
        return HISTORY_CACHE_PREFIX + userId;
    }

    private void ensureSignLogTable() {
        if (signLogTableReady) {
            return;
        }
        synchronized (this) {
            if (signLogTableReady) {
                return;
            }
            try {
                signLogMapper.createTableIfNotExists();
                signLogTableReady = true;
            } catch (Exception ignored) {
                // 下一次进入再尝试，避免把一次临时数据库故障永久记为已就绪。
            }
        }
    }

    private String buildLockKey(Long userId) {
        return LOCK_KEY_PREFIX + userId + ":" + DateUtils.getDate();
    }

    private long secondsUntilTomorrow() {
        LocalDate tomorrow = LocalDate.now().plusDays(1);
        long seconds = java.time.Duration.between(java.time.LocalDateTime.now(), tomorrow.atStartOfDay()).getSeconds();
        return Math.max(seconds, 60L);
    }

    private int safeInt(Integer value) {
        return value == null ? 0 : value;
    }

    private String normalizeRewardType(String rewardType) {
        if (StringUtils.isBlank(rewardType)) {
            return "POINT";
        }
        String normalized = rewardType.trim().toUpperCase();
        return "MONEY".equals(normalized) ? "MONEY" : "POINT";
    }

    private String readString(String key, String defaultValue) {
        String raw = StringUtils.trim(configService.selectConfigByKey(key));
        return StringUtils.isEmpty(raw) ? defaultValue : raw;
    }

    private double readDouble(String key, double defaultValue) {
        String raw = StringUtils.trim(configService.selectConfigByKey(key));
        if (StringUtils.isEmpty(raw)) {
            return defaultValue;
        }
        try {
            return Double.parseDouble(raw);
        } catch (NumberFormatException ignored) {
            return defaultValue;
        }
    }

    private BigDecimal moneyOf(double value) {
        return BigDecimal.valueOf(value).setScale(2, RoundingMode.HALF_UP);
    }

    private String generateSourceNo() {
        return "SG" + DateUtils.dateTimeNow() + IdUtils.fastSimpleUUID().substring(0, 8).toUpperCase();
    }

    private static final class RewardRule {
        private final int day;
        private final BigDecimal amount;

        private RewardRule(int day, BigDecimal amount) {
            this.day = day;
            this.amount = amount == null ? BigDecimal.ZERO : amount.setScale(2, RoundingMode.HALF_UP);
        }
    }
}
