package com.ruoyi.system.service.impl;

import java.util.Date;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.system.domain.SysAppRealNameAuth;
import com.ruoyi.system.mapper.SysAppRealNameAuthMapper;
import com.ruoyi.system.service.ISysAppRealNameAuthService;
import com.ruoyi.system.service.ISysBusinessNoticeService;
import com.ruoyi.system.service.ISysUserService;

/**
 * APP实名认证 服务层实现
 *
 * @author ruoyi
 */
@Service
public class SysAppRealNameAuthServiceImpl implements ISysAppRealNameAuthService
{
    @Autowired
    private SysAppRealNameAuthMapper authMapper;

    @Autowired
    private ISysBusinessNoticeService businessNoticeService;

    @Autowired
    private ISysUserService userService;

    @Override
    public SysAppRealNameAuth selectAuthById(Long authId)
    {
        return authMapper.selectAuthById(authId);
    }

    @Override
    public SysAppRealNameAuth selectAuthByUserId(Long userId)
    {
        return authMapper.selectAuthByUserId(userId);
    }

    @Override
    public List<SysAppRealNameAuth> selectAuthList(SysAppRealNameAuth auth)
    {
        return authMapper.selectAuthList(auth);
    }

    @Override
    @Transactional
    public int insertAuth(SysAppRealNameAuth auth)
    {
        if (auth.getStatus() == null)
        {
            auth.setStatus(0);
        }
        auth.setSubmitTime(new Date());
        int result = authMapper.insertAuth(auth);
        if (result > 0 && auth.getUserId() != null && auth.getUserName() != null)
        {
            syncUserRealNameStatus(auth.getUserId(), 0);
            businessNoticeService.insertRealNameAuthNotice(auth.getUserName(), auth.getRealName());
        }
        return result;
    }

    @Override
    @Transactional
    public int updateAuth(SysAppRealNameAuth auth)
    {
        SysAppRealNameAuth existingAuth = null;
        if (auth.getAuthId() != null)
        {
            existingAuth = authMapper.selectAuthById(auth.getAuthId());
        }
        if (existingAuth == null)
        {
            return 0;
        }
        if (auth.getUserId() == null)
        {
            auth.setUserId(existingAuth.getUserId());
        }
        if (auth.getUserName() == null)
        {
            auth.setUserName(existingAuth.getUserName());
        }
        if (auth.getStatus() != null && auth.getStatus() == 0)
        {
            auth.setSubmitTime(new Date());
            auth.setRejectReason(null);
            auth.setReviewTime(null);
            auth.setReviewUserId(null);
            auth.setReviewUserName(null);
        }
        int result = authMapper.updateAuth(auth);
        if (result > 0 && auth.getUserId() != null)
        {
            syncUserRealNameStatus(auth.getUserId(), auth.getStatus());
            if (auth.getStatus() != null && auth.getStatus() == 0 && auth.getUserName() != null)
            {
                businessNoticeService.insertRealNameAuthNotice(auth.getUserName(), auth.getRealName());
            }
        }
        return result;
    }

    @Override
    @Transactional
    public int deleteAuthById(Long authId)
    {
        SysAppRealNameAuth auth = authMapper.selectAuthById(authId);
        int result = authMapper.deleteAuthById(authId);
        if (result > 0 && auth != null && auth.getUserId() != null)
        {
            syncUserRealNameStatus(auth.getUserId(), 0);
        }
        return result;
    }

    @Override
    @Transactional
    public int deleteAuthByIds(Long[] authIds)
    {
        Set<Long> userIds = new LinkedHashSet<Long>();
        for (Long authId : authIds)
        {
            SysAppRealNameAuth auth = authMapper.selectAuthById(authId);
            if (auth != null && auth.getUserId() != null)
            {
                userIds.add(auth.getUserId());
            }
        }
        int result = authMapper.deleteAuthByIds(authIds);
        if (result > 0)
        {
            for (Long userId : userIds)
            {
                syncUserRealNameStatus(userId, 0);
            }
        }
        return result;
    }

    private void syncUserRealNameStatus(Long userId, Integer authStatus)
    {
        if (userId == null)
        {
            return;
        }
        userService.updateUserRealNameStatus(userId, resolveUserRealNameStatus(authStatus));
    }

    private int resolveUserRealNameStatus(Integer authStatus)
    {
        if (authStatus == null)
        {
            return 1;
        }
        if (authStatus == 0)
        {
            return 1;
        }
        if (authStatus == 1)
        {
            return 3;
        }
        if (authStatus == 2)
        {
            return 2;
        }
        if (authStatus == 3)
        {
            return 3;
        }
        return 1;
    }
}
