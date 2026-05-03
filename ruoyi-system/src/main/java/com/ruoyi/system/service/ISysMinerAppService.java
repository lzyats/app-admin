package com.ruoyi.system.service;

import java.util.List;
import java.util.Map;

public interface ISysMinerAppService
{
    Map<String, Object> getOverview(Long userId);

    List<Map<String, Object>> listAvailableMiners(Long userId);

    Map<String, Object> claimMiner(Long userId, Long minerId);

    Map<String, Object> collectIfNeeded(Long userId);

    Map<String, Object> exchangeWag(Long userId, String requestNo, double wagAmount);

    List<Map<String, Object>> listRewardLogs(Long userId);

    List<Map<String, Object>> listExchangeLogs(Long userId);
}
