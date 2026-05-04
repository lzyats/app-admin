package com.ruoyi.system.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysInvestTag;
import com.ruoyi.system.mapper.SysInvestTagMapper;
import com.ruoyi.system.service.ISysInvestTagService;

@Service
public class SysInvestTagServiceImpl implements ISysInvestTagService
{
    @Autowired
    private SysInvestTagMapper investTagMapper;

    @Override
    public SysInvestTag selectInvestTagById(Long tagId)
    {
        return investTagMapper.selectInvestTagById(tagId);
    }

    @Override
    public List<SysInvestTag> selectInvestTagList(SysInvestTag tag)
    {
        return investTagMapper.selectInvestTagList(tag);
    }

    @Override
    public int insertInvestTag(SysInvestTag tag)
    {
        if (StringUtils.isBlank(tag.getTagType()))
        {
            tag.setTagType("PRODUCT");
        }
        return investTagMapper.insertInvestTag(tag);
    }

    @Override
    public int updateInvestTag(SysInvestTag tag)
    {
        if (StringUtils.isBlank(tag.getTagType()))
        {
            tag.setTagType("PRODUCT");
        }
        return investTagMapper.updateInvestTag(tag);
    }

    @Override
    public int deleteInvestTagByIds(Long[] tagIds)
    {
        return investTagMapper.deleteInvestTagByIds(tagIds);
    }
}
