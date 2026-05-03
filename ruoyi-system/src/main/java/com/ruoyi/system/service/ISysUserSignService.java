package com.ruoyi.system.service;

import com.ruoyi.common.core.domain.entity.SysUserSignLog;
import java.util.List;
import java.util.Map;

/**
 * 用户签到服务接口
 */
public interface ISysUserSignService {
    Map<String, Object> getTodayStatus(Long userId, String userName);

    Map<String, Object> signToday(Long userId, String userName);

    List<SysUserSignLog> selectSignLogList(SysUserSignLog signLog);
}
