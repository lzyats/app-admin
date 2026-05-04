package com.ruoyi.system.mapper;

import java.util.Date;
import java.util.List;
import java.math.BigDecimal;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysTeamStatEvent;
import com.ruoyi.system.domain.SysTeamStatUser;

public interface SysTeamStatMapper
{
    int clearTeamRelation();

    int insertTeamRelationFromUser();

    int deleteEventsByDate(@Param("statDate") Date statDate);

    int insertRegisterEvents(@Param("statDate") Date statDate, @Param("calcDepth") Integer calcDepth);

    int insertRechargeEvents(@Param("statDate") Date statDate, @Param("calcDepth") Integer calcDepth);

    int insertInvestEvents(
        @Param("statDate") Date statDate,
        @Param("calcDepth") Integer calcDepth,
        @Param("yebaoLevelBonusEnabled") Boolean yebaoLevelBonusEnabled
    );

    int insertInvestOrderEvents(
        @Param("memberUserId") Long memberUserId,
        @Param("orderId") Long orderId,
        @Param("eventAmount") BigDecimal eventAmount,
        @Param("eventTime") Date eventTime,
        @Param("calcDepth") Integer calcDepth
    );

    int deleteInvestOrderEvents(@Param("orderId") Long orderId);

    int deleteDailyByDate(@Param("statDate") Date statDate);

    int buildDailySnapshot(
        @Param("statDate") Date statDate,
        @Param("calcDepth") Integer calcDepth,
        @Param("dayEnd") Date dayEnd,
        @Param("yebaoLevelBonusEnabled") Boolean yebaoLevelBonusEnabled
    );

    int refreshUserSnapshot(@Param("statDate") Date statDate);

    List<SysTeamStatUser> selectTeamStatUserList(SysTeamStatUser query);

    List<SysTeamStatEvent> selectTeamStatEventList(SysTeamStatEvent query);
}
