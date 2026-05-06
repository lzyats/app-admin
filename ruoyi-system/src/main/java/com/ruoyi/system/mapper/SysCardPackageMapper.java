package com.ruoyi.system.mapper;

import java.util.Date;
import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface SysCardPackageMapper
{
    List<Map<String, Object>> selectMyCouponCards(@Param("userId") Long userId);

    List<Map<String, Object>> selectMyTrialCards(@Param("userId") Long userId);

    Map<String, Object> selectTrialCardByIdForUpdate(@Param("userTrialId") Long userTrialId);

    Map<String, Object> selectActiveTrialCardByUserIdForUpdate(@Param("userId") Long userId);

    List<Map<String, Object>> selectActiveTrialCardsByUserIdForUpdate(@Param("userId") Long userId,
                                                                       @Param("excludeUserTrialId") Long excludeUserTrialId);

    List<Map<String, Object>> selectExpiredTrialCards(@Param("now") Date now, @Param("limit") Integer limit);

    List<Map<String, Object>> selectExpiredUnstartedTrialCards(@Param("now") Date now, @Param("limit") Integer limit);

    int updateTrialCardUse(@Param("userTrialId") Long userTrialId,
                           @Param("originalLevel") Integer originalLevel,
                           @Param("currentLevel") Integer currentLevel,
                           @Param("startTime") Date startTime,
                           @Param("endTime") Date endTime,
                           @Param("updateBy") String updateBy,
                           @Param("remark") String remark);

    int updateTrialCardExpired(@Param("userTrialId") Long userTrialId,
                               @Param("updateBy") String updateBy,
                               @Param("remark") String remark);
}
