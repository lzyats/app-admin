package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.common.core.domain.entity.SysUserPointAccount;
import com.ruoyi.common.core.domain.entity.SysUserPointLog;

/**
 * 用户积分账户服务
 */
public interface ISysUserPointService {
    public SysUserPointAccount selectPointAccountById(Long pointAccountId);

    public SysUserPointAccount selectPointAccountByUserId(Long userId);

    public SysUserPointAccount selectPointAccountByUserIdAndUserName(Long userId, String userName);

    public List<SysUserPointAccount> selectPointAccountList(SysUserPointAccount pointAccount);

    public int insertPointAccount(SysUserPointAccount pointAccount);

    public int updatePointAccount(SysUserPointAccount pointAccount);

    public int deletePointAccountById(Long pointAccountId);

    public int deletePointAccountByIds(Long[] pointAccountIds);

    public SysUserPointAccount ensurePointAccount(Long userId, String userName);

    public int grantPoints(Long userId, String userName, Long points, String sourceType, Long sourceId, String sourceNo, String remark);

    public int grantInvestPoints(Long userId, String userName, Long points, Long sourceId, String sourceNo, String remark);

    public int grantActivityPoints(Long userId, String userName, Long points, Long sourceId, String sourceNo, String remark);

    public int spendPoints(Long userId, String userName, Long points, String sourceType, Long sourceId, String sourceNo, String remark);

    public int adjustPoints(Long userId, String userName, Long points, String sourceType, Long sourceId, String sourceNo, String remark);
}
