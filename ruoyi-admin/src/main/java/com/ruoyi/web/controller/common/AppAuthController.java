package com.ruoyi.web.controller.common;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.constant.CacheConstants;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.constant.UserConstants;
import com.ruoyi.common.exception.user.CaptchaException;
import com.ruoyi.common.exception.user.CaptchaExpireException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysUserService;

/**
 * APP 认证扩展接口。
 */
@RestController
@RequestMapping("/app/auth")
public class AppAuthController
{
    @Autowired
    private ISysUserService userService;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private RedisCache redisCache;

    /**
     * 忘记密码：通过用户名+邮箱校验后重置密码。
     */
    @PostMapping("/forgotPwd")
    public AjaxResult forgotPwd(@RequestBody ForgotPwdBody body)
    {
        String username = StringUtils.trim(body.getUsername());
        String email = StringUtils.trim(body.getEmail());
        String newPassword = StringUtils.trim(body.getNewPassword());

        if (StringUtils.isEmpty(username) || StringUtils.isEmpty(email) || StringUtils.isEmpty(newPassword))
        {
            return AjaxResult.error("用户名、邮箱、新密码不能为空");
        }
        if (newPassword.length() < UserConstants.PASSWORD_MIN_LENGTH
                || newPassword.length() > UserConstants.PASSWORD_MAX_LENGTH)
        {
            return AjaxResult.error("密码长度必须在5到20个字符之间");
        }

        validateCaptchaIfNeeded(body.getCode(), body.getUuid());

        SysUser user = userService.selectUserByUserName(username);
        if (user == null)
        {
            return AjaxResult.error("用户不存在");
        }
        if (StringUtils.isEmpty(user.getEmail()) || !StringUtils.equalsIgnoreCase(user.getEmail(), email))
        {
            return AjaxResult.error("用户名与邮箱不匹配");
        }

        String encryptedPwd = SecurityUtils.encryptPassword(newPassword);
        int rows = userService.resetUserPwd(user.getUserId(), encryptedPwd);
        if (rows <= 0)
        {
            return AjaxResult.error("重置密码失败，请稍后重试");
        }
        return AjaxResult.success("密码重置成功");
    }

    /**
     * 按系统开关校验验证码。
     */
    private void validateCaptchaIfNeeded(String code, String uuid)
    {
        boolean captchaEnabled = configService.selectCaptchaEnabled();
        if (!captchaEnabled)
        {
            return;
        }

        String verifyKey = CacheConstants.CAPTCHA_CODE_KEY + StringUtils.nvl(uuid, "");
        String captcha = redisCache.getCacheObject(verifyKey);
        redisCache.deleteObject(verifyKey);
        if (captcha == null)
        {
            throw new CaptchaExpireException();
        }
        if (!StringUtils.equalsIgnoreCase(code, captcha))
        {
            throw new CaptchaException();
        }
    }

    /**
     * 忘记密码请求体。
     */
    public static class ForgotPwdBody
    {
        /**
         * 用户名。
         */
        private String username;

        /**
         * 注册邮箱。
         */
        private String email;

        /**
         * 新密码。
         */
        private String newPassword;

        /**
         * 验证码。
         */
        private String code;

        /**
         * 验证码唯一标识。
         */
        private String uuid;

        public String getUsername()
        {
            return username;
        }

        public void setUsername(String username)
        {
            this.username = username;
        }

        public String getEmail()
        {
            return email;
        }

        public void setEmail(String email)
        {
            this.email = email;
        }

        public String getNewPassword()
        {
            return newPassword;
        }

        public void setNewPassword(String newPassword)
        {
            this.newPassword = newPassword;
        }

        public String getCode()
        {
            return code;
        }

        public void setCode(String code)
        {
            this.code = code;
        }

        public String getUuid()
        {
            return uuid;
        }

        public void setUuid(String uuid)
        {
            this.uuid = uuid;
        }
    }
}
