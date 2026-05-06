package com.ruoyi.system.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysCouponGrantRequest;
import com.ruoyi.system.service.ISysDeliveryTargetService;
import com.ruoyi.system.service.ISysUserService;

@Service
public class SysDeliveryTargetServiceImpl implements ISysDeliveryTargetService
{
    @Autowired
    private ISysUserService userService;

    @Override
    public List<SysUser> selectAudienceUsers(SysCouponGrantRequest request)
    {
        return userService.selectUserList(buildUserQuery(request));
    }

    @Override
    public List<Long> resolveTargetUserIds(SysCouponGrantRequest request)
    {
        if (request.getUserIds() != null && !request.getUserIds().isEmpty())
        {
            return dedupeUserIds(request.getUserIds());
        }
        List<SysUser> audience = userService.selectUserList(buildUserQuery(request));
        List<Long> userIds = new ArrayList<Long>();
        for (SysUser user : audience)
        {
            if (user != null && user.getUserId() != null && user.getUserId() > 0L)
            {
                userIds.add(user.getUserId());
            }
        }
        return dedupeUserIds(userIds);
    }

    private SysUser buildUserQuery(SysCouponGrantRequest request)
    {
        SysUser query = new SysUser();
        query.setUserName(trimToNull(request.getUserName()));
        query.setNickName(trimToNull(request.getNickName()));
        query.setRealName(trimToNull(request.getRealName()));
        query.setPhonenumber(trimToNull(request.getPhonenumber()));
        query.setStatus(trimToNull(request.getStatus()));
        query.setRealNameStatus(parseInteger(request.getRealNameStatus()));
        query.setLevel(request.getLevel());
        Map<String, Object> params = new HashMap<String, Object>();
        if (StringUtils.isNotBlank(request.getBeginTime()))
        {
            params.put("beginTime", request.getBeginTime());
        }
        if (StringUtils.isNotBlank(request.getEndTime()))
        {
            params.put("endTime", request.getEndTime());
        }
        if (!params.isEmpty())
        {
            query.setParams(params);
        }
        return query;
    }

    private String trimToNull(String value)
    {
        if (StringUtils.isBlank(value))
        {
            return null;
        }
        return StringUtils.trim(value);
    }

    private Integer parseInteger(String value)
    {
        if (StringUtils.isBlank(value))
        {
            return null;
        }
        try
        {
            return Integer.valueOf(value.trim());
        }
        catch (Exception ignored)
        {
            return null;
        }
    }

    private List<Long> dedupeUserIds(List<Long> userIds)
    {
        Set<Long> unique = new LinkedHashSet<Long>();
        for (Long userId : userIds)
        {
            if (userId != null && userId > 0L)
            {
                unique.add(userId);
            }
        }
        return new ArrayList<Long>(unique);
    }
}
