package com.ruoyi.system.service.impl;

import java.math.BigDecimal;
import java.util.List;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.system.domain.SysTeamLevel;
import com.ruoyi.system.mapper.SysTeamLevelMapper;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.service.ISysTeamLevelService;

@Service
public class SysTeamLevelServiceImpl implements ISysTeamLevelService
{
    private static final String CACHE_KEY_OPTIONS = "team:level:options";
    private static final Integer CACHE_EXPIRE_MINUTES = 30;

    @Autowired
    private SysTeamLevelMapper teamLevelMapper;

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private RedisCache redisCache;

    @Override
    public SysTeamLevel selectTeamLevelById(Long teamLevelId)
    {
        return teamLevelMapper.selectTeamLevelById(teamLevelId);
    }

    @Override
    public List<SysTeamLevel> selectTeamLevelList(SysTeamLevel teamLevel)
    {
        return teamLevelMapper.selectTeamLevelList(teamLevel);
    }

    @Override
    public List<SysTeamLevel> selectEnabledOptionsCached()
    {
        List<SysTeamLevel> cached = redisCache.getCacheObject(CACHE_KEY_OPTIONS);
        if (cached != null)
        {
            return cached;
        }
        SysTeamLevel query = new SysTeamLevel();
        query.setStatus("0");
        List<SysTeamLevel> list = teamLevelMapper.selectTeamLevelList(query);
        redisCache.setCacheObject(CACHE_KEY_OPTIONS, list, CACHE_EXPIRE_MINUTES, TimeUnit.MINUTES);
        return list;
    }

    @Override
    public int insertTeamLevel(SysTeamLevel teamLevel)
    {
        int rows = teamLevelMapper.insertTeamLevel(teamLevel);
        if (rows > 0)
        {
            clearCache();
        }
        return rows;
    }

    @Override
    public int updateTeamLevel(SysTeamLevel teamLevel)
    {
        int rows = teamLevelMapper.updateTeamLevel(teamLevel);
        if (rows > 0)
        {
            clearCache();
        }
        return rows;
    }

    @Override
    public int deleteTeamLevelByIds(Long[] teamLevelIds)
    {
        int rows = teamLevelMapper.deleteTeamLevelByIds(teamLevelIds);
        if (rows > 0)
        {
            clearCache();
        }
        return rows;
    }

    @Override
    @Transactional
    public boolean checkAndUpgradeUserTeamLevel(Long userId)
    {
        if (userId == null)
        {
            return false;
        }
        SysUser user = userMapper.selectUserBaseByIdForUpdate(userId);
        if (user == null)
        {
            return false;
        }

        Integer current = user.getTeamLeaderLevel() == null ? 0 : user.getTeamLeaderLevel();
        Integer userLevel = user.getLevel() == null ? 0 : user.getLevel();
        int directValidUsers = teamLevelMapper.countDirectValidUsers(userId);
        int teamValidUsers = teamLevelMapper.countTeamValidUsers(userId);
        BigDecimal teamInvest = teamLevelMapper.sumTeamInvestAmount(userId);
        if (teamInvest == null)
        {
            teamInvest = BigDecimal.ZERO;
        }

        Integer target = current;
        List<SysTeamLevel> levels = selectEnabledOptionsCached();
        for (SysTeamLevel cfg : levels)
        {
            Integer cfgLevel = cfg.getTeamLevel() == null ? 0 : cfg.getTeamLevel();
            Integer needUserLevel = cfg.getRequiredUserLevel() == null ? 0 : cfg.getRequiredUserLevel();
            Integer needDirectUsers = cfg.getRequiredDirectUsers() == null ? 0 : cfg.getRequiredDirectUsers();
            Integer needTeamUsers = cfg.getRequiredTeamUsers() == null ? 0 : cfg.getRequiredTeamUsers();
            BigDecimal needTeamInvest = cfg.getRequiredTeamInvest() == null ? BigDecimal.ZERO : cfg.getRequiredTeamInvest();

            boolean pass = userLevel >= needUserLevel
                && directValidUsers >= needDirectUsers
                && teamValidUsers >= needTeamUsers
                && teamInvest.compareTo(needTeamInvest) >= 0;
            if (pass && cfgLevel > target)
            {
                target = cfgLevel;
            }
        }

        if (target > current)
        {
            teamLevelMapper.updateUserTeamLeaderLevel(userId, target);
            user.setTeamLeaderLevel(target);
            return true;
        }
        return false;
    }

    @Override
    public void clearCache()
    {
        redisCache.deleteObject(CACHE_KEY_OPTIONS);
    }
}
