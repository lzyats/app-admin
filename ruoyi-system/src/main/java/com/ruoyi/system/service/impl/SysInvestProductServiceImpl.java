package com.ruoyi.system.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysInvestProduct;
import com.ruoyi.system.mapper.SysInvestProductMapper;
import com.ruoyi.system.service.ISysInvestProductService;

@Service
public class SysInvestProductServiceImpl implements ISysInvestProductService
{
    @Autowired
    private SysInvestProductMapper productMapper;

    @Override
    public SysInvestProduct selectInvestProductById(Long productId)
    {
        SysInvestProduct product = productMapper.selectInvestProductById(productId);
        if (product != null)
        {
            product.setTagIds(productMapper.selectTagIdsByProductId(productId));
        }
        return product;
    }

    @Override
    public List<SysInvestProduct> selectInvestProductList(SysInvestProduct product)
    {
        return productMapper.selectInvestProductList(product);
    }

    @Override
    @Transactional
    public int insertInvestProduct(SysInvestProduct product)
    {
        validateProduct(product);
        int rows = productMapper.insertInvestProduct(product);
        if (rows > 0)
        {
            saveTagRel(product.getProductId(), product.getTagIds());
        }
        return rows;
    }

    @Override
    @Transactional
    public int updateInvestProduct(SysInvestProduct product)
    {
        validateProduct(product);
        int rows = productMapper.updateInvestProduct(product);
        if (rows > 0)
        {
            productMapper.deleteProductTagRelByProductId(product.getProductId());
            saveTagRel(product.getProductId(), product.getTagIds());
        }
        return rows;
    }

    @Override
    @Transactional
    public int deleteInvestProductByIds(Long[] productIds)
    {
        for (Long productId : productIds)
        {
            productMapper.deleteProductTagRelByProductId(productId);
        }
        return productMapper.deleteInvestProductByIds(productIds);
    }

    @Override
    @Transactional
    public int copyInvestProduct(Long productId, String operator)
    {
        SysInvestProduct source = selectInvestProductById(productId);
        if (source == null)
        {
            throw new ServiceException("复制失败，产品不存在");
        }
        SysInvestProduct target = buildCopy(source, operator);
        validateProduct(target);
        int rows = productMapper.insertInvestProduct(target);
        if (rows > 0)
        {
            saveTagRel(target.getProductId(), source.getTagIds());
        }
        return rows;
    }

    private void saveTagRel(Long productId, Long[] tagIds)
    {
        if (tagIds == null || tagIds.length == 0)
        {
            return;
        }
        for (Long tagId : tagIds)
        {
            if (tagId != null)
            {
                productMapper.insertProductTagRel(productId, tagId);
            }
        }
    }

    private void validateProduct(SysInvestProduct product)
    {
        if (StringUtils.isBlank(product.getCurrency()))
        {
            throw new ServiceException("投资币种不能为空");
        }
        String currency = product.getCurrency().trim().toUpperCase();
        if (!"CNY".equals(currency) && !"USD".equals(currency))
        {
            throw new ServiceException("投资币种仅支持人民币(CNY)和USD");
        }
        product.setCurrency(currency);
        if (StringUtils.isBlank(product.getCardTheme()))
        {
            product.setCardTheme(resolveThemeByCurrency(product.getCurrency()));
        }
        if (product.getMinInvestAmount() != null && product.getMaxInvestAmount() != null
            && product.getMinInvestAmount().compareTo(product.getMaxInvestAmount()) > 0)
        {
            throw new ServiceException("起投金额不能大于最高可投金额");
        }
        String investMode = StringUtils.upperCase(StringUtils.defaultIfBlank(product.getInvestMode(), "SHARE"));
        if (!"SHARE".equals(investMode) && !"AMOUNT".equals(investMode))
        {
            throw new ServiceException("投资方式仅支持按份额(SHARE)或按金额(AMOUNT)");
        }
        product.setInvestMode(investMode);
        BigDecimal minAmount = product.getMinInvestAmount() == null ? BigDecimal.ZERO : product.getMinInvestAmount();
        BigDecimal maxAmount = product.getMaxInvestAmount() == null ? BigDecimal.ZERO : product.getMaxInvestAmount();
        Long totalShares = product.getTotalShares() == null ? 0L : product.getTotalShares();
        Long soldShares = product.getSoldShares() == null ? 0L : product.getSoldShares();
        BigDecimal totalAmount = product.getTotalAmount() == null ? BigDecimal.ZERO : product.getTotalAmount();
        BigDecimal soldAmount = product.getSoldAmount() == null ? BigDecimal.ZERO : product.getSoldAmount();
        if ("SHARE".equals(investMode))
        {
            if (totalShares <= 0L)
            {
                throw new ServiceException("按份额模式必须配置总份数");
            }
            if (minAmount.compareTo(BigDecimal.ZERO) <= 0)
            {
                throw new ServiceException("按份额模式下起投金额必须大于0");
            }
            if (maxAmount.compareTo(BigDecimal.ZERO) > 0 && maxAmount.remainder(minAmount).compareTo(BigDecimal.ZERO) != 0)
            {
                throw new ServiceException("按份额模式下最高可投必须是起投金额的整数倍");
            }
            if (soldShares < 0L)
            {
                soldShares = 0L;
            }
            if (soldShares > totalShares)
            {
                throw new ServiceException("已售份数不能超过总份数");
            }
            totalAmount = minAmount.multiply(BigDecimal.valueOf(totalShares)).setScale(2, RoundingMode.DOWN);
            if (soldAmount.compareTo(BigDecimal.ZERO) < 0)
            {
                soldAmount = BigDecimal.ZERO;
            }
            if (soldAmount.compareTo(totalAmount) > 0)
            {
                throw new ServiceException("已投金额不能超过总金额");
            }
            soldAmount = soldAmount.setScale(2, RoundingMode.DOWN);
            product.setTotalAmount(totalAmount);
            product.setSoldAmount(soldAmount);
            product.setTotalShares(totalShares);
            product.setSoldShares(soldShares);
        }
        else
        {
            if (totalAmount.compareTo(BigDecimal.ZERO) <= 0)
            {
                throw new ServiceException("按金额模式必须配置总金额");
            }
            if (soldAmount.compareTo(BigDecimal.ZERO) < 0)
            {
                soldAmount = BigDecimal.ZERO;
            }
            if (soldAmount.compareTo(totalAmount) > 0)
            {
                throw new ServiceException("已售金额不能超过总金额");
            }
            product.setTotalAmount(totalAmount.setScale(2, RoundingMode.DOWN));
            product.setSoldAmount(soldAmount.setScale(2, RoundingMode.DOWN));
            product.setTotalShares(totalShares < 0L ? 0L : totalShares);
            product.setSoldShares(soldShares < 0L ? 0L : soldShares);
        }
        product.setProgressPercent(calcProgressPercentByMode(product));
        if ("1".equals(product.getGroupEnabled())
            && (product.getGroupSize() == null || product.getGroupSize() < 2))
        {
            throw new ServiceException("拼团产品成团人数至少为2");
        }
        if ("STAGED".equalsIgnoreCase(product.getInterestMode())
            && (product.getInterestStageCount() == null || product.getInterestStageCount() <= 0))
        {
            throw new ServiceException("分段返息必须配置返息阶段数");
        }
        if ("STAGED".equalsIgnoreCase(product.getPrincipalMode())
            && (product.getPrincipalStageCount() == null || product.getPrincipalStageCount() <= 0))
        {
            throw new ServiceException("分段返本必须配置返本阶段数");
        }
        Date startTime = product.getStartTime();
        Date endTime = product.getEndTime();
        if (startTime != null && endTime != null && endTime.before(startTime))
        {
            throw new ServiceException("产品有效期结束时间不能早于开始时间");
        }
        if (product.getSingleRate() != null && product.getSingleRate().compareTo(BigDecimal.ZERO) < 0)
        {
            throw new ServiceException("单购利率不能小于0");
        }
        if (product.getGroupRate() != null && product.getGroupRate().compareTo(BigDecimal.ZERO) < 0)
        {
            throw new ServiceException("拼团利率不能小于0");
        }
    }

    private BigDecimal calcProgressPercentByMode(SysInvestProduct product)
    {
        String mode = StringUtils.upperCase(StringUtils.defaultIfBlank(product.getInvestMode(), "SHARE"));
        BigDecimal progress = BigDecimal.ZERO;
        if ("AMOUNT".equals(mode))
        {
            BigDecimal totalAmount = product.getTotalAmount() == null ? BigDecimal.ZERO : product.getTotalAmount();
            BigDecimal soldAmount = product.getSoldAmount() == null ? BigDecimal.ZERO : product.getSoldAmount();
            if (totalAmount.compareTo(BigDecimal.ZERO) > 0)
            {
                progress = soldAmount.multiply(BigDecimal.valueOf(100))
                    .divide(totalAmount, 4, RoundingMode.HALF_UP);
            }
        }
        else
        {
            Long totalShares = product.getTotalShares() == null ? 0L : product.getTotalShares();
            Long soldShares = product.getSoldShares() == null ? 0L : product.getSoldShares();
            if (totalShares > 0L)
            {
                progress = BigDecimal.valueOf(soldShares)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(BigDecimal.valueOf(totalShares), 4, RoundingMode.HALF_UP);
            }
        }
        if (progress.compareTo(BigDecimal.ZERO) < 0)
        {
            return BigDecimal.ZERO.setScale(4, RoundingMode.HALF_UP);
        }
        if (progress.compareTo(BigDecimal.valueOf(100)) > 0)
        {
            return BigDecimal.valueOf(100).setScale(4, RoundingMode.HALF_UP);
        }
        return progress.setScale(4, RoundingMode.HALF_UP);
    }

    private String resolveThemeByCurrency(String currency)
    {
        if (StringUtils.isBlank(currency))
        {
            return "blue";
        }
        String key = currency.trim().toUpperCase();
        if ("USD".equals(key))
        {
            return "purple";
        }
        return "blue";
    }

    private SysInvestProduct buildCopy(SysInvestProduct source, String operator)
    {
        SysInvestProduct copy = new SysInvestProduct();
        copy.setProductCode(generateCopyCode(source.getProductCode()));
        copy.setProductName(source.getProductName());
        copy.setCurrency(source.getCurrency());
        copy.setCardTheme(source.getCardTheme());
        copy.setRiskTag(source.getRiskTag());
        copy.setCoverImage(source.getCoverImage());
        copy.setGalleryImages(source.getGalleryImages());
        copy.setProductContent(source.getProductContent());
        copy.setTradeRuleContent(source.getTradeRuleContent());
        copy.setSingleRate(source.getSingleRate());
        copy.setGroupRate(source.getGroupRate());
        copy.setCycleDays(source.getCycleDays());
        copy.setInterestMode(source.getInterestMode());
        copy.setPrincipalMode(source.getPrincipalMode());
        copy.setInterestStageCount(source.getInterestStageCount());
        copy.setPrincipalStageCount(source.getPrincipalStageCount());
        copy.setStageConfigJson(source.getStageConfigJson());
        copy.setInvestMode(source.getInvestMode());
        copy.setMinInvestAmount(source.getMinInvestAmount());
        copy.setMaxInvestAmount(source.getMaxInvestAmount());
        copy.setTotalShares(source.getTotalShares());
        copy.setSoldShares(0L);
        copy.setTotalAmount(source.getTotalAmount());
        copy.setSoldAmount(BigDecimal.ZERO);
        copy.setProgressPercent(BigDecimal.ZERO);
        copy.setPointPerUnit(source.getPointPerUnit());
        copy.setGrowthPerUnit(source.getGrowthPerUnit());
        copy.setRedPacketPerUnit(source.getRedPacketPerUnit());
        copy.setCouponEnabled(source.getCouponEnabled());
        copy.setGroupEnabled(source.getGroupEnabled());
        copy.setGroupSize(source.getGroupSize());
        copy.setAutoGroup(source.getAutoGroup());
        copy.setLimitLevel(source.getLimitLevel());
        copy.setLimitTimes(source.getLimitTimes());
        copy.setStartTime(source.getStartTime());
        copy.setEndTime(source.getEndTime());
        copy.setStatus(source.getStatus());
        copy.setRemark(source.getRemark());
        copy.setCreateBy(operator);
        return copy;
    }

    private String generateCopyCode(String sourceCode)
    {
        String base = StringUtils.trim(sourceCode);
        if (StringUtils.isBlank(base))
        {
            base = "PRD";
        }
        String suffix = "_C" + (System.currentTimeMillis() % 1000000);
        int maxBaseLen = 64 - suffix.length();
        if (maxBaseLen < 1)
        {
            return "P" + suffix;
        }
        if (base.length() > maxBaseLen)
        {
            base = base.substring(0, maxBaseLen);
        }
        return base + suffix;
    }
}
