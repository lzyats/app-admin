package com.ruoyi.system.mapper;

import com.ruoyi.common.core.domain.entity.SysUserSignLog;
import java.util.List;
import org.apache.ibatis.annotations.Param;

/**
 * 用户签到记录 Mapper
 */
public interface SysUserSignLogMapper {
    SysUserSignLog selectSignLogById(Long signId);

    SysUserSignLog selectLatestSignLogByUserId(Long userId);

    SysUserSignLog selectSignLogByUserIdAndSignDate(@Param("userId") Long userId, @Param("signDate") String signDate);

    List<SysUserSignLog> selectSignLogList(SysUserSignLog signLog);

    List<SysUserSignLog> selectRecentSignLogList(@Param("userId") Long userId, @Param("limit") Integer limit);

    int insertSignLog(SysUserSignLog signLog);

    int createTableIfNotExists();

    int updateSignLog(SysUserSignLog signLog);

    int deleteSignLogById(Long signId);

    int deleteSignLogByIds(Long[] signIds);
}
