package com.ruoyi.framework.aspectj;

import java.lang.reflect.Field;
import java.util.Map;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.ruoyi.common.annotation.GoogleVerifyRequired;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.ServletUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.service.ISysGoogleAuthService;

/**
 * Google 验证码敏感操作校验切面
 */
@Aspect
@Component
public class GoogleVerifyAspect
{
    @Autowired
    private ISysGoogleAuthService googleAuthService;

    @Before("@annotation(googleVerifyRequired)")
    public void doBefore(JoinPoint joinPoint, GoogleVerifyRequired googleVerifyRequired)
    {
        String field = googleVerifyRequired.codeField();
        String code = extractCode(joinPoint.getArgs(), field);
        if (StringUtils.isBlank(code))
        {
            code = ServletUtils.getParameter(field);
        }
        googleAuthService.validateOperation(SecurityUtils.getUserId(), code);
    }

    private String extractCode(Object[] args, String field)
    {
        if (args == null || args.length == 0)
        {
            return null;
        }
        for (Object arg : args)
        {
            if (arg == null)
            {
                continue;
            }
            if (arg instanceof Map)
            {
                Object val = ((Map<?, ?>) arg).get(field);
                if (val != null && StringUtils.isNotBlank(String.valueOf(val)))
                {
                    return String.valueOf(val).trim();
                }
                continue;
            }
            String val = extractFromBean(arg, field);
            if (StringUtils.isNotBlank(val))
            {
                return val.trim();
            }
        }
        return null;
    }

    private String extractFromBean(Object bean, String fieldName)
    {
        Class<?> clazz = bean.getClass();
        while (clazz != null && clazz != Object.class)
        {
            try
            {
                Field field = clazz.getDeclaredField(fieldName);
                field.setAccessible(true);
                Object value = field.get(bean);
                return value == null ? null : String.valueOf(value);
            }
            catch (NoSuchFieldException e)
            {
                clazz = clazz.getSuperclass();
            }
            catch (Exception e)
            {
                return null;
            }
        }
        return null;
    }
}
