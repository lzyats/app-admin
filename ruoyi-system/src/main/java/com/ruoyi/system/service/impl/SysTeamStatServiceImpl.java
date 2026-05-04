package com.ruoyi.system.service.impl;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysConfig;
import com.ruoyi.system.domain.SysTeamStatEvent;
import com.ruoyi.system.domain.SysTeamStatUser;
import com.ruoyi.system.mapper.SysTeamStatMapper;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysTeamStatService;

@Service
public class SysTeamStatServiceImpl implements ISysTeamStatService
{
    private static final String CONFIG_CALC_DEPTH = "team.stats.calc.depth";
    private static final String CONFIG_LAST_CALC_DATE = "team.stats.last.calc.date";
    private static final String CONFIG_YEBAO_LEVEL_BONUS_ENABLED = "app.yebao.levelBonusEnabled";

    @Autowired
    private SysTeamStatMapper teamStatMapper;

    @Autowired
    private ISysConfigService configService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void rebuildDailyStats(Date statDate)
    {
        LocalDate targetDate = resolveTargetDate(statDate);
        Date statDay = toDate(targetDate.atStartOfDay());
        Date dayEnd = toDate(LocalDateTime.of(targetDate, LocalTime.MAX));
        Integer calcDepth = getCalcDepth();
        boolean yebaoLevelBonusEnabled = isYebaoLevelBonusEnabled();

        teamStatMapper.clearTeamRelation();
        teamStatMapper.insertTeamRelationFromUser();

        teamStatMapper.deleteEventsByDate(statDay);
        teamStatMapper.insertRegisterEvents(statDay, calcDepth);
        teamStatMapper.insertRechargeEvents(statDay, calcDepth);
        teamStatMapper.insertInvestEvents(statDay, calcDepth, yebaoLevelBonusEnabled);

        teamStatMapper.deleteDailyByDate(statDay);
        teamStatMapper.buildDailySnapshot(statDay, calcDepth, dayEnd, yebaoLevelBonusEnabled);
        teamStatMapper.refreshUserSnapshot(statDay);

        saveLastCalcDate(targetDate);
    }

    @Override
    public List<SysTeamStatUser> selectTeamStatUserList(SysTeamStatUser query)
    {
        return teamStatMapper.selectTeamStatUserList(query);
    }

    @Override
    public List<SysTeamStatEvent> selectTeamStatEventList(SysTeamStatEvent query)
    {
        return teamStatMapper.selectTeamStatEventList(query);
    }

    @Override
    public void recordInvestOrderEvent(Long memberUserId, Long orderId, BigDecimal investAmount, Date eventTime)
    {
        if (memberUserId == null || memberUserId <= 0L || orderId == null || orderId <= 0L)
        {
            return;
        }
        if (investAmount == null || investAmount.compareTo(BigDecimal.ZERO) <= 0)
        {
            return;
        }
        Date safeEventTime = eventTime == null ? new Date() : eventTime;
        teamStatMapper.insertInvestOrderEvents(memberUserId, orderId, investAmount, safeEventTime, getCalcDepth());
    }

    @Override
    public void revokeInvestOrderEvent(Long orderId)
    {
        if (orderId == null || orderId <= 0L)
        {
            return;
        }
        teamStatMapper.deleteInvestOrderEvents(orderId);
    }

    @Override
    public Integer getCalcDepth()
    {
        String val = configService.selectConfigByKey(CONFIG_CALC_DEPTH);
        int defaultDepth = 3;
        if (StringUtils.isBlank(val))
        {
            return defaultDepth;
        }
        try
        {
            int parsed = Integer.parseInt(val.trim());
            if (parsed < 1)
            {
                return 1;
            }
            return Math.min(parsed, 20);
        }
        catch (Exception ex)
        {
            return defaultDepth;
        }
    }

    private void saveLastCalcDate(LocalDate targetDate)
    {
        SysConfig config = new SysConfig();
        config.setConfigName("团队统计-最近统计日期");
        config.setConfigKey(CONFIG_LAST_CALC_DATE);
        config.setConfigValue(targetDate.format(DateTimeFormatter.ISO_LOCAL_DATE));
        config.setConfigType("N");
        config.setIsAppConfig("0");
        config.setRemark("夜间统计任务自动更新");
        List<SysConfig> list = new ArrayList<SysConfig>();
        list.add(config);
        configService.batchSaveConfig("system", list);
    }

    private LocalDate resolveTargetDate(Date statDate)
    {
        if (statDate == null)
        {
            return LocalDate.now().minusDays(1);
        }
        return statDate.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
    }

    private Date toDate(LocalDateTime dateTime)
    {
        return Date.from(dateTime.atZone(ZoneId.systemDefault()).toInstant());
    }

    private boolean isYebaoLevelBonusEnabled()
    {
        try
        {
            String raw = configService.selectConfigByKey(CONFIG_YEBAO_LEVEL_BONUS_ENABLED);
            return "true".equalsIgnoreCase(StringUtils.trim(raw)) || "1".equals(StringUtils.trim(raw));
        }
        catch (Exception ex)
        {
            return false;
        }
    }
}
