package com.ruoyi.system.service.impl;

import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysCouponTemplate;
import com.ruoyi.system.mapper.SysCouponTemplateMapper;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.service.ISysCouponTemplateService;

@Service
public class SysCouponTemplateServiceImpl implements ISysCouponTemplateService
{
    @Autowired
    private SysCouponTemplateMapper couponTemplateMapper;

    @Autowired
    private SysUserMapper userMapper;

    @Override
    public SysCouponTemplate selectCouponTemplateById(Long couponId)
    {
        return couponTemplateMapper.selectCouponTemplateById(couponId);
    }

    @Override
    public List<SysCouponTemplate> selectCouponTemplateList(SysCouponTemplate template)
    {
        return couponTemplateMapper.selectCouponTemplateList(template);
    }

    @Override
    public int insertCouponTemplate(SysCouponTemplate template)
    {
        return couponTemplateMapper.insertCouponTemplate(template);
    }

    @Override
    public int updateCouponTemplate(SysCouponTemplate template)
    {
        return couponTemplateMapper.updateCouponTemplate(template);
    }

    @Override
    public int deleteCouponTemplateByIds(Long[] couponIds)
    {
        return couponTemplateMapper.deleteCouponTemplateByIds(couponIds);
    }

    @Override
    @Transactional
    public int grantCouponToUsers(Long couponId, List<Long> userIds, Integer level, String grantType, String operator, String remark)
    {
        SysCouponTemplate template = couponTemplateMapper.selectCouponTemplateById(couponId);
        if (template == null)
        {
            throw new ServiceException("优惠券模板不存在");
        }
        List<Long> targetUserIds = resolveTargetUsers(userIds, level);
        if (targetUserIds.isEmpty())
        {
            throw new ServiceException("发放目标为空");
        }

        int count = 0;
        for (Long userId : targetUserIds)
        {
            String userName = userMapper.selectUserById(userId).getUserName();
            count += couponTemplateMapper.insertUserCoupon(couponId, userId, userName,
                StringUtils.isBlank(grantType) ? "MANUAL" : grantType,
                template.getValidDays(), operator, remark);
        }
        return count;
    }

    private List<Long> resolveTargetUsers(List<Long> userIds, Integer level)
    {
        if (userIds != null && !userIds.isEmpty())
        {
            return userIds;
        }
        if (level != null)
        {
            return couponTemplateMapper.selectUserIdsByLevel(level);
        }
        return new ArrayList<>();
    }
}
