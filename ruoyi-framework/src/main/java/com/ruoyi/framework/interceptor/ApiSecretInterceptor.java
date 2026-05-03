package com.ruoyi.framework.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.utils.ServletUtils;

/**
 * API密钥验证拦截器
 *
 * @author ruoyi
 */
@Component
public class ApiSecretInterceptor implements HandlerInterceptor {

    public static final String API_SECRET_HEADER = "X-Api-Secret";
    public static final String API_SECRET_VALUE = "GoApiApp2024SecretKey";

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }
        String uri = request.getRequestURI();
        if (uri != null && uri.startsWith("/app/config/")) {
            return true;
        }
        String apiSecret = request.getHeader(API_SECRET_HEADER);
        if (API_SECRET_VALUE.equals(apiSecret)) {
            return true;
        }
        AjaxResult ajaxResult = AjaxResult.error(500, "无效的API请求");
        ServletUtils.renderString(response, JSON.toJSONString(ajaxResult));
        return false;
    }
}
