package com.ruoyi.web.controller.system;

import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.config.CloudStorageConfig;
import com.ruoyi.common.config.RuoYiConfig;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.model.LoginUser;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.file.FileUtils;
import com.ruoyi.common.utils.file.MimeTypeUtils;
import com.ruoyi.framework.security.crypto.ApiCryptoService;
import com.ruoyi.framework.web.service.TokenService;
import com.ruoyi.system.service.ICloudStorageService;
import com.ruoyi.system.service.ISysUserService;
import tools.jackson.databind.ObjectMapper;

/**
 * Personal profile management.
 */
@RestController
@RequestMapping("/system/user/profile")
public class SysProfileController extends BaseController
{
    private static final Logger log = LoggerFactory.getLogger(SysProfileController.class);

    @Autowired
    private ISysUserService userService;

    @Autowired
    private TokenService tokenService;

    @Autowired
    private CloudStorageConfig cloudStorageConfig;

    @Autowired
    private ICloudStorageService cloudStorageService;

    @Autowired
    private ApiCryptoService apiCryptoService;

    @Autowired
    private ObjectMapper objectMapper;

    @GetMapping
    public AjaxResult profile()
    {
        LoginUser loginUser = getLoginUser();
        SysUser user = loginUser.getUser();
        AjaxResult ajax = AjaxResult.success(user);
        ajax.put("roleGroup", userService.selectUserRoleGroup(loginUser.getUsername()));
        ajax.put("postGroup", userService.selectUserPostGroup(loginUser.getUsername()));
        return ajax;
    }

    @Log(title = "个人信息", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult updateProfile(@RequestBody(required = false) Map<String, Object> bodyMap)
    {
        LoginUser loginUser = getLoginUser();
        SysUser currentUser = loginUser.getUser();
        SysUser user = resolveProfileBody(bodyMap);
        String originalPhone = currentUser.getPhonenumber();
        String originalEmail = currentUser.getEmail();

        if (StringUtils.isNotEmpty(user.getNickName())) {
            currentUser.setNickName(user.getNickName());
        }
        if (StringUtils.isNotEmpty(user.getEmail())) {
            currentUser.setEmail(user.getEmail());
        }
        if (StringUtils.isNotEmpty(user.getPhonenumber())) {
            currentUser.setPhonenumber(user.getPhonenumber());
        }
        if (user.getSex() != null) {
            currentUser.setSex(user.getSex());
        }
        if (user.getBirthday() != null) {
            currentUser.setBirthday(user.getBirthday());
        }
        if (StringUtils.isNotEmpty(user.getAvatar())) {
            currentUser.setAvatar(user.getAvatar());
        }
        if (StringUtils.isNotEmpty(user.getRemark())) {
            currentUser.setRemark(user.getRemark());
        }

        if (StringUtils.isNotEmpty(user.getPhonenumber())
                && !StringUtils.equals(user.getPhonenumber(), originalPhone)
                && !userService.checkPhoneUnique(currentUser))
        {
            return error("修改用户" + loginUser.getUsername() + "失败，手机号码已存在");
        }
        if (StringUtils.isNotEmpty(user.getEmail())
                && !StringUtils.equals(user.getEmail(), originalEmail)
                && !userService.checkEmailUnique(currentUser))
        {
            return error("The email address is already in use.");
        }

        if (userService.updateUserProfile(currentUser) > 0)
        {
            syncLoginUserCache(loginUser, currentUser);
            return success();
        }
        return error("Failed to update profile.");
    }

    @Log(title = "个人信息", businessType = BusinessType.UPDATE)
    @PutMapping("/updatePwd")
    public AjaxResult updatePwd(@RequestBody Map<String, String> params)
    {
        String oldPassword = params.get("oldPassword");
        String newPassword = params.get("newPassword");
        LoginUser loginUser = getLoginUser();
        Long userId = loginUser.getUserId();
        SysUser user = userService.selectUserById(userId);
        String password = user.getPassword();
        if (!SecurityUtils.matchesPassword(oldPassword, password))
        {
            return error("修改密码失败，旧密码错误");
        }
        if (SecurityUtils.matchesPassword(newPassword, password))
        {
            return error("New password must be different from the old password.");
        }
        newPassword = SecurityUtils.encryptPassword(newPassword);
        if (userService.resetUserPwd(userId, newPassword) > 0)
        {
            loginUser.getUser().setPwdUpdateDate(DateUtils.getNowDate());
            loginUser.getUser().setPassword(newPassword);
            tokenService.setLoginUser(loginUser);
            return success();
        }
        return error("Password update failed.");
    }

    @Log(title = "用户头像", businessType = BusinessType.UPDATE)
    @PostMapping("/avatar")
    public AjaxResult avatar(@RequestParam("avatarfile") MultipartFile file) throws Exception
    {
        if (!file.isEmpty())
        {
            LoginUser loginUser = getLoginUser();
            String oldAvatar = loginUser.getUser().getAvatar();
            String avatar = uploadAvatar(file);

            if (StringUtils.isNotEmpty(avatar) && userService.updateUserAvatar(loginUser.getUserId(), avatar))
            {
                if (StringUtils.isNotEmpty(oldAvatar) && !oldAvatar.startsWith("http"))
                {
                    FileUtils.deleteFile(RuoYiConfig.getProfile() + FileUtils.stripPrefix(oldAvatar));
                }
                AjaxResult ajax = AjaxResult.success();
                ajax.put("imgUrl", avatar);
                ajax.put("avatar", avatar);
                loginUser.getUser().setAvatar(avatar);
                syncLoginUserCache(loginUser, loginUser.getUser());
                return ajax;
            }
        }
        return error("Avatar upload failed.");
    }

    private SysUser resolveProfileBody(Map<String, Object> bodyMap)
    {
        if (bodyMap == null || bodyMap.isEmpty())
        {
            return new SysUser();
        }

        Object encryptedData = bodyMap.get("data");
        if (encryptedData instanceof String encryptedText && StringUtils.isNotBlank(encryptedText))
        {
            try
            {
                String plainJson = apiCryptoService.decryptText(encryptedText);
                return objectMapper.readValue(plainJson, SysUser.class);
            }
            catch (Exception e)
            {
                throw new RuntimeException("个人资料请求解密失败", e);
            }
        }

        return objectMapper.convertValue(bodyMap, SysUser.class);
    }

    private void syncLoginUserCache(LoginUser loginUser, SysUser latestUser)
    {
        if (loginUser == null)
        {
            return;
        }
        if (latestUser != null)
        {
            loginUser.setUserId(latestUser.getUserId());
            loginUser.setDeptId(latestUser.getDeptId());
            loginUser.setUser(latestUser);
        }
        tokenService.setLoginUser(loginUser);
    }

    private String uploadAvatar(MultipartFile file) throws Exception
    {
        String storageType = cloudStorageConfig.getType();
        log.info("Avatar upload storage type: {}", storageType);

        if ("local".equals(storageType) || StringUtils.isBlank(storageType))
        {
            return com.ruoyi.common.utils.file.FileUploadUtils.upload(
                RuoYiConfig.getAvatarPath(), file, MimeTypeUtils.IMAGE_EXTENSION, true);
        }
        return cloudStorageService.uploadAvatar(file);
    }
}
