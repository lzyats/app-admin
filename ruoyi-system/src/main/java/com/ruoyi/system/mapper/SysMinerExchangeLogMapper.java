package com.ruoyi.system.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysMinerExchangeLog;

public interface SysMinerExchangeLogMapper
{
    SysMinerExchangeLog selectByRequestNo(@Param("requestNo") String requestNo);

    int insertExchangeLog(SysMinerExchangeLog log);

    int updateExchangeLog(SysMinerExchangeLog log);

    List<SysMinerExchangeLog> selectExchangeLogList(SysMinerExchangeLog query);
}

