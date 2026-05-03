package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.common.core.domain.entity.SysUserPointAccount;

/**
 * 用户积分账户 Mapper
 */
public interface SysUserPointAccountMapper {
    public SysUserPointAccount selectPointAccountById(Long pointAccountId);

    public SysUserPointAccount selectPointAccountByUserId(Long userId);

    public SysUserPointAccount selectPointAccountByUserIdAndUserName(Long userId, String userName);

    public List<SysUserPointAccount> selectPointAccountList(SysUserPointAccount pointAccount);

    public int insertPointAccount(SysUserPointAccount pointAccount);

    public int updatePointAccount(SysUserPointAccount pointAccount);

    public int deletePointAccountById(Long pointAccountId);

    public int deletePointAccountByIds(Long[] pointAccountIds);

    public int increasePoints(Long pointAccountId, Long points, Long earnedPoints, Long adjustedPoints, Long spentPoints);

    public int deductPoints(Long pointAccountId, Long points, Long spentPoints);
}
