package com.ruoyi.system.service;

import java.math.BigDecimal;
import java.util.Map;
import com.ruoyi.system.domain.SysInvestProduct;

public interface ISysCouponUseService
{
    Map<String, Object> previewInvestCoupon(Long userId, SysInvestProduct product, Long userCouponId, BigDecimal investAmount);

    int markInvestCouponUsed(Long userCouponId, Long usedProductId, Long usedOrderId, String operator, String remark);
}
