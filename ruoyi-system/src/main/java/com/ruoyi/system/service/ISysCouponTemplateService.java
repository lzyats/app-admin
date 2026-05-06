package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.system.domain.SysCouponGrantRequest;
import com.ruoyi.system.domain.SysCouponTemplate;

public interface ISysCouponTemplateService
{
    SysCouponTemplate selectCouponTemplateById(Long couponId);

    List<SysCouponTemplate> selectCouponTemplateList(SysCouponTemplate template);

    int insertCouponTemplate(SysCouponTemplate template);

    int updateCouponTemplate(SysCouponTemplate template);

    int deleteCouponTemplateByIds(Long[] couponIds);

    List<SysUser> selectCouponAudienceList(SysCouponGrantRequest request);

    int grantCouponToUsers(Long couponId, SysCouponGrantRequest request, String operator);
}
