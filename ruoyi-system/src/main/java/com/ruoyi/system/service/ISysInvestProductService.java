package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysInvestProduct;

public interface ISysInvestProductService
{
    SysInvestProduct selectInvestProductById(Long productId);

    List<SysInvestProduct> selectInvestProductList(SysInvestProduct product);

    int insertInvestProduct(SysInvestProduct product);

    int updateInvestProduct(SysInvestProduct product);

    int deleteInvestProductByIds(Long[] productIds);
}
