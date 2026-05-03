package com.ruoyi.system.service.impl;

import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.entity.SysUserGrowthLog;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysUserLevel;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.service.ISysUserGrowthLogService;
import com.ruoyi.system.service.ISysGrowthValueService;
import com.ruoyi.system.service.ISysUserLevelService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;

/**
 * 成长值 服务层实现
 * 
 * @author ruoyi
 */
@Service
public class SysGrowthValueServiceImpl implements ISysGrowthValueService {

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private ISysUserLevelService userLevelService; // 注入用户等级服务，用于获取缓存的等级列表

    @Autowired
    private ISysUserGrowthLogService growthLogService;

    @Override
    @Transactional
    public boolean increaseGrowthValue(Long userId, Long growthValue, String sourceType, Long sourceId, String sourceNo, String remark) {
        return changeGrowthValue(userId, growthValue, "increase", sourceType, sourceId, sourceNo, remark);
    }

    @Override
    @Transactional
    public boolean decreaseGrowthValue(Long userId, Long growthValue, String sourceType, Long sourceId, String sourceNo, String remark) {
        return changeGrowthValue(userId, growthValue, "decrease", sourceType, sourceId, sourceNo, remark);
    }

    @Override
    @Transactional
    public boolean checkAndUpgradeUserLevel(Long userId, Long currentGrowthValue) {
        SysUser user = userMapper.selectUserBaseById(userId);
        if (user == null) {
            return false;
        }

        // 获取所有启用的会员等级，并按成长值要求降序排列
        SysUserLevel query = new SysUserLevel();
        query.setStatus("0"); // 启用状态
        List<SysUserLevel> levels = userLevelService.selectEnabledOptionsCached(); // 使用缓存获取等级列表

        if (levels == null || levels.isEmpty()) {
            return false;
        }

        // 找到用户当前成长值可以达到的最高等级
        Integer bestLevel = user.getLevel() == null ? 0 : user.getLevel();
        for (SysUserLevel level : levels) {
            if (level == null || level.getLevel() == null) {
                continue;
            }
            Long required = level.getRequiredGrowthValue() == null ? 0L : level.getRequiredGrowthValue();
            if (currentGrowthValue >= required) {
                if (level.getLevel() > bestLevel) {
                    bestLevel = level.getLevel();
                }
            }
        }

        // 如果用户的当前等级低于其应达到的最高等级，则进行升级
        if (bestLevel != null && !bestLevel.equals(user.getLevel())) {
            userMapper.updateUserLevelValue(userId, bestLevel);
            // TODO: 记录等级变动日志
            return true;
        }
        return false;
    }

    private boolean changeGrowthValue(Long userId, Long growthValue, String changeType,
                                      String sourceType, Long sourceId, String sourceNo, String remark)
    {
        if (userId == null || growthValue == null || growthValue <= 0)
        {
            throw new ServiceException("用户ID或成长值无效");
        }
        SysUser user = userMapper.selectUserBaseByIdForUpdate(userId);
        if (user == null)
        {
            throw new ServiceException("用户不存在");
        }

        Long beforeValue = user.getGrowthValue() == null ? 0L : user.getGrowthValue();
        Long delta = "decrease".equalsIgnoreCase(changeType) ? -growthValue : growthValue;
        Long afterValue = beforeValue + delta;
        if (afterValue < 0)
        {
            throw new ServiceException("成长值不足，无法扣除");
        }

        user.setGrowthValue(afterValue);
        int rows = userMapper.updateUserGrowthValue(user);
        if (rows <= 0)
        {
            return false;
        }

        // 每次成长值变化都统一执行升级检查并同步用户等级信息
        checkAndUpgradeUserLevel(userId, afterValue);
        recordGrowthLog(user, delta, beforeValue, afterValue, changeType, sourceType, sourceId, sourceNo, remark);
        return true;
    }

    private void recordGrowthLog(SysUser user, Long changeValue, Long beforeValue, Long afterValue,
                                 String changeType, String sourceType, Long sourceId, String sourceNo, String remark) {
        SysUserGrowthLog log = new SysUserGrowthLog();
        log.setUserId(user.getUserId());
        log.setUserName(user.getUserName());
        log.setChangeValue(changeValue);
        log.setGrowthValueBefore(beforeValue);
        log.setGrowthValueAfter(afterValue);
        log.setChangeType(changeType);
        log.setSourceType(StringUtils.isBlank(sourceType) ? "manual" : sourceType);
        log.setSourceId(sourceId);
        log.setSourceNo(sourceNo);
        log.setStatus("success");
        String operator;
        try {
            operator = SecurityUtils.getUsername();
        } catch (Exception ex) {
            operator = "system";
        }
        log.setOperatorName(StringUtils.isBlank(operator) ? "system" : operator);
        log.setRemark(remark);
        Date now = new Date();
        log.setCreateTime(now);
        log.setUpdateTime(now);
        growthLogService.insertGrowthLog(log);
    }
}
