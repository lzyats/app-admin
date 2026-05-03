package com.ruoyi.system.service.impl;

import java.math.BigDecimal;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.exception.ServiceException;
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
        if (product.getMinInvestAmount() != null && product.getMaxInvestAmount() != null
            && product.getMinInvestAmount().compareTo(product.getMaxInvestAmount()) > 0)
        {
            throw new ServiceException("起投金额不能大于最高可投金额");
        }
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
        if (product.getSingleRate() != null && product.getSingleRate().compareTo(BigDecimal.ZERO) < 0)
        {
            throw new ServiceException("单购利率不能小于0");
        }
        if (product.getGroupRate() != null && product.getGroupRate().compareTo(BigDecimal.ZERO) < 0)
        {
            throw new ServiceException("拼团利率不能小于0");
        }
    }
}
