package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.common.core.domain.entity.SysUserPointLog;

/**
 * 用户积分账变 Mapper
 */
public interface SysUserPointLogMapper {
    public List<SysUserPointLog> selectPointLogByUserId(Long userId);

    public List<SysUserPointLog> selectPointLogByPointAccountId(Long pointAccountId);

    public SysUserPointLog selectPointLogById(Long logId);

    public List<SysUserPointLog> selectPointLogList(SysUserPointLog pointLog);

    public int insertPointLog(SysUserPointLog pointLog);

    public int updatePointLog(SysUserPointLog pointLog);

    public int deletePointLogById(Long logId);

    public int deletePointLogByIds(Long[] logIds);
}
