package com.ruoyi.system.service.impl;

import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.core.domain.entity.SysUserPointAccount;
import com.ruoyi.common.core.domain.entity.SysUserPointLog;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.mapper.SysUserPointAccountMapper;
import com.ruoyi.system.mapper.SysUserPointLogMapper;
import com.ruoyi.system.service.ISysUserPointService;

/**
 * 用户积分账户服务实现
 */
@Service
public class SysUserPointServiceImpl implements ISysUserPointService {
    @Autowired
    private SysUserPointAccountMapper pointAccountMapper;

    @Autowired
    private SysUserPointLogMapper pointLogMapper;

    @Override
    public SysUserPointAccount selectPointAccountById(Long pointAccountId) {
        return pointAccountMapper.selectPointAccountById(pointAccountId);
    }

    @Override
    public SysUserPointAccount selectPointAccountByUserId(Long userId) {
        return pointAccountMapper.selectPointAccountByUserId(userId);
    }

    @Override
    public SysUserPointAccount selectPointAccountByUserIdAndUserName(Long userId, String userName) {
        return pointAccountMapper.selectPointAccountByUserIdAndUserName(userId, userName);
    }

    @Override
    public List<SysUserPointAccount> selectPointAccountList(SysUserPointAccount pointAccount) {
        return pointAccountMapper.selectPointAccountList(pointAccount);
    }

    @Override
    public int insertPointAccount(SysUserPointAccount pointAccount) {
        return pointAccountMapper.insertPointAccount(pointAccount);
    }

    @Override
    public int updatePointAccount(SysUserPointAccount pointAccount) {
        return pointAccountMapper.updatePointAccount(pointAccount);
    }

    @Override
    public int deletePointAccountById(Long pointAccountId) {
        return pointAccountMapper.deletePointAccountById(pointAccountId);
    }

    @Override
    public int deletePointAccountByIds(Long[] pointAccountIds) {
        return pointAccountMapper.deletePointAccountByIds(pointAccountIds);
    }

    @Override
    public SysUserPointAccount ensurePointAccount(Long userId, String userName) {
        if (userId == null || userId <= 0) {
            return null;
        }
        SysUserPointAccount pointAccount = pointAccountMapper.selectPointAccountByUserId(userId);
        if (pointAccount != null) {
            return pointAccount;
        }

        Date now = new Date();
        pointAccount = new SysUserPointAccount();
        pointAccount.setUserId(userId);
        pointAccount.setUserName(userName);
        pointAccount.setAvailablePoints(0L);
        pointAccount.setFrozenPoints(0L);
        pointAccount.setTotalEarned(0L);
        pointAccount.setTotalSpent(0L);
        pointAccount.setTotalAdjusted(0L);
        pointAccount.setCreateTime(now);
        pointAccount.setUpdateTime(now);
        pointAccountMapper.insertPointAccount(pointAccount);
        return pointAccountMapper.selectPointAccountByUserId(userId);
    }

    @Override
    @Transactional
    public int grantPoints(Long userId, String userName, Long points, String sourceType, Long sourceId, String sourceNo, String remark) {
        return applyPointsChange(userId, userName, points, "earn", sourceType, sourceId, sourceNo, remark);
    }

    @Override
    @Transactional
    public int grantInvestPoints(Long userId, String userName, Long points, Long sourceId, String sourceNo, String remark) {
        return applyPointsChange(userId, userName, points, "earn", "invest", sourceId, sourceNo, remark);
    }

    @Override
    @Transactional
    public int grantActivityPoints(Long userId, String userName, Long points, Long sourceId, String sourceNo, String remark) {
        return applyPointsChange(userId, userName, points, "earn", "activity", sourceId, sourceNo, remark);
    }

    @Override
    @Transactional
    public int spendPoints(Long userId, String userName, Long points, String sourceType, Long sourceId, String sourceNo, String remark) {
        return applyPointsChange(userId, userName, points, "spend", sourceType, sourceId, sourceNo, remark);
    }

    @Override
    @Transactional
    public int adjustPoints(Long userId, String userName, Long points, String sourceType, Long sourceId, String sourceNo, String remark) {
        return applyPointsChange(userId, userName, points, "adjust", sourceType, sourceId, sourceNo, remark);
    }

    private int applyPointsChange(Long userId, String userName, Long points, String changeType, String sourceType, Long sourceId, String sourceNo, String remark) {
        if (userId == null || userId <= 0 || points == null || points == 0) {
            return 0;
        }
        long absolutePoints = Math.abs(points);
        if (absolutePoints == 0) {
            return 0;
        }

        SysUserPointAccount pointAccount = ensurePointAccount(userId, userName);
        if (pointAccount == null || pointAccount.getPointAccountId() == null) {
            return 0;
        }

        Date now = new Date();
        long before = safeLong(pointAccount.getAvailablePoints());
        long after = before;
        int rows;
        if ("spend".equalsIgnoreCase(changeType)) {
            rows = pointAccountMapper.deductPoints(pointAccount.getPointAccountId(), absolutePoints, absolutePoints);
            if (rows <= 0) {
                return 0;
            }
            after = before - absolutePoints;
            pointAccount.setTotalSpent(safeLong(pointAccount.getTotalSpent()) + absolutePoints);
        } else {
            rows = pointAccountMapper.increasePoints(
                pointAccount.getPointAccountId(),
                absolutePoints,
                "earn".equalsIgnoreCase(changeType) ? absolutePoints : 0L,
                "adjust".equalsIgnoreCase(changeType) ? absolutePoints : 0L,
                0L
            );
            if (rows <= 0) {
                return 0;
            }
            after = before + absolutePoints;
            if ("earn".equalsIgnoreCase(changeType)) {
                pointAccount.setTotalEarned(safeLong(pointAccount.getTotalEarned()) + absolutePoints);
            } else {
                pointAccount.setTotalAdjusted(safeLong(pointAccount.getTotalAdjusted()) + absolutePoints);
            }
        }

        pointAccount.setAvailablePoints(after);
        pointAccount.setUpdateTime(now);
        pointAccountMapper.updatePointAccount(pointAccount);

        SysUserPointLog log = new SysUserPointLog();
        log.setPointAccountId(pointAccount.getPointAccountId());
        log.setUserId(userId);
        log.setUserName(StringUtils.isNotBlank(userName) ? userName : pointAccount.getUserName());
        log.setPoints("spend".equalsIgnoreCase(changeType) ? -absolutePoints : absolutePoints);
        log.setPointsBefore(before);
        log.setPointsAfter(after);
        log.setChangeType(changeType);
        log.setSourceType(sourceType);
        log.setSourceId(sourceId);
        log.setSourceNo(sourceNo);
        log.setStatus("success");
        String operatorName = SecurityUtils.getUsername();
        log.setOperatorName(StringUtils.isNotBlank(operatorName) ? operatorName : "system");
        log.setRemark(remark);
        log.setCreateTime(now);
        log.setUpdateTime(now);
        pointLogMapper.insertPointLog(log);
        return 1;
    }

    private long safeLong(Long value) {
        return value == null ? 0L : value;
    }
}
