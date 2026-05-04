package com.ruoyi.common.annotation;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 标记需要 Google 验证码校验的敏感操作方法。
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface GoogleVerifyRequired
{
    /**
     * 从请求中提取验证码的字段名。
     */
    String codeField() default "googleCode";
}
