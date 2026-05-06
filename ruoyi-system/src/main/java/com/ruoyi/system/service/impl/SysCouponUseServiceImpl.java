package com.ruoyi.system.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysInvestProduct;
import com.ruoyi.system.mapper.SysCouponTemplateMapper;
import com.ruoyi.system.service.ISysCouponUseService;
import tools.jackson.databind.ObjectMapper;

@Service
public class SysCouponUseServiceImpl implements ISysCouponUseService
{
    private static final String[] PAYMENT_COUPON_TYPES = new String[] {"CASH", "FULL_REDUCTION"};

    @Autowired
    private SysCouponTemplateMapper couponTemplateMapper;

    @Autowired
    private ObjectMapper objectMapper;

    @Override
    public Map<String, Object> previewInvestCoupon(Long userId, SysInvestProduct product, Long userCouponId, BigDecimal investAmount)
    {
        Map<String, Object> result = new LinkedHashMap<String, Object>();
        BigDecimal safeAmount = investAmount == null ? BigDecimal.ZERO : investAmount.setScale(2, RoundingMode.DOWN);
        result.put("couponId", null);
        result.put("userCouponId", null);
        result.put("couponName", "");
        result.put("couponType", "");
        result.put("discountAmount", BigDecimal.ZERO);
        result.put("payAmount", safeAmount);

        if (userCouponId == null || userCouponId <= 0L)
        {
            return result;
        }
        if (product == null)
        {
            throw new ServiceException("产品不存在");
        }
        if (!"1".equals(StringUtils.trim(product.getCouponEnabled())))
        {
            throw new ServiceException("当前产品不支持使用优惠券");
        }

        Map<String, Object> row = couponTemplateMapper.selectUserCouponForInvestUse(userCouponId, userId);
        if (row == null || row.isEmpty())
        {
            throw new ServiceException("优惠券不存在或已失效");
        }

        String userStatus = safeText(row.get("userStatus"));
        if (!"0".equals(userStatus))
        {
            throw new ServiceException("当前优惠券已使用或已失效");
        }
        String templateStatus = safeText(row.get("templateStatus"));
        if (StringUtils.isNotBlank(templateStatus) && !"0".equals(templateStatus))
        {
            throw new ServiceException("当前优惠券模板已停用");
        }

        Date now = new Date();
        Date startTime = toDate(row.get("startTime"));
        Date endTime = toDate(row.get("endTime"));
        if (startTime != null && now.before(startTime))
        {
            throw new ServiceException("当前优惠券未到生效时间");
        }
        if (endTime != null && !now.before(endTime))
        {
            throw new ServiceException("当前优惠券已过期");
        }

        String couponType = StringUtils.upperCase(safeText(row.get("couponType")));
        if (!isPaymentCouponType(couponType))
        {
            throw new ServiceException("当前优惠券不能用于支付抵扣");
        }

        if (!isCouponApplicableToProduct(row, product))
        {
            throw new ServiceException("当前优惠券不适用于所选产品");
        }

        BigDecimal minAmount = toBigDecimal(row.get("minAmount"));
        if (minAmount.compareTo(BigDecimal.ZERO) > 0 && safeAmount.compareTo(minAmount) < 0)
        {
            throw new ServiceException("当前优惠券未达到使用门槛");
        }

        BigDecimal discountAmount = toBigDecimal(row.get("discountAmount")).setScale(2, RoundingMode.DOWN);
        if (discountAmount.compareTo(BigDecimal.ZERO) <= 0)
        {
            throw new ServiceException("当前优惠券抵扣金额无效");
        }
        if (discountAmount.compareTo(safeAmount) > 0)
        {
            discountAmount = safeAmount;
        }
        BigDecimal payAmount = safeAmount.subtract(discountAmount).setScale(2, RoundingMode.DOWN);
        if (payAmount.compareTo(BigDecimal.ZERO) < 0)
        {
            payAmount = BigDecimal.ZERO;
        }

        result.put("couponId", row.get("couponId"));
        result.put("userCouponId", row.get("userCouponId"));
        result.put("couponName", row.get("couponName"));
        result.put("couponType", couponType);
        result.put("discountAmount", discountAmount);
        result.put("payAmount", payAmount);
        return result;
    }

    @Override
    public int markInvestCouponUsed(Long userCouponId, Long usedProductId, Long usedOrderId, String operator, String remark)
    {
        if (userCouponId == null || userCouponId <= 0L)
        {
            return 0;
        }
        return couponTemplateMapper.updateUserCouponUsed(userCouponId, usedProductId, usedOrderId, operator, remark);
    }

    private boolean isPaymentCouponType(String couponType)
    {
        for (String type : PAYMENT_COUPON_TYPES)
        {
            if (type.equalsIgnoreCase(couponType))
            {
                return true;
            }
        }
        return false;
    }

    private boolean isCouponApplicableToProduct(Map<String, Object> row, SysInvestProduct product)
    {
        String scopeType = StringUtils.upperCase(safeText(row.get("scopeType")));
        if ("GLOBAL".equals(scopeType) || StringUtils.isBlank(scopeType))
        {
            return true;
        }
        String productIdsJson = row.get("productIdsJson") == null ? "" : String.valueOf(row.get("productIdsJson")).trim();
        if (StringUtils.isBlank(productIdsJson))
        {
            return false;
        }
        try
        {
            List<Object> ids = objectMapper.readValue(productIdsJson, List.class);
            if (ids == null || ids.isEmpty())
            {
                return false;
            }
            String productId = String.valueOf(product.getProductId());
            for (Object id : ids)
            {
                if (id != null && productId.equals(String.valueOf(id)))
                {
                    return true;
                }
            }
        }
        catch (Exception ignored)
        {
        }
        return false;
    }

    private BigDecimal toBigDecimal(Object value)
    {
        if (value == null)
        {
            return BigDecimal.ZERO;
        }
        if (value instanceof BigDecimal)
        {
            return (BigDecimal) value;
        }
        try
        {
            return new BigDecimal(String.valueOf(value).trim());
        }
        catch (Exception e)
        {
            return BigDecimal.ZERO;
        }
    }

    private Date toDate(Object value)
    {
        if (value == null)
        {
            return null;
        }
        if (value instanceof Date)
        {
            return (Date) value;
        }
        if (value instanceof LocalDateTime)
        {
            return Date.from(((LocalDateTime) value).atZone(ZoneId.systemDefault()).toInstant());
        }
        if (value instanceof LocalDate)
        {
            return Date.from(((LocalDate) value).atStartOfDay(ZoneId.systemDefault()).toInstant());
        }
        try
        {
            return Date.from(LocalDateTime.parse(String.valueOf(value)).atZone(ZoneId.systemDefault()).toInstant());
        }
        catch (Exception ignored)
        {
        }
        return null;
    }

    private String safeText(Object value)
    {
        if (value == null)
        {
            return "";
        }
        String text = String.valueOf(value).trim();
        if ("null".equalsIgnoreCase(text))
        {
            return "";
        }
        return text;
    }
}
