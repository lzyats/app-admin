package com.ruoyi.framework.web.service;

import java.util.HashSet;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.model.LoginUser;
import com.ruoyi.common.enums.UserStatus;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.MessageUtils;
import com.ruoyi.common.utils.ServletUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.mapper.SysRoleMapper;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.common.core.domain.entity.SysRole;

/**
 * User authentication loading service.
 *
 * Login reads user data directly from the database to avoid stale cache data
 * affecting password validation. The user cache is still used by APP and admin
 * pages for profile reads.
 *
 * @author ruoyi
 */
@Service
public class UserDetailsServiceImpl implements UserDetailsService
{
    private static final Logger log = LoggerFactory.getLogger(UserDetailsServiceImpl.class);

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private SysRoleMapper roleMapper;

    @Autowired
    private SysPasswordService passwordService;

    @Autowired
    private SysPermissionService permissionService;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException
    {
        boolean appClient = isAppClient();
        SysUser user = userMapper.selectUserAuthByUserName(username);
        if (StringUtils.isNull(user))
        {
            log.info("Login user '{}' does not exist.", username);
            throw new ServiceException(MessageUtils.message("user.not.exists"));
        }
        else if (UserStatus.DELETED.getCode().equals(user.getDelFlag()))
        {
            log.info("Login user '{}' has been deleted.", username);
            throw new ServiceException(MessageUtils.message("user.password.delete"));
        }
        else if (UserStatus.DISABLE.getCode().equals(user.getStatus()))
        {
            log.info("Login user '{}' has been disabled.", username);
            throw new ServiceException(MessageUtils.message("user.blocked"));
        }

        passwordService.validate(user);

        if (!appClient)
        {
            List<SysRole> roles = roleMapper.selectRolesByUserName(username);
            user.setRoles(roles);
            if (roles != null && !roles.isEmpty())
            {
                Long[] roleIds = roles.stream().map(SysRole::getRoleId).toArray(Long[]::new);
                user.setRoleIds(roleIds);
            }
        }

        return appClient ? createAppLoginUser(user) : createLoginUser(user);
    }

    public UserDetails createLoginUser(SysUser user)
    {
        return new LoginUser(user.getUserId(), user.getDeptId(), user, permissionService.getMenuPermission(user));
    }

    public UserDetails createAppLoginUser(SysUser user)
    {
        return new LoginUser(user.getUserId(), user.getDeptId(), user, new HashSet<>());
    }

    private boolean isAppClient()
    {
        try
        {
            String clientType = ServletUtils.getRequest().getHeader("X-Client-Type");
            return "app".equalsIgnoreCase(clientType);
        }
        catch (Exception ignored)
        {
            return false;
        }
    }
}
