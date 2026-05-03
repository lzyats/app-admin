package com.ruoyi.system.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysInvestProduct;

public interface SysInvestProductMapper
{
    SysInvestProduct selectInvestProductById(Long productId);

    List<SysInvestProduct> selectInvestProductList(SysInvestProduct product);

    int insertInvestProduct(SysInvestProduct product);

    int updateInvestProduct(SysInvestProduct product);

    int deleteInvestProductById(Long productId);

    int deleteInvestProductByIds(Long[] productIds);

    int deleteProductTagRelByProductId(Long productId);

    int insertProductTagRel(@Param("productId") Long productId, @Param("tagId") Long tagId);

    Long[] selectTagIdsByProductId(Long productId);
}
