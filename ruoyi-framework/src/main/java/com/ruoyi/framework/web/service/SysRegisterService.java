package com.ruoyi.framework.web.service;

import java.security.SecureRandom;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.ruoyi.common.constant.CacheConstants;
import com.ruoyi.common.constant.Constants;
import com.ruoyi.common.constant.UserConstants;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.model.RegisterBody;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.exception.user.CaptchaException;
import com.ruoyi.common.exception.user.CaptchaExpireException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.MessageUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.manager.AsyncManager;
import com.ruoyi.framework.manager.factory.AsyncFactory;
import com.ruoyi.common.core.domain.entity.SysUserWallet;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysUserService;
import com.ruoyi.system.service.ISysUserWalletService;

/**
 * 注册服务。
 *
 * 注册时会创建用户基础资料、生成邀请码，并通过统一的用户服务完成缓存读写与失效。
 */
@Component
public class SysRegisterService
{
    private static final String INVITE_CODE_CONFIG_KEY = "app.feature.inviteCodeEnabled";
    private static final String ROOT_LEVEL_DETAIL = "0";
    private static final char[] INVITE_CHARSET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ".toCharArray();
    private static final int INVITE_CODE_LENGTH = 6;
    private static final int INVITE_CODE_RETRY_MAX = 12;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private static final String INVITE_CODE_CACHE_PREFIX = "invite_code:";

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private RedisCache redisCache;

    @Autowired
    private ISysUserWalletService walletService;

    /**
     * 用户注册。
     */
    public String register(RegisterBody registerBody)
    {
        String msg = "";
        String username = StringUtils.trim(registerBody.getUsername());
        String password = StringUtils.trim(registerBody.getPassword());

        SysUser sysUser = new SysUser();
        sysUser.setUserName(username);

        boolean captchaEnabled = configService.selectCaptchaEnabled();
        if (captchaEnabled)
        {
            validateCaptcha(registerBody.getCode(), registerBody.getUuid());
        }

        if (StringUtils.isEmpty(username))
        {
            msg = "用户名不能为空";
        }
        else if (StringUtils.isEmpty(password))
        {
            msg = "用户密码不能为空";
        }
        else if (username.length() < UserConstants.USERNAME_MIN_LENGTH
                || username.length() > UserConstants.USERNAME_MAX_LENGTH)
        {
            msg = "账户长度必须在2到20个字符之间";
        }
        else if (password.length() < UserConstants.PASSWORD_MIN_LENGTH
                || password.length() > UserConstants.PASSWORD_MAX_LENGTH)
        {
            msg = "密码长度必须在5到20个字符之间";
        }
        else if (!userService.checkUserNameUnique(sysUser))
        {
            msg = "保存用户'" + username + "'失败，注册账号已存在";
        }
        else
        {
            if (isInviteEnabled())
            {
                String inviteCodeInput = StringUtils.trim(registerBody.getInviteCode());
                if (StringUtils.isEmpty(inviteCodeInput))
                {
                    return "当前系统要求填写邀请码";
                }
                SysUser inviter = findInviterByInviteCode(inviteCodeInput);
                if (inviter == null)
                {
                    return "邀请码无效，请检查后重试";
                }

                String inviterLevelDetail = StringUtils.isEmpty(inviter.getLevelDetail())
                        ? ROOT_LEVEL_DETAIL
                        : inviter.getLevelDetail();
                String levelDetail = inviterLevelDetail + "," + inviter.getUserId();
                sysUser.setLevelDetail(levelDetail);
                sysUser.setUserLevel(calcUserLevel(levelDetail));
            }
            else
            {
                sysUser.setLevelDetail(ROOT_LEVEL_DETAIL);
                sysUser.setUserLevel(0);
            }

            sysUser.setInviteCode(generateUniqueInviteCode());
            sysUser.setNickName(username);
            sysUser.setPwdUpdateDate(DateUtils.getNowDate());
            sysUser.setPassword(SecurityUtils.encryptPassword(password));
            boolean regFlag = userService.registerUser(sysUser);
            if (!regFlag)
            {
                msg = "注册失败，请联系系统管理人员";
            }
            else
            {
                cacheInviteCode(sysUser.getInviteCode(), sysUser.getUserId());
                ensureDefaultWallets(sysUser);
                AsyncManager.me().execute(AsyncFactory.recordLogininfor(
                        username,
                        Constants.REGISTER,
                        MessageUtils.message("user.register.success")));
            }
        }
        return msg;
    }

    /**
     * 校验验证码。
     */
    private void validateCaptcha(String code, String uuid)
    {
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
     * 是否启用邀请码。
     */
    private boolean isInviteEnabled()
    {
        String enabled = configService.selectConfigByKey(INVITE_CODE_CONFIG_KEY);
        return "true".equalsIgnoreCase(StringUtils.trim(enabled));
    }

    /**
     * 计算用户层级。
     */
    private int calcUserLevel(String levelDetail)
    {
        if (StringUtils.isEmpty(levelDetail))
        {
            return 0;
        }
        String[] parts = levelDetail.split(",");
        return Math.max(parts.length - 1, 0);
    }

    /**
     * 生成唯一邀请码。
     */
    private String generateUniqueInviteCode()
    {
        for (int i = 0; i < INVITE_CODE_RETRY_MAX; i++)
        {
            String code = randomInviteCode();
            if (userService.selectUserByInviteCode(code) == null)
            {
                return code;
            }
        }
        throw new IllegalStateException("邀请码生成失败，请稍后重试");
    }

    /**
     * 生成6位邀请码。
     */
    private String randomInviteCode()
    {
        StringBuilder sb = new StringBuilder(INVITE_CODE_LENGTH);
        for (int i = 0; i < INVITE_CODE_LENGTH; i++)
        {
            int index = SECURE_RANDOM.nextInt(INVITE_CHARSET.length);
            sb.append(INVITE_CHARSET[index]);
        }
        return sb.toString();
    }

    /**
     * 根据邀请码查找邀请人，优先从 Redis 缓存获取。
     */
    private SysUser findInviterByInviteCode(String inviteCode)
    {
        String cacheKey = INVITE_CODE_CACHE_PREFIX + inviteCode;
        Long inviterId = redisCache.getCacheObject(cacheKey);
        if (inviterId != null)
        {
            return userService.selectUserById(inviterId);
        }
        SysUser inviter = userService.selectUserByInviteCode(inviteCode);
        if (inviter != null)
        {
            redisCache.setCacheObject(cacheKey, inviter.getUserId());
        }
        return inviter;
    }

    /**
     * 缓存邀请码到用户ID的映射。
     */
    private void cacheInviteCode(String inviteCode, Long userId)
    {
        if (StringUtils.isNotEmpty(inviteCode) && userId != null)
        {
            String cacheKey = INVITE_CODE_CACHE_PREFIX + inviteCode;
            redisCache.setCacheObject(cacheKey, userId);
        }
    }

    /**
     * 为新用户补齐默认钱包。
     */
    private void ensureDefaultWallets(SysUser sysUser)
    {
        if (sysUser == null || sysUser.getUserId() == null)
        {
            return;
        }
        createWalletIfAbsent(sysUser.getUserId(), "CNY");
        createWalletIfAbsent(sysUser.getUserId(), "USD");
    }

    private void createWalletIfAbsent(Long userId, String currencyType)
    {
        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyType(userId, currencyType);
        if (wallet != null)
        {
            return;
        }
        SysUserWallet newWallet = new SysUserWallet();
        newWallet.setUserId(userId);
        newWallet.setCurrencyType(currencyType);
        newWallet.setTotalInvest(0D);
        newWallet.setAvailableBalance(0D);
        newWallet.setFrozenAmount(0D);
        newWallet.setProfitAmount(0D);
        newWallet.setPendingAmount(0D);
        newWallet.setTotalRecharge(0D);
        newWallet.setTotalWithdraw(0D);
        walletService.insertWallet(newWallet);
    }
}
