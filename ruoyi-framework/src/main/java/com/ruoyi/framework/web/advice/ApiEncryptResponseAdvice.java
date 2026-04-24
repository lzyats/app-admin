package com.ruoyi.framework.web.advice;

import org.springframework.core.MethodParameter;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.http.server.ServletServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.security.crypto.ApiCryptoService;
import jakarta.servlet.http.HttpServletRequest;

/**
 * API 响应加密处理
 *
 * 仅对 AjaxResult 的 data 字段进行加密，code/msg 保持明文。
 *
 * @author ruoyi
 */
@Component
@ControllerAdvice
public class ApiEncryptResponseAdvice implements ResponseBodyAdvice<Object>
{
    private final ApiCryptoService apiCryptoService;

    public ApiEncryptResponseAdvice(ApiCryptoService apiCryptoService)
    {
        this.apiCryptoService = apiCryptoService;
    }

    @Override
    public boolean supports(MethodParameter returnType, Class<? extends HttpMessageConverter<?>> converterType)
    {
        return true;
    }

    @Override
    public Object beforeBodyWrite(Object body, MethodParameter returnType, MediaType selectedContentType,
            Class<? extends HttpMessageConverter<?>> selectedConverterType, ServerHttpRequest request, ServerHttpResponse response)
    {
        if (!(request instanceof ServletServerHttpRequest servletRequest))
        {
            return body;
        }
        HttpServletRequest rawRequest = servletRequest.getServletRequest();
        if (!apiCryptoService.shouldEncryptResponse(rawRequest))
        {
            return body;
        }
        if (!(body instanceof AjaxResult ajaxResult))
        {
            return body;
        }

        Object data = ajaxResult.get(AjaxResult.DATA_TAG);
        if (data == null)
        {
            return body;
        }

        String encryptedText = apiCryptoService.encryptAny(data);
        if (StringUtils.isNotEmpty(encryptedText))
        {
            ajaxResult.put(AjaxResult.DATA_TAG, encryptedText);
            response.getHeaders().set(apiCryptoService.getEncryptHeader(), apiCryptoService.getEncryptHeaderValue());
        }
        return ajaxResult;
    }
}
