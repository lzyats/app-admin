package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysNewsCategory;

public interface ISysNewsCategoryService
{
    List<SysNewsCategory> selectNewsCategoryList(SysNewsCategory category);

    List<SysNewsCategory> selectNewsCategoryAll();

    SysNewsCategory selectNewsCategoryById(Long categoryId);

    int insertNewsCategory(SysNewsCategory category);

    int updateNewsCategory(SysNewsCategory category);

    int deleteNewsCategoryById(Long categoryId);

    int deleteNewsCategoryByIds(Long[] categoryIds);

    void clearCache();
}
