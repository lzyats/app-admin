package com.ruoyi.web.controller.system;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.ruoyi.common.constant.Constants;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysMenu;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.model.LoginUser;
import com.ruoyi.common.core.domain.model.LoginBody;
import com.ruoyi.common.core.text.Convert;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.ServletUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.security.crypto.ApiCryptoService;
import com.ruoyi.framework.web.service.SysLoginService;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysMenuService;
import com.ruoyi.system.service.ISysTeamLevelService;
import com.ruoyi.system.service.ISysUserService;
import com.ruoyi.system.domain.vo.RouterVo;
import tools.jackson.databind.ObjectMapper;

/**
 * 登录验证码
 */
@RestController
public class SysLoginController {
    private static final String CACHE_KEY_ROUTERS_PREFIX = "cache:router:";
    private static final Integer CACHE_ROUTERS_TTL_MINUTES = 5;

    @Autowired
    private SysLoginService loginService;

    @Autowired
    private ISysMenuService menuService;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ISysTeamLevelService teamLevelService;

    @Autowired
    private RedisCache redisCache;

    @Autowired
    private ApiCryptoService apiCryptoService;

    @Autowired
    private ObjectMapper objectMapper;

    /**
     * 登录方法
     */
    @PostMapping("/login")
    public AjaxResult login(@RequestBody Map<String, Object> loginBody) {
        LoginBody resolvedLoginBody = resolveLoginBody(loginBody);
        AjaxResult ajax = AjaxResult.success();
        String token = loginService.login(
                resolvedLoginBody.getUsername(),
                resolvedLoginBody.getPassword(),
                resolvedLoginBody.getCode(),
                resolvedLoginBody.getUuid());
        ajax.put(Constants.TOKEN, token);
        return ajax;
    }

    /**
     * 获取登录用户的基础信息。
     * 这里只返回 APP 首页和个人信息页所需的基础资料，不再携带权限、钱包等重复数据。
     */
    @GetMapping("getInfo")
    public AjaxResult getInfo() {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        SysUser loginUserInfo = loginUser.getUser();
        boolean appClient = isAppClient();
        Long userId = resolveUserId(loginUser, loginUserInfo);
        SysUser user = null;
        if (userId != null) {
            if (appClient)
            {
                teamLevelService.checkAndUpgradeUserTeamLevel(userId);
            }
            user = appClient
                    ? userService.selectUserBaseById(userId)
                    : userService.selectUserById(userId);
        }
        if (user == null) {
            user = loginUserInfo;
        } else if (loginUserInfo != null) {
            if (user.getRoles() == null || user.getRoles().isEmpty()) {
                user.setRoles(loginUserInfo.getRoles());
            }
            if (user.getRoleIds() == null || user.getRoleIds().length == 0) {
                user.setRoleIds(loginUserInfo.getRoleIds());
            }
        }
        if (user != null) {
            user.setPayPasswordSet(StringUtils.isNotBlank(user.getPayPassword()) ? 1 : 0);
        }
        AjaxResult ajax = AjaxResult.success();
        ajax.put("user", user);
        ajax.put("roles", appClient
                ? new ArrayList<>()
                : (user != null && user.getRoles() != null
                ? user.getRoles()
                : (loginUserInfo != null && loginUserInfo.getRoles() != null ? loginUserInfo.getRoles() : new ArrayList<>())));
        ajax.put("permissions", appClient
                ? new ArrayList<>()
                : (loginUser.getPermissions() != null ? new ArrayList<>(loginUser.getPermissions()) : new ArrayList<>()));
        ajax.put("pwdChrtype", getSysAccountChrtype());
        Date pwdUpdateDate = user != null ? user.getPwdUpdateDate() : null;
        ajax.put("isDefaultModifyPwd", initPasswordIsModify(pwdUpdateDate));
        ajax.put("isPasswordExpired", passwordIsExpiration(pwdUpdateDate));
        return ajax;
    }

    /**
     * 获取路由信息
     */
    @GetMapping("getRouters")
    public AjaxResult getRouters() {
        Long userId = SecurityUtils.getUserId();
        String cacheKey = CACHE_KEY_ROUTERS_PREFIX + userId;
        List<RouterVo> cached = redisCache.getCacheObject(cacheKey);
        if (cached != null)
        {
            return AjaxResult.success(cached);
        }
        List<SysMenu> menus = menuService.selectMenuTreeByUserId(userId);
        List<RouterVo> routers = menuService.buildMenus(menus);
        redisCache.setCacheObject(cacheKey, routers, CACHE_ROUTERS_TTL_MINUTES, TimeUnit.MINUTES);
        return AjaxResult.success(routers);
    }

    private String getSysAccountChrtype() {
        return Convert.toStr(configService.selectConfigByKey("sys.account.chrtype"), "0");
    }

    private boolean initPasswordIsModify(Date pwdUpdateDate) {
        Integer initPasswordModify = Convert.toInt(configService.selectConfigByKey("sys.account.initPasswordModify"));
        return initPasswordModify != null && initPasswordModify == 1 && pwdUpdateDate == null;
    }

    private boolean passwordIsExpiration(Date pwdUpdateDate) {
        Integer passwordValidateDays = Convert.toInt(configService.selectConfigByKey("sys.account.passwordValidateDays"));
        if (passwordValidateDays != null && passwordValidateDays > 0) {
            if (StringUtils.isNull(pwdUpdateDate)) {
                return true;
            }
            Date nowDate = DateUtils.getNowDate();
            return DateUtils.differentDaysByMillisecond(nowDate, pwdUpdateDate) > passwordValidateDays;
        }
        return false;
    }

    private LoginBody resolveLoginBody(Map<String, Object> loginBody) {
        if (loginBody == null || loginBody.isEmpty()) {
            return new LoginBody();
        }

        Object encryptedData = loginBody.get("data");
        if (encryptedData instanceof String encryptedText && StringUtils.isNotBlank(encryptedText)) {
            try {
                String plainJson = apiCryptoService.decryptText(encryptedText);
                return objectMapper.readValue(plainJson, LoginBody.class);
            } catch (Exception e) {
                throw new RuntimeException("登录请求解密失败", e);
            }
        }

        return objectMapper.convertValue(loginBody, LoginBody.class);
    }

    private boolean isAppClient() {
        String clientType = ServletUtils.getRequest().getHeader("X-Client-Type");
        return "app".equalsIgnoreCase(clientType);
    }

    private Long resolveUserId(LoginUser loginUser, SysUser loginUserInfo) {
        if (loginUser != null && loginUser.getUserId() != null) {
            return loginUser.getUserId();
        }
        if (loginUserInfo != null && loginUserInfo.getUserId() != null) {
            return loginUserInfo.getUserId();
        }
        return null;
    }
}
