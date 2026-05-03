package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.SysMinerRewardLog;

public interface SysMinerRewardLogMapper
{
    int insertRewardLog(SysMinerRewardLog log);

    List<SysMinerRewardLog> selectRewardLogList(SysMinerRewardLog query);
}

