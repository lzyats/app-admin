package com.ruoyi.web.controller.app;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysInvestProduct;
import com.ruoyi.system.domain.SysInvestTag;
import com.ruoyi.system.mapper.SysAppInvestOrderMapper;
import com.ruoyi.system.service.ISysInvestProductService;
import com.ruoyi.system.service.ISysInvestTagService;

@RestController
@RequestMapping("/app/invest/product")
public class AppInvestProductController extends BaseController
{
    @Autowired
    private ISysInvestProductService productService;

    @Autowired
    private ISysInvestTagService tagService;

    @Autowired
    private SysAppInvestOrderMapper appInvestOrderMapper;

    @GetMapping("/list")
    public AjaxResult list()
    {
        SysInvestProduct query = new SysInvestProduct();
        query.setStatus("0");
        List<SysInvestProduct> products = productService.selectInvestProductList(query);

        SysInvestTag tagQuery = new SysInvestTag();
        tagQuery.setStatus("0");
        tagQuery.setTagType("PRODUCT");
        List<SysInvestTag> tags = tagService.selectInvestTagList(tagQuery);
        Map<Long, String> tagNameMap = new HashMap<Long, String>();
        for (SysInvestTag tag : tags)
        {
            if (tag.getTagId() != null)
            {
                tagNameMap.put(tag.getTagId(), tag.getTagName());
            }
        }

        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (SysInvestProduct item : products)
        {
            SysInvestProduct detail = productService.selectInvestProductById(item.getProductId());
            rows.add(toProductMap(detail, tagNameMap, null));
        }
        Map<String, Object> data = new LinkedHashMap<String, Object>();
        data.put("rows", rows);
        return AjaxResult.success(data);
    }

    @GetMapping("/{productId}")
    public AjaxResult detail(@PathVariable Long productId)
    {
        SysInvestProduct product = productService.selectInvestProductById(productId);
        if (product == null)
        {
            throw new ServiceException("产品不存在");
        }
        if (!"0".equals(product.getStatus()))
        {
            throw new ServiceException("产品不可用");
        }
        SysInvestTag tagQuery = new SysInvestTag();
        tagQuery.setStatus("0");
        tagQuery.setTagType("PRODUCT");
        List<SysInvestTag> tags = tagService.selectInvestTagList(tagQuery);
        Map<Long, String> tagNameMap = new HashMap<Long, String>();
        for (SysInvestTag tag : tags)
        {
            if (tag.getTagId() != null)
            {
                tagNameMap.put(tag.getTagId(), tag.getTagName());
            }
        }
        Long userId = SecurityUtils.getUserId();
        return AjaxResult.success(toProductMap(product, tagNameMap, userId));
    }

    private Map<String, Object> toProductMap(SysInvestProduct product, Map<Long, String> tagNameMap, Long userId)
    {
        Map<String, Object> map = new LinkedHashMap<String, Object>();
        map.put("productId", product.getProductId());
        map.put("productCode", product.getProductCode());
        map.put("productName", product.getProductName());
        map.put("currency", product.getCurrency());
        map.put("cardTheme", product.getCardTheme());
        map.put("riskTag", product.getRiskTag());
        map.put("coverImage", product.getCoverImage());
        map.put("galleryImages", product.getGalleryImages());
        map.put("productContent", product.getProductContent());
        map.put("tradeRuleContent", product.getTradeRuleContent());
        map.put("singleRate", product.getSingleRate());
        map.put("groupRate", product.getGroupRate());
        map.put("cycleDays", product.getCycleDays());
        map.put("investMode", StringUtils.defaultIfBlank(product.getInvestMode(), "SHARE"));
        map.put("minInvestAmount", product.getMinInvestAmount());
        map.put("maxInvestAmount", product.getMaxInvestAmount());
        map.put("totalShares", product.getTotalShares());
        map.put("soldShares", product.getSoldShares());
        map.put("totalAmount", product.getTotalAmount());
        map.put("soldAmount", product.getSoldAmount());
        map.put("pointPerUnit", product.getPointPerUnit());
        map.put("growthPerUnit", product.getGrowthPerUnit());
        map.put("redPacketPerUnit", product.getRedPacketPerUnit());
        map.put("groupEnabled", product.getGroupEnabled());
        map.put("groupSize", product.getGroupSize());
        map.put("limitLevel", product.getLimitLevel());
        map.put("limitTimes", product.getLimitTimes());
        map.put("startTime", product.getStartTime());
        map.put("endTime", product.getEndTime());
        map.put("status", product.getStatus());
        BigDecimal progressPercent = product.getProgressPercent();
        if (progressPercent == null)
        {
            progressPercent = calcProgressPercent(product.getSoldShares(), product.getTotalShares());
        }
        map.put("progressPercent", progressPercent);
        map.put("remainingShares", calcRemainingShares(product.getSoldShares(), product.getTotalShares()));
        map.put("remainingAmount", calcRemainingAmount(product.getSoldAmount(), product.getTotalAmount()));
        map.put("tagNames", resolveTagNames(product.getTagIds(), tagNameMap));
        Map<String, Object> orderCheck = buildOrderCheck(product, userId, progressPercent);
        map.put("userInvestCount", orderCheck.get("userInvestCount"));
        map.put("canOrder", orderCheck.get("canOrder"));
        map.put("orderDisabledReason", orderCheck.get("reason"));
        return map;
    }

    private Map<String, Object> buildOrderCheck(SysInvestProduct product, Long userId, BigDecimal progressPercent)
    {
        Map<String, Object> check = new LinkedHashMap<String, Object>();
        int userInvestCount = 0;
        if (userId != null && userId > 0L && product.getProductId() != null)
        {
            userInvestCount = appInvestOrderMapper.countUserInvestOrderByProduct(userId, product.getProductId());
        }
        String reason = "";
        boolean canOrder = true;
        Date now = new Date();
        Date startTime = product.getStartTime();
        if (startTime != null && now.before(startTime))
        {
            canOrder = false;
            reason = "产品未开始";
        }
        Date endTime = product.getEndTime();
        if (canOrder && endTime != null && now.after(endTime))
        {
            canOrder = false;
            reason = "产品已过有效期";
        }
        if (canOrder && progressPercent != null && progressPercent.compareTo(BigDecimal.valueOf(100)) >= 0)
        {
            canOrder = false;
            reason = "产品进度已100%，暂不可下单";
        }
        Integer limitTimes = product.getLimitTimes() == null ? 0 : product.getLimitTimes();
        if (canOrder && limitTimes > 0 && userInvestCount >= limitTimes)
        {
            canOrder = false;
            reason = limitTimes == 1 ? "该产品不可复购，您已订购过" : "该产品最多可认购" + limitTimes + "次，已达上限";
        }
        check.put("userInvestCount", userInvestCount);
        check.put("canOrder", canOrder);
        check.put("reason", reason);
        return check;
    }

    private BigDecimal calcProgressPercent(Long sold, Long total)
    {
        if (sold == null || total == null || total <= 0 || sold <= 0)
        {
            return BigDecimal.ZERO;
        }
        return BigDecimal.valueOf(sold)
            .multiply(BigDecimal.valueOf(100))
            .divide(BigDecimal.valueOf(total), 4, java.math.RoundingMode.HALF_UP);
    }

    private Long calcRemainingShares(Long sold, Long total)
    {
        if (total == null || total <= 0)
        {
            return 0L;
        }
        long soldVal = sold == null ? 0L : sold;
        long remain = total - soldVal;
        return remain < 0 ? 0L : remain;
    }

    private BigDecimal calcRemainingAmount(BigDecimal sold, BigDecimal total)
    {
        if (total == null || total.compareTo(BigDecimal.ZERO) <= 0)
        {
            return BigDecimal.ZERO;
        }
        BigDecimal soldVal = sold == null ? BigDecimal.ZERO : sold;
        BigDecimal remain = total.subtract(soldVal);
        return remain.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : remain;
    }

    private List<String> resolveTagNames(Long[] tagIds, Map<Long, String> tagNameMap)
    {
        List<String> names = new ArrayList<String>();
        if (tagIds == null || tagIds.length == 0)
        {
            return names;
        }
        for (Long tagId : tagIds)
        {
            String name = tagNameMap.get(tagId);
            if (name != null && !name.trim().isEmpty())
            {
                names.add(name);
            }
        }
        return names;
    }
}
