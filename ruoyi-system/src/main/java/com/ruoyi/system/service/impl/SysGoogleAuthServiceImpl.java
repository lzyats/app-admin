package com.ruoyi.system.service.impl;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.GoogleTotpUtils;
import com.ruoyi.system.domain.SysUserGoogleAuth;
import com.ruoyi.system.mapper.SysUserGoogleAuthMapper;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysGoogleAuthService;

@Service
public class SysGoogleAuthServiceImpl implements ISysGoogleAuthService
{
    private static final String GOOGLE_BIND_CACHE_KEY = "google:bind:secret:";

    @Autowired
    private RedisCache redisCache;

    @Autowired
    private SysUserGoogleAuthMapper googleAuthMapper;

    @Autowired
    private ISysConfigService configService;

    @Override
    public Map<String, Object> status(Long userId, String userName)
    {
        SysUserGoogleAuth auth = googleAuthMapper.selectByUserId(userId);
        boolean enabled = auth != null && auth.getEnabled() != null && auth.getEnabled() == 1
            && StringUtils.isNotBlank(auth.getSecret());
        Map<String, Object> data = new HashMap<>();
        data.put("enabled", enabled);
        data.put("userName", userName);
        return data;
    }

    @Override
    public Map<String, Object> initBind(Long userId, String userName)
    {
        String secret = GoogleTotpUtils.generateSecret();
        redisCache.setCacheObject(cacheKey(userId), secret, 10, TimeUnit.MINUTES);
        String issuer = configService.selectConfigByKey("sys.google.auth.issuer");
        if (StringUtils.isBlank(issuer))
        {
            issuer = "RuoYiAdmin";
        }
        String otpAuthUrl = GoogleTotpUtils.buildOtpAuthUri(issuer, userName, secret);
        Map<String, Object> data = new HashMap<>();
        data.put("secret", secret);
        data.put("otpAuthUrl", otpAuthUrl);
        data.put("issuer", issuer);
        data.put("expireMinutes", 10);
        return data;
    }

    @Override
    public void bind(Long userId, String userName, String code)
    {
        if (StringUtils.isBlank(code))
        {
            throw new ServiceException("Google验证码不能为空");
        }
        String secret = redisCache.getCacheObject(cacheKey(userId));
        if (StringUtils.isBlank(secret))
        {
            throw new ServiceException("绑定会话已过期，请重新发起绑定");
        }
        if (!GoogleTotpUtils.verifyCode(secret, code))
        {
            throw new ServiceException("Google验证码错误");
        }
        googleAuthMapper.upsert(userId, secret, 1);
        redisCache.deleteObject(cacheKey(userId));
    }

    @Override
    public void unbind(Long userId, String code)
    {
        SysUserGoogleAuth auth = googleAuthMapper.selectByUserId(userId);
        if (auth == null || auth.getEnabled() == null || auth.getEnabled() != 1 || StringUtils.isBlank(auth.getSecret()))
        {
            throw new ServiceException("当前账号未绑定Google验证");
        }
        if (!GoogleTotpUtils.verifyCode(auth.getSecret(), code))
        {
            throw new ServiceException("Google验证码错误");
        }
        googleAuthMapper.deleteByUserId(userId);
    }

    @Override
    public void validateOperation(Long userId, String googleCode)
    {
        if (StringUtils.isBlank(googleCode))
        {
            throw new ServiceException("敏感操作需要输入Google验证码");
        }
        SysUserGoogleAuth auth = googleAuthMapper.selectByUserId(userId);
        if (auth == null || auth.getEnabled() == null || auth.getEnabled() != 1 || StringUtils.isBlank(auth.getSecret()))
        {
            throw new ServiceException("当前账号未绑定Google验证，请先绑定后再执行敏感操作");
        }
        if (!GoogleTotpUtils.verifyCode(auth.getSecret(), googleCode))
        {
            throw new ServiceException("Google验证码错误或已过期");
        }
    }

    private String cacheKey(Long userId)
    {
        return GOOGLE_BIND_CACHE_KEY + userId;
    }
}
