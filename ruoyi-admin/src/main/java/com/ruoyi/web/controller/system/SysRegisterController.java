package com.ruoyi.web.controller.system;

import java.util.HashSet;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.ruoyi.common.constant.Constants;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.model.LoginUser;
import com.ruoyi.common.core.domain.model.RegisterBody;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.security.crypto.ApiCryptoService;
import com.ruoyi.framework.web.service.SysLoginService;
import com.ruoyi.framework.web.service.SysRegisterService;
import com.ruoyi.framework.web.service.TokenService;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysUserService;
import tools.jackson.databind.ObjectMapper;

/**
 * 注册验证
 *
 * @author ruoyi
 */
@RestController
public class SysRegisterController extends BaseController
{
    @Autowired
    private SysRegisterService registerService;

    @Autowired
    private SysLoginService loginService;

    @Autowired
    private TokenService tokenService;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ApiCryptoService apiCryptoService;

    @Autowired
    private ObjectMapper objectMapper;

    @PostMapping("/register")
    public AjaxResult register(@RequestBody Map<String, Object> user)
    {
        if (!"true".equals(configService.selectConfigByKey("sys.account.registerUser")))
        {
            return error("当前系统没有开启注册功能！");
        }

        RegisterBody registerBody = resolveRegisterBody(user);
        String msg = registerService.register(registerBody);
        if (StringUtils.isNotEmpty(msg))
        {
            return error(msg);
        }

        String username = StringUtils.trim(registerBody.getUsername());
        SysUser registeredUser = userService.selectUserBaseByUserName(username);
        if (registeredUser == null)
        {
            return error("注册成功，但自动登录失败：用户不存在");
        }

        LoginUser loginUser = new LoginUser(
                registeredUser.getUserId(),
                registeredUser.getDeptId(),
                registeredUser,
                new HashSet<>());
        String token = tokenService.createToken(loginUser, "app");
        loginService.recordLoginInfo(registeredUser.getUserId());

        AjaxResult ajax = success();
        ajax.put(Constants.TOKEN, token);
        ajax.put("user", loginService.toAppUser(registeredUser));
        return ajax;
    }

    private RegisterBody resolveRegisterBody(Map<String, Object> user)
    {
        if (user == null || user.isEmpty())
        {
            return new RegisterBody();
        }

        Object encryptedData = user.get("data");
        if (encryptedData instanceof String encryptedText && StringUtils.isNotBlank(encryptedText))
        {
            try
            {
                String plainJson = apiCryptoService.decryptText(encryptedText);
                return objectMapper.readValue(plainJson, RegisterBody.class);
            }
            catch (Exception e)
            {
                throw new RuntimeException("注册请求解密失败", e);
            }
        }

        return objectMapper.convertValue(user, RegisterBody.class);
    }
}
