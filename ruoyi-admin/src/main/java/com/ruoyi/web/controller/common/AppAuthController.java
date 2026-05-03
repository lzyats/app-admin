package com.ruoyi.web.controller.common;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Anonymous;
import com.ruoyi.common.constant.CacheConstants;
import com.ruoyi.common.constant.Constants;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.model.LoginBody;
import com.ruoyi.common.core.domain.model.LoginUser;
import com.ruoyi.common.core.domain.model.RegisterBody;
import com.ruoyi.common.core.domain.model.SecurityAnswerBody;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.exception.user.CaptchaException;
import com.ruoyi.common.exception.user.CaptchaExpireException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.security.crypto.ApiCryptoService;
import com.ruoyi.framework.web.service.SysLoginService;
import com.ruoyi.framework.web.service.SysRegisterService;
import com.ruoyi.framework.web.service.TokenService;
import com.ruoyi.system.domain.SysAppRealNameAuth;
import com.ruoyi.system.domain.SysSecurityQuestion;
import com.ruoyi.system.domain.SysUserSecurityAnswer;
import com.ruoyi.system.service.ISysAppRealNameAuthService;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysSecurityQuestionService;
import com.ruoyi.system.service.ISysUserSecurityAnswerService;
import com.ruoyi.system.service.ISysUserService;
import tools.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/app/auth")
public class AppAuthController {

    /**
     * APP 认证与账户安全入口。
     *
     * 这里包含登录辅助、找回密码、安全问题、实名认证等接口，用户读取统一走用户服务缓存链路。
     */

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private RedisCache redisCache;

    @Autowired
    private ISysSecurityQuestionService questionService;

    @Autowired
    private ISysUserSecurityAnswerService answerService;

    @Autowired
    private ISysAppRealNameAuthService realNameAuthService;

    @Autowired
    private ApiCryptoService apiCryptoService;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private SysLoginService loginService;

    @Autowired
    private SysRegisterService registerService;

    @Autowired
    private TokenService tokenService;

    @Anonymous
    @PostMapping("/login")
    public AjaxResult login(@RequestBody Map<String, Object> loginBody)
    {
        LoginBody resolvedLoginBody = resolveLoginBody(loginBody);
        Map<String, Object> resp = loginService.loginForApp(
                resolvedLoginBody.getUsername(),
                resolvedLoginBody.getPassword(),
                resolvedLoginBody.getCode(),
                resolvedLoginBody.getUuid());
        AjaxResult ajax = AjaxResult.success();
        ajax.putAll(resp);
        return ajax;
    }

    @Anonymous
    @PostMapping("/register")
    public AjaxResult register(@RequestBody Map<String, Object> body)
    {
        if (!"true".equals(configService.selectConfigByKey("sys.account.registerUser")))
        {
            return AjaxResult.error("当前系统没有开启注册功能！");
        }

        RegisterBody registerBody = resolveRegisterBody(body);
        String msg = registerService.register(registerBody);
        if (StringUtils.isNotEmpty(msg))
        {
            return AjaxResult.error(msg);
        }

        String username = StringUtils.trim(registerBody.getUsername());
        SysUser registeredUser = userService.selectUserBaseByUserName(username);
        if (registeredUser == null)
        {
            return AjaxResult.error("注册成功，但自动登录失败：用户不存在");
        }

        LoginUser loginUser = new LoginUser(
                registeredUser.getUserId(),
                registeredUser.getDeptId(),
                registeredUser,
                new HashSet<>());
        String token = tokenService.createToken(loginUser, "app");
        loginService.recordLoginInfo(registeredUser.getUserId());

        AjaxResult ajax = AjaxResult.success();
        ajax.put(Constants.TOKEN, token);
        ajax.put("user", loginService.toAppUser(registeredUser));
        return ajax;
    }

    private LoginBody resolveLoginBody(Map<String, Object> loginBody)
    {
        if (loginBody == null || loginBody.isEmpty())
        {
            return new LoginBody();
        }
        Object encryptedData = loginBody.get("data");
        if (encryptedData instanceof String encryptedText && StringUtils.isNotBlank(encryptedText))
        {
            try
            {
                String plainJson = apiCryptoService.decryptText(encryptedText);
                return objectMapper.readValue(plainJson, LoginBody.class);
            }
            catch (Exception e)
            {
                throw new RuntimeException("登录请求解密失败", e);
            }
        }
        return objectMapper.convertValue(loginBody, LoginBody.class);
    }

    private RegisterBody resolveRegisterBody(Map<String, Object> registerBody)
    {
        if (registerBody == null || registerBody.isEmpty())
        {
            return new RegisterBody();
        }
        Object encryptedData = registerBody.get("data");
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
        return objectMapper.convertValue(registerBody, RegisterBody.class);
    }

    @Anonymous
    @PostMapping("/forgotPwdBySecurity")
    public AjaxResult forgotPwdBySecurity(@RequestBody Map<String, Object> bodyMap) {
        ForgotPwdBySecurityBody body = resolveForgotPwdBody(bodyMap);
        String username = StringUtils.trim(body.getUsername());
        String newPassword = StringUtils.trim(body.getNewPassword());
        List<SecurityAnswerBody> answers = body.getAnswers();

        if (StringUtils.isEmpty(username)) {
            return AjaxResult.error("Username cannot be empty");
        }
        if (StringUtils.isEmpty(newPassword)) {
            return AjaxResult.error("New password cannot be empty");
        }
        if (newPassword.length() < 5 || newPassword.length() > 20) {
            return AjaxResult.error("Password length must be between 5 and 20 characters");
        }
        if (answers == null || answers.size() < 2) {
            return AjaxResult.error("At least 2 security answers are required");
        }

        validateCaptchaIfNeeded(body.getCode(), body.getUuid());

        SysUser user = userService.selectUserByUserName(username);
        if (user == null) {
            return AjaxResult.error("User does not exist");
        }

        for (SecurityAnswerBody answer : answers) {
            if (answer.getQuestionId() == null || StringUtils.isEmpty(answer.getAnswer())) {
                return AjaxResult.error("Security question or answer cannot be empty");
            }
            if (!answerService.verifyAnswer(user.getUserId(), answer.getQuestionId(), answer.getAnswer())) {
                return AjaxResult.error("Security answer is incorrect");
            }
        }

        String encryptedPwd = SecurityUtils.encryptPassword(newPassword);
        int rows = userService.resetUserPwd(user.getUserId(), encryptedPwd);
        return rows > 0 ? AjaxResult.success("Password reset successfully") : AjaxResult.error("Failed to reset password");
    }

    @Anonymous
    @PostMapping("/security/questions")
    public AjaxResult getSecurityQuestions(@RequestBody(required = false) Map<String, String> params) {
        String lang = params != null ? params.get("lang") : null;
        return AjaxResult.success(questionService.selectQuestionAll(lang));
    }

    @Anonymous
    @PostMapping("/security/hasSet")
    public AjaxResult hasSecurityQuestions(@RequestBody HasSecurityQuestionsBody body) {
        String username = StringUtils.trim(body.getUsername());
        if (StringUtils.isEmpty(username)) {
            return AjaxResult.error("Username cannot be empty");
        }

        SysUser user = userService.selectUserByUserName(username);
        if (user == null) {
            return AjaxResult.error("User does not exist");
        }

        return AjaxResult.success(answerService.selectAnswerCountByUserId(user.getUserId()) >= 2);
    }

    @Anonymous
    @PostMapping("/security/myQuestions")
    public AjaxResult getMySecurityQuestions(@RequestBody(required = false) Map<String, String> params) {
        String username = params != null ? StringUtils.trim(params.get("username")) : null;
        if (StringUtils.isEmpty(username)) {
            return AjaxResult.error("Username cannot be empty");
        }

        SysUser user = userService.selectUserByUserName(username);
        if (user == null) {
            return AjaxResult.error("User does not exist");
        }

        List<SysUserSecurityAnswer> answers = answerService.selectAnswerByUserId(user.getUserId());
        List<Map<String, Object>> result = new ArrayList<>();
        for (SysUserSecurityAnswer answer : answers) {
            SysSecurityQuestion question = questionService.selectQuestionById(answer.getQuestionId());
            if (question == null) {
                continue;
            }
            Map<String, Object> item = new HashMap<>();
            item.put("questionId", question.getQuestionId());
            item.put("questionText", question.getQuestionText());
            result.add(item);
        }
        return AjaxResult.success(result);
    }

    @PostMapping("/realName/status")
    public AjaxResult getRealNameStatus() {
        Map<String, Object> result = new HashMap<>();
        result.put("handheldRequired", readBool("app.feature.realNameHandheldRequired", false));

        Long userId = SecurityUtils.getUserId();
        if (userId != null && userId > 0) {
            SysUser user = userService.selectUserById(userId);
            result.put("status", user != null && user.getRealNameStatus() != null ? user.getRealNameStatus() : 0);
            SysAppRealNameAuth latestAuth = realNameAuthService.selectAuthByUserId(userId);
            if (latestAuth != null) {
                result.put("latestAuth", latestAuth);
            }
        } else {
            result.put("status", 0);
        }

        return AjaxResult.success(result);
    }

    @PostMapping("/realName/submit")
    public AjaxResult submitRealName(@RequestBody(required = false) Map<String, Object> bodyMap) {
        Long userId = SecurityUtils.getUserId();
        if (userId == null || userId <= 0) {
            return AjaxResult.error("User is not logged in");
        }
        boolean handheldRequired = readBool("app.feature.realNameHandheldRequired", false);

        RealNameAuthBody body = resolveRealNameAuthBody(bodyMap);

        String realName = StringUtils.trim(body.getRealName());
        String idCardNumber = StringUtils.trim(body.getIdCardNumber());
        String idCardFront = StringUtils.trim(body.getIdCardFront());
        String idCardBack = StringUtils.trim(body.getIdCardBack());
        String handheldPhoto = StringUtils.trim(body.getHandheldPhoto());

        if (StringUtils.isEmpty(realName)) {
            return AjaxResult.error("Real name cannot be empty");
        }
        if (StringUtils.isEmpty(idCardNumber)) {
            return AjaxResult.error("ID card number cannot be empty");
        }
        if (idCardNumber.length() != 15 && idCardNumber.length() != 18) {
            return AjaxResult.error("ID card number format is invalid");
        }
        if (StringUtils.isEmpty(idCardFront) || StringUtils.isEmpty(idCardBack)) {
            return AjaxResult.error("Please upload all required ID card images");
        }
        if (handheldRequired && StringUtils.isEmpty(handheldPhoto)) {
            return AjaxResult.error("Please upload all required ID card images");
        }

        SysUser user = userService.selectUserById(userId);
        if (user == null) {
            return AjaxResult.error("User does not exist");
        }

        SysAppRealNameAuth existing = realNameAuthService.selectAuthByUserId(userId);
        if (existing != null && existing.getStatus() != null && existing.getStatus() == 0) {
            return AjaxResult.error("Real name verification is pending");
        }

        SysAppRealNameAuth auth = new SysAppRealNameAuth();
        auth.setAuthId(null);
        auth.setUserId(userId);
        auth.setUserName(user.getUserName());
        auth.setRealName(realName);
        auth.setIdCardNumber(idCardNumber);
        auth.setIdCardFront(idCardFront);
        auth.setIdCardBack(idCardBack);
        auth.setHandheldPhoto(handheldRequired ? handheldPhoto : null);
        auth.setStatus(0);

        int rows = realNameAuthService.insertAuth(auth);
        return rows > 0 ? AjaxResult.success() : AjaxResult.error("Submission failed");
    }

    private RealNameAuthBody resolveRealNameAuthBody(Map<String, Object> bodyMap) {
        if (bodyMap == null || bodyMap.isEmpty()) {
            return new RealNameAuthBody();
        }

        Object encryptedData = bodyMap.get("data");
        if (encryptedData instanceof String encryptedText && StringUtils.isNotBlank(encryptedText)) {
            try {
                String plainJson = apiCryptoService.decryptText(encryptedText);
                return objectMapper.readValue(plainJson, RealNameAuthBody.class);
            } catch (Exception e) {
                throw new RuntimeException("实名认证请求解密失败", e);
            }
        }

        return objectMapper.convertValue(bodyMap, RealNameAuthBody.class);
    }

    private void validateCaptchaIfNeeded(String code, String uuid) {
        if (!configService.selectCaptchaEnabled()) {
            return;
        }
        if (StringUtils.isEmpty(code) || StringUtils.isEmpty(uuid)) {
            throw new CaptchaException();
        }
        String verifyKey = CacheConstants.CAPTCHA_CODE_KEY + uuid;
        String captcha = redisCache.getCacheObject(verifyKey);
        if (captcha == null) {
            throw new CaptchaExpireException();
        }
        redisCache.deleteObject(verifyKey);
        if (!StringUtils.equalsIgnoreCase(code, captcha)) {
            throw new CaptchaException();
        }
    }

    private ForgotPwdBySecurityBody resolveForgotPwdBody(Map<String, Object> bodyMap) {
        if (bodyMap == null || bodyMap.isEmpty()) {
            return new ForgotPwdBySecurityBody();
        }

        Object encryptedData = bodyMap.get("data");
        if (encryptedData instanceof String encryptedText && StringUtils.isNotBlank(encryptedText)) {
            try {
                String plainJson = apiCryptoService.decryptText(encryptedText);
                return objectMapper.readValue(plainJson, ForgotPwdBySecurityBody.class);
            } catch (Exception e) {
                throw new RuntimeException("找回密码请求解密失败", e);
            }
        }

        return objectMapper.convertValue(bodyMap, ForgotPwdBySecurityBody.class);
    }

    private boolean readBool(String key, boolean defaultValue) {
        String raw = StringUtils.trim(configService.selectConfigByKey(key));
        if (StringUtils.isEmpty(raw)) {
            return defaultValue;
        }
        return "1".equals(raw) || "true".equalsIgnoreCase(raw) || "yes".equalsIgnoreCase(raw);
    }

    public static class ForgotPwdBySecurityBody {
        private String username;
        private String newPassword;
        private List<SecurityAnswerBody> answers;
        private String code;
        private String uuid;

        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        public String getNewPassword() { return newPassword; }
        public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
        public List<SecurityAnswerBody> getAnswers() { return answers; }
        public void setAnswers(List<SecurityAnswerBody> answers) { this.answers = answers; }
        public String getCode() { return code; }
        public void setCode(String code) { this.code = code; }
        public String getUuid() { return uuid; }
        public void setUuid(String uuid) { this.uuid = uuid; }
    }

    public static class HasSecurityQuestionsBody {
        private String username;

        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
    }

    public static class RealNameAuthBody {
        private String realName;
        private String idCardNumber;
        private String idCardFront;
        private String idCardBack;
        private String handheldPhoto;

        public String getRealName() { return realName; }
        public void setRealName(String realName) { this.realName = realName; }
        public String getIdCardNumber() { return idCardNumber; }
        public void setIdCardNumber(String idCardNumber) { this.idCardNumber = idCardNumber; }
        public String getIdCardFront() { return idCardFront; }
        public void setIdCardFront(String idCardFront) { this.idCardFront = idCardFront; }
        public String getIdCardBack() { return idCardBack; }
        public void setIdCardBack(String idCardBack) { this.idCardBack = idCardBack; }
        public String getHandheldPhoto() { return handheldPhoto; }
        public void setHandheldPhoto(String handheldPhoto) { this.handheldPhoto = handheldPhoto; }
    }
}
