package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysInvestTag;

public interface ISysInvestTagService
{
    SysInvestTag selectInvestTagById(Long tagId);

    List<SysInvestTag> selectInvestTagList(SysInvestTag tag);

    int insertInvestTag(SysInvestTag tag);

    int updateInvestTag(SysInvestTag tag);

    int deleteInvestTagByIds(Long[] tagIds);
}
