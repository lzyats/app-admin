package com.ruoyi.system.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysCouponTemplate;

public interface SysCouponTemplateMapper
{
    SysCouponTemplate selectCouponTemplateById(Long couponId);

    List<SysCouponTemplate> selectCouponTemplateList(SysCouponTemplate template);

    int insertCouponTemplate(SysCouponTemplate template);

    int updateCouponTemplate(SysCouponTemplate template);

    int deleteCouponTemplateById(Long couponId);

    int deleteCouponTemplateByIds(Long[] couponIds);

    int insertUserCoupon(@Param("couponId") Long couponId, @Param("userId") Long userId,
                         @Param("userName") String userName, @Param("grantType") String grantType,
                         @Param("validDays") Integer validDays, @Param("operator") String operator,
                         @Param("remark") String remark);

    List<Long> selectUserIdsByLevel(@Param("level") Integer level);
}
