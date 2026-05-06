package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.system.domain.SysCouponGrantRequest;

public interface ISysDeliveryTargetService
{
    List<SysUser> selectAudienceUsers(SysCouponGrantRequest request);

    List<Long> resolveTargetUserIds(SysCouponGrantRequest request);
}
