package com.ruoyi.framework.web.service;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import com.ruoyi.common.constant.CacheConstants;
import com.ruoyi.common.constant.Constants;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.model.LoginUser;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.utils.ServletUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.http.UserAgentUtils;
import com.ruoyi.common.utils.ip.AddressUtils;
import com.ruoyi.common.utils.ip.IpUtils;
import com.ruoyi.common.utils.uuid.IdUtils;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import jakarta.servlet.http.HttpServletRequest;

/**
 * Token 管理服务。
 * 负责登录态的创建、刷新、读取和删除，用户资料本身由统一用户服务提供。
 * APP 和 WEB 使用不同的 Redis key 前缀与过期时间，互不干扰。
 *
 * @author ruoyi
 */
@Component
public class TokenService
{
    private static final Logger log = LoggerFactory.getLogger(TokenService.class);

    // token 自定义标识
    @Value("${token.header}")
    private String header;

    // token 秘钥
    @Value("${token.secret}")
    private String secret;

    // WEB 端过期时间（分钟），默认 30 分钟
    @Value("${token.web.expireTime:${token.expireTime:30}}")
    private int webExpireTime;

    // APP 端过期时间（分钟），默认 30 天
    @Value("${token.app.expireTime:43200}")
    private int appExpireTime;

    protected static final long MILLIS_SECOND = 1000;

    protected static final long MILLIS_MINUTE = 60 * MILLIS_SECOND;

    private static final Long MILLIS_MINUTE_TWENTY = 20 * 60 * 1000L;

    private static final String CLIENT_TYPE_KEY = "client_type";
    private static final String CLIENT_TYPE_APP = "app";
    private static final String CLIENT_TYPE_WEB = "web";

    @Autowired
    private RedisCache redisCache;

    /**
     * 获取用户身份信息。
     *
     * @return 用户信息
     */
    public LoginUser getLoginUser(HttpServletRequest request)
    {
        String token = getToken(request);
        if (StringUtils.isNotEmpty(token))
        {
            try
            {
                Claims claims = parseToken(token);
                String uuid = (String) claims.get(Constants.LOGIN_USER_KEY);
                String clientType = normalizeClientType((String) claims.get(CLIENT_TYPE_KEY));
                String userKey = getTokenKey(uuid, clientType);
                LoginUser user = redisCache.getCacheObject(userKey);
                if (user != null)
                {
                    if (StringUtils.isEmpty(user.getClientType()))
                    {
                        user.setClientType(clientType);
                    }
                    fillLoginUserIdentity(user);
                }
                return user;
            }
            catch (Exception e)
            {
                log.error("获取用户信息异常'{}'", e.getMessage());
            }
        }
        return null;
    }

    /**
     * 设置用户身份信息。
     */
    public void setLoginUser(LoginUser loginUser)
    {
        if (StringUtils.isNotNull(loginUser) && StringUtils.isNotEmpty(loginUser.getToken()))
        {
            refreshToken(loginUser);
        }
    }

    /**
     * 删除用户身份信息。
     */
    public void delLoginUser(String token)
    {
        delLoginUser(token, null);
    }

    /**
     * 删除用户身份信息。
     */
    public void delLoginUser(String token, String clientType)
    {
        if (StringUtils.isNotEmpty(token))
        {
            String userKey = getTokenKey(token, clientType);
            redisCache.deleteObject(userKey);
        }
    }

    /**
     * 创建 token。
     *
     * @param loginUser 用户信息
     * @return token
     */
    public String createToken(LoginUser loginUser)
    {
        return createToken(loginUser, null);
    }

    /**
     * 创建 token。
     *
     * @param loginUser 用户信息
     * @param clientType 客户端类型，空值默认 web
     * @return token
     */
    public String createToken(LoginUser loginUser, String clientType)
    {
        String token = IdUtils.fastUUID();
        loginUser.setToken(token);
        loginUser.setClientType(normalizeClientType(clientType));
        setUserAgent(loginUser);
        refreshToken(loginUser);

        Map<String, Object> claims = new HashMap<>();
        claims.put(Constants.LOGIN_USER_KEY, token);
        claims.put(Constants.JWT_USERNAME, loginUser.getUsername());
        claims.put(CLIENT_TYPE_KEY, loginUser.getClientType());
        return createToken(claims);
    }

    /**
     * 验证 token 有效期，剩余不足 20 分钟时自动刷新缓存。
     *
     * @param loginUser 登录信息
     */
    public void verifyToken(LoginUser loginUser)
    {
        long expireTime = loginUser.getExpireTime();
        long currentTime = System.currentTimeMillis();
        if (expireTime - currentTime <= MILLIS_MINUTE_TWENTY)
        {
            refreshToken(loginUser);
        }
    }

    /**
     * 刷新 token 有效期。
     *
     * @param loginUser 登录信息
     */
    public void refreshToken(LoginUser loginUser)
    {
        fillLoginUserIdentity(loginUser);
        String clientType = normalizeClientType(loginUser.getClientType());
        int currentExpireTime = resolveExpireTime(clientType);
        loginUser.setClientType(clientType);
        loginUser.setLoginTime(System.currentTimeMillis());
        loginUser.setExpireTime(loginUser.getLoginTime() + currentExpireTime * MILLIS_MINUTE);
        String userKey = getTokenKey(loginUser.getToken(), clientType);
        redisCache.setCacheObject(userKey, loginUser, currentExpireTime, TimeUnit.MINUTES);
    }

    /**
     * Ensure userId/deptId are always available in LoginUser.
     * This prevents downstream APIs from receiving null user IDs when the
     * security principal is partially deserialized from Redis.
     */
    private void fillLoginUserIdentity(LoginUser loginUser)
    {
        if (loginUser == null)
        {
            return;
        }
        SysUser user = loginUser.getUser();
        if (user == null)
        {
            return;
        }
        if (loginUser.getUserId() == null)
        {
            loginUser.setUserId(user.getUserId());
        }
        if (loginUser.getDeptId() == null)
        {
            loginUser.setDeptId(user.getDeptId());
        }
    }

    /**
     * 设置用户代理信息。
     *
     * @param loginUser 登录信息
     */
    public void setUserAgent(LoginUser loginUser)
    {
        String userAgent = ServletUtils.getRequest().getHeader("User-Agent");
        String ip = IpUtils.getIpAddr();
        loginUser.setIpaddr(ip);
        loginUser.setLoginLocation(AddressUtils.getRealAddressByIP(ip));
        loginUser.setBrowser(UserAgentUtils.getBrowser(userAgent));
        loginUser.setOs(UserAgentUtils.getOperatingSystem(userAgent));
    }

    /**
     * 从数据声明生成 token。
     *
     * @param claims 数据声明
     * @return token
     */
    private String createToken(Map<String, Object> claims)
    {
        return Jwts.builder().setClaims(claims).signWith(SignatureAlgorithm.HS512, secret).compact();
    }

    /**
     * 从 token 中解析数据声明。
     *
     * @param token token
     * @return 数据声明
     */
    private Claims parseToken(String token)
    {
        return Jwts.parser().setSigningKey(secret).parseClaimsJws(token).getBody();
    }

    /**
     * 从 token 中获取用户名。
     *
     * @param token token
     * @return 用户名
     */
    public String getUsernameFromToken(String token)
    {
        Claims claims = parseToken(token);
        return claims.getSubject();
    }

    /**
     * 获取请求 token。
     *
     * @param request 请求
     * @return token
     */
    private String getToken(HttpServletRequest request)
    {
        String token = request.getHeader(header);
        if (StringUtils.isNotEmpty(token) && token.startsWith(Constants.TOKEN_PREFIX))
        {
            token = token.replace(Constants.TOKEN_PREFIX, "");
        }
        return token;
    }

    private String getTokenKey(String uuid)
    {
        return getTokenKey(uuid, null);
    }

    private String getTokenKey(String uuid, String clientType)
    {
        return CacheConstants.LOGIN_TOKEN_KEY + normalizeClientType(clientType) + ":" + uuid;
    }

    private String normalizeClientType(String clientType)
    {
        if (CLIENT_TYPE_APP.equalsIgnoreCase(clientType))
        {
            return CLIENT_TYPE_APP;
        }
        return CLIENT_TYPE_WEB;
    }

    private int resolveExpireTime(String clientType)
    {
        return CLIENT_TYPE_APP.equals(clientType) ? appExpireTime : webExpireTime;
    }

    /**
     * 角色权限变更后，刷新所有持有该角色的在线用户权限。
     *
     * @param roleId 变更的角色ID
     * @param permissionService 权限服务
     */
    public void refreshPermissionByRoleId(Long roleId, SysPermissionService permissionService)
    {
        String pattern = CacheConstants.LOGIN_TOKEN_KEY + "*";
        Collection<String> keys = redisCache.keys(pattern);
        if (keys == null || keys.isEmpty())
        {
            return;
        }
        for (String key : keys)
        {
            LoginUser loginUser = redisCache.getCacheObject(key);
            if (loginUser == null || loginUser.getUser() == null || loginUser.getUser().isAdmin())
            {
                continue;
            }
            boolean hasRole = loginUser.getUser().getRoles() != null
                    && loginUser.getUser().getRoles().stream().anyMatch(r -> roleId.equals(r.getRoleId()));
            if (!hasRole)
            {
                continue;
            }
            loginUser.setPermissions(permissionService.getMenuPermission(loginUser.getUser()));
            refreshToken(loginUser);
            log.info("角色[{}]权限变更，已刷新在线用户[{}]的权限缓存", roleId, loginUser.getUsername());
        }
    }
}
