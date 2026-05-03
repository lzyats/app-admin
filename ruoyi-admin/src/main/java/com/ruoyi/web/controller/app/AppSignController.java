package com.ruoyi.web.controller.app;

import java.util.LinkedHashMap;
import java.util.Map;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysUserService;
import com.ruoyi.system.service.ISysUserSignService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * APP 签到接口
 */
@RestController
@RequestMapping("/app/sign")
public class AppSignController {
    private static final String SIGN_REWARD_TYPE_KEY = "app.sign.rewardType";
    private static final String SIGN_REWARD_AMOUNT_KEY = "app.sign.rewardAmount";
    private static final String SIGN_CONTINUOUS_RULE_KEY = "app.sign.continuousRewardRule";

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ISysUserSignService signService;

    @Autowired
    private ISysConfigService configService;

    @GetMapping("/config")
    public AjaxResult config() {
        Map<String, Object> data = new LinkedHashMap<String, Object>();
        data.put("rewardType", normalizeText(configService.selectConfigByKey(SIGN_REWARD_TYPE_KEY), "POINT"));
        data.put("rewardAmount", normalizeNumber(configService.selectConfigByKey(SIGN_REWARD_AMOUNT_KEY), "1"));
        data.put("continuousRewardRule", normalizeJson(configService.selectConfigByKey(SIGN_CONTINUOUS_RULE_KEY), "[]"));
        return AjaxResult.success(data);
    }

    @GetMapping("/status")
    public AjaxResult status() {
        Long userId = SecurityUtils.getUserId();
        if (userId == null || userId <= 0) {
            return AjaxResult.error("User is not logged in.");
        }
        SysUser user = userService.selectUserById(userId);
        if (user == null) {
            return AjaxResult.error("User does not exist.");
        }
        return AjaxResult.success(signService.getTodayStatus(userId, user.getUserName()));
    }

    @PostMapping("/submit")
    public AjaxResult submit() {
        Long userId = SecurityUtils.getUserId();
        if (userId == null || userId <= 0) {
            return AjaxResult.error("User is not logged in.");
        }
        SysUser user = userService.selectUserById(userId);
        if (user == null) {
            return AjaxResult.error("User does not exist.");
        }
        try {
            return AjaxResult.success(signService.signToday(userId, user.getUserName()));
        } catch (IllegalStateException ex) {
            return AjaxResult.error(ex.getMessage());
        }
    }

    private String normalizeText(String value, String defaultValue) {
        String trimmed = StringUtils.trim(value);
        return StringUtils.isEmpty(trimmed) ? defaultValue : trimmed;
    }

    private String normalizeNumber(String value, String defaultValue) {
        String trimmed = StringUtils.trim(value);
        if (StringUtils.isEmpty(trimmed)) {
            return defaultValue;
        }
        return trimmed;
    }

    private String normalizeJson(String value, String defaultValue) {
        String trimmed = StringUtils.trim(value);
        if (StringUtils.isEmpty(trimmed)) {
            return defaultValue;
        }
        try {
            Object parsed = com.alibaba.fastjson2.JSON.parse(trimmed);
            return com.alibaba.fastjson2.JSON.toJSONString(parsed);
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
