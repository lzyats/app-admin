package com.ruoyi.system.service.impl;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysCouponGrantRequest;
import com.ruoyi.system.domain.SysCouponTemplate;
import com.ruoyi.system.mapper.SysCouponTemplateMapper;
import com.ruoyi.system.service.ISysCouponTemplateService;
import com.ruoyi.system.service.ISysDeliveryTargetService;
import com.ruoyi.system.service.ISysUserService;

@Service
public class SysCouponTemplateServiceImpl implements ISysCouponTemplateService
{
    @Autowired
    private SysCouponTemplateMapper couponTemplateMapper;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ISysDeliveryTargetService deliveryTargetService;

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
    public List<SysUser> selectCouponAudienceList(SysCouponGrantRequest request)
    {
        return deliveryTargetService.selectAudienceUsers(request);
    }

    @Override
    @Transactional
    public int grantCouponToUsers(Long couponId, SysCouponGrantRequest request, String operator)
    {
        SysCouponTemplate template = couponTemplateMapper.selectCouponTemplateById(couponId);
        if (template == null)
        {
            throw new ServiceException("优惠券模板不存在");
        }
        request.setCouponId(couponId);
        List<Long> targetUserIds = deliveryTargetService.resolveTargetUserIds(request);
        if (targetUserIds.isEmpty())
        {
            throw new ServiceException("发放目标为空");
        }

        Set<Long> uniqueTargetIds = new LinkedHashSet<Long>(targetUserIds);
        List<Long> eligibleUserIds = new ArrayList<Long>();
        for (Long userId : uniqueTargetIds)
        {
            if (userId == null || userId <= 0L)
            {
                continue;
            }
            SysUser user = userService.selectUserBaseById(userId);
            if (user == null)
            {
                continue;
            }
            if (couponTemplateMapper.countUserCouponByCouponAndUser(couponId, userId) > 0)
            {
                continue;
            }
            eligibleUserIds.add(userId);
        }
        if (eligibleUserIds.isEmpty())
        {
            throw new ServiceException("发放目标已全部发放过或不存在");
        }

        Integer totalCount = template.getTotalCount() == null ? 0 : template.getTotalCount();
        Integer receivedCount = template.getReceivedCount() == null ? 0 : template.getReceivedCount();
        if (totalCount > 0 && receivedCount + eligibleUserIds.size() > totalCount)
        {
            throw new ServiceException("发放数量超过模板总数");
        }

        int count = 0;
        for (Long userId : eligibleUserIds)
        {
            SysUser user = userService.selectUserBaseById(userId);
            if (user == null)
            {
                continue;
            }
            count += couponTemplateMapper.insertUserCoupon(couponId, userId, user.getUserName(),
                StringUtils.isBlank(request.getGrantType()) ? "MANUAL" : request.getGrantType(),
                template.getValidDays(), operator, request.getRemark());
        }
        if (count > 0)
        {
            couponTemplateMapper.increaseReceivedCount(couponId, count);
        }
        return count;
    }
}