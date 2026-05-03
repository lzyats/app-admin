package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysCouponTemplate;

public interface ISysCouponTemplateService
{
    SysCouponTemplate selectCouponTemplateById(Long couponId);

    List<SysCouponTemplate> selectCouponTemplateList(SysCouponTemplate template);

    int insertCouponTemplate(SysCouponTemplate template);

    int updateCouponTemplate(SysCouponTemplate template);

    int deleteCouponTemplateByIds(Long[] couponIds);

    int grantCouponToUsers(Long couponId, List<Long> userIds, Integer level, String grantType, String operator, String remark);
}
