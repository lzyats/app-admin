package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.SysInvestTag;

public interface SysInvestTagMapper
{
    SysInvestTag selectInvestTagById(Long tagId);

    List<SysInvestTag> selectInvestTagList(SysInvestTag tag);

    int insertInvestTag(SysInvestTag tag);

    int updateInvestTag(SysInvestTag tag);

    int deleteInvestTagById(Long tagId);

    int deleteInvestTagByIds(Long[] tagIds);
}
