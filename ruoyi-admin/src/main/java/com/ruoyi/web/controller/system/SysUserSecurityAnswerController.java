package com.ruoyi.web.controller.system;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.constant.UserConstants;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.model.SecurityAnswerBody;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysUserSecurityAnswer;
import com.ruoyi.system.service.ISysUserSecurityAnswerService;
import com.ruoyi.system.service.ISysUserService;
import com.ruoyi.framework.security.crypto.ApiCryptoService;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

/**
 * 用户安全问题答案管理。
 */
@RestController
@RequestMapping("/app/user/security")
public class SysUserSecurityAnswerController extends BaseController
{
    @Autowired
    private ISysUserSecurityAnswerService answerService;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ApiCryptoService apiCryptoService;

    /**
     * 获取当前用户的安全问题答案列表。
     */
    @GetMapping("/answers")
    public AjaxResult getMyAnswers()
    {
        Long userId = SecurityUtils.getUserId();
        List<SysUserSecurityAnswer> list = answerService.selectAnswerByUserId(userId);
        return success(list);
    }

    /**
     * 获取指定用户的安全问题答案列表。
     */
    @GetMapping("/answers/{userId}")
    public AjaxResult getUserAnswers(@PathVariable Long userId)
    {
        Long currentUserId = SecurityUtils.getUserId();
        if (!SecurityUtils.isAdmin() && !userId.equals(currentUserId))
        {
            return AjaxResult.error("无权查看该用户的安全问题");
        }
        List<SysUserSecurityAnswer> list = answerService.selectAnswerByUserId(userId);
        return success(list);
    }

    /**
     * 设置用户安全问题答案。
     *
     * 兼容两种请求体：
     * 1. 直接数组 [ {...}, {...} ]
     * 2. 包一层对象 { "answers": [ {...}, {...} ] }
     */
    @Log(title = "安全问题设置", businessType = BusinessType.INSERT)
    @PostMapping("/answers")
    public AjaxResult setAnswers(@RequestBody(required = false) Object body)
    {
        Long userId = SecurityUtils.getUserId();
        List<SysUserSecurityAnswer> answers = parseAnswersBody(body);
        if (answers.isEmpty())
        {
            return AjaxResult.error("安全问题数据不能为空");
        }
        int rows = answerService.setUserSecurityAnswers(userId, answers);
        if (rows > 0)
        {
            userService.updateUserSecurityQuestionSet(userId, 1);
        }
        return toAjax(rows);
    }

    /**
     * 校验用户安全问题答案是否正确。
     */
    @PostMapping("/verify")
    public AjaxResult verifyAnswers(@RequestBody SysUserSecurityAnswer answer)
    {
        Long userId = SecurityUtils.getUserId();
        boolean isCorrect = answerService.verifyAnswer(userId, answer.getQuestionId(), answer.getAnswer());
        if (isCorrect)
        {
            return success(true);
        }
        return error("答案验证失败");
    }

    /**
     * 获取用户已设置的问题数量。
     */
    @GetMapping("/count")
    public AjaxResult getAnswerCount()
    {
        Long userId = SecurityUtils.getUserId();
        int count = answerService.selectAnswerCountByUserId(userId);
        return success(count);
    }

    /**
     * 通过安全问题更新登录密码。
     */
    @PostMapping("/updatePwd")
    public AjaxResult updatePasswordBySecurity(@RequestBody UpdatePwdBySecurityBody body)
    {
        String newPassword = StringUtils.trim(body.getNewPassword());
        List<SecurityAnswerBody> answers = body.getAnswers();

        if (StringUtils.isEmpty(newPassword))
        {
            return AjaxResult.error("新密码不能为空");
        }
        if (newPassword.length() < UserConstants.PASSWORD_MIN_LENGTH
                || newPassword.length() > UserConstants.PASSWORD_MAX_LENGTH)
        {
            return AjaxResult.error("密码长度必须在6到20个字符之间");
        }
        if (answers == null || answers.size() < 2)
        {
            return AjaxResult.error("请至少回答2个安全问题");
        }

        Long userId = SecurityUtils.getUserId();
        SysUser user = userService.selectUserById(userId);
        if (user == null)
        {
            return AjaxResult.error("用户不存在");
        }

        for (SecurityAnswerBody answer : answers)
        {
            if (answer.getQuestionId() == null || StringUtils.isEmpty(answer.getAnswer()))
            {
                return AjaxResult.error("安全问题或答案不能为空");
            }
            if (!answerService.verifyAnswer(userId, answer.getQuestionId(), answer.getAnswer()))
            {
                return AjaxResult.error("安全问题答案验证失败");
            }
        }

        String encryptedPwd = SecurityUtils.encryptPassword(newPassword);
        int rows = userService.resetUserPwd(userId, encryptedPwd);
        if (rows <= 0)
        {
            return AjaxResult.error("更新密码失败，请稍后重试");
        }
        return AjaxResult.success("密码更新成功");
    }

    /**
     * 通过安全问题更新支付密码。
     */
    @PostMapping("/updatePayPwd")
    public AjaxResult updatePayPasswordBySecurity(@RequestBody UpdatePwdBySecurityBody body)
    {
        String newPassword = StringUtils.trim(body.getNewPassword());
        List<SecurityAnswerBody> answers = body.getAnswers();

        if (StringUtils.isEmpty(newPassword))
        {
            return AjaxResult.error("新支付密码不能为空");
        }
        if (newPassword.length() != 6)
        {
            return AjaxResult.error("支付密码必须为6位数字");
        }
        if (!newPassword.matches("\\d+"))
        {
            return AjaxResult.error("支付密码必须为数字");
        }
        if (answers == null || answers.size() < 2)
        {
            return AjaxResult.error("请至少回答2个安全问题");
        }

        Long userId = SecurityUtils.getUserId();
        SysUser user = userService.selectUserById(userId);
        if (user == null)
        {
            return AjaxResult.error("用户不存在");
        }

        for (SecurityAnswerBody answer : answers)
        {
            if (answer.getQuestionId() == null || StringUtils.isEmpty(answer.getAnswer()))
            {
                return AjaxResult.error("安全问题或答案不能为空");
            }
            if (!answerService.verifyAnswer(userId, answer.getQuestionId(), answer.getAnswer()))
            {
                return AjaxResult.error("安全问题答案验证失败");
            }
        }

        String encryptedPayPwd = SecurityUtils.encryptPassword(newPassword);
        int rows = userService.updateUserPayPwd(userId, encryptedPayPwd);
        if (rows <= 0)
        {
            return AjaxResult.error("更新支付密码失败，请稍后重试");
        }
        return AjaxResult.success("支付密码更新成功");
    }

    public static class UpdatePwdBySecurityBody
    {
        private String newPassword;
        private List<SecurityAnswerBody> answers;

        public String getNewPassword()
        {
            return newPassword;
        }

        public void setNewPassword(String newPassword)
        {
            this.newPassword = newPassword;
        }

        public List<SecurityAnswerBody> getAnswers()
        {
            return answers;
        }

        public void setAnswers(List<SecurityAnswerBody> answers)
        {
            this.answers = answers;
        }
    }

    private List<SysUserSecurityAnswer> parseAnswersBody(Object body)
    {
        if (body == null)
        {
            return List.of();
        }
        if (body instanceof List<?> list)
        {
            return convertAnswerList(list);
        }
        if (body instanceof Map<?, ?> map)
        {
            Object answersNode = map.get("answers");
            if (answersNode instanceof List<?> list)
            {
                return convertAnswerList(list);
            }
            if (answersNode instanceof Map<?, ?> singleMap)
            {
                return convertAnswerList(List.of(singleMap));
            }
            Object dataNode = map.get("data");
            if (dataNode instanceof String cipherText && StringUtils.isNotBlank(cipherText))
            {
                try
                {
                    String plainJson = apiCryptoService.decryptText(cipherText);
                    if (StringUtils.isBlank(plainJson))
                    {
                        return List.of();
                    }
                    if (plainJson.trim().startsWith("["))
                    {
                        List<SysUserSecurityAnswer> answers = objectMapper.readValue(
                                plainJson, new TypeReference<List<SysUserSecurityAnswer>>() {});
                        return answers == null ? List.of() : answers;
                    }
                    if (plainJson.trim().startsWith("{"))
                    {
                        Map<String, Object> plainMap = objectMapper.readValue(
                                plainJson, new TypeReference<Map<String, Object>>() {});
                        Object plainAnswersNode = plainMap.get("answers");
                        if (plainAnswersNode instanceof List<?> plainList)
                        {
                            return convertAnswerList(plainList);
                        }
                        if (plainAnswersNode instanceof Map<?, ?> plainSingleMap)
                        {
                            return convertAnswerList(List.of(plainSingleMap));
                        }
                    }
                }
                catch (Exception ignored)
                {
                    return List.of();
                }
            }
        }
        return List.of();
    }

    private List<SysUserSecurityAnswer> convertAnswerList(List<?> source)
    {
        List<SysUserSecurityAnswer> answers = new ArrayList<>();
        for (Object item : source)
        {
            if (item == null)
            {
                continue;
            }
            if (item instanceof SysUserSecurityAnswer securityAnswer)
            {
                answers.add(securityAnswer);
                continue;
            }
            if (item instanceof Map<?, ?> map)
            {
                answers.add(objectMapper.convertValue(new LinkedHashMap<>(map), SysUserSecurityAnswer.class));
                continue;
            }
            answers.add(objectMapper.convertValue(item, SysUserSecurityAnswer.class));
        }
        return answers;
    }
}
