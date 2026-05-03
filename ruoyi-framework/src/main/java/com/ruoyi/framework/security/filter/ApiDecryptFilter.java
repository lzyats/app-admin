package com.ruoyi.framework.security.filter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import com.ruoyi.common.constant.Constants;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.http.HttpHelper;
import com.ruoyi.framework.security.crypto.ApiCryptoService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

/**
 * API 请求解密过滤器
 *
 * 仅在请求头命中加密标识且 Content-Type 为 application/json 时生效。
 *
 * @author ruoyi
 */
@Component
public class ApiDecryptFilter extends OncePerRequestFilter
{
    private final ObjectMapper objectMapper;
    private final ApiCryptoService apiCryptoService;

    public ApiDecryptFilter(ObjectMapper objectMapper, ApiCryptoService apiCryptoService)
    {
        this.objectMapper = objectMapper;
        this.apiCryptoService = apiCryptoService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException
    {
        if (!apiCryptoService.shouldDecryptRequest(request))
        {
            filterChain.doFilter(request, response);
            return;
        }

        String contentType = request.getContentType();
        if (!StringUtils.startsWithIgnoreCase(contentType, MediaType.APPLICATION_JSON_VALUE))
        {
            filterChain.doFilter(request, response);
            return;
        }

        String method = request.getMethod();
        if ("GET".equalsIgnoreCase(method) || "HEAD".equalsIgnoreCase(method) || "DELETE".equalsIgnoreCase(method))
        {
            filterChain.doFilter(request, response);
            return;
        }

        long contentLength = request.getContentLengthLong();
        if (contentLength <= 0L)
        {
            filterChain.doFilter(request, response);
            return;
        }

        String body = HttpHelper.getBodyString(request);
        if (StringUtils.isEmpty(body))
        {
            filterChain.doFilter(request, response);
            return;
        }

        try
        {
            JsonNode root = objectMapper.readTree(body);
            JsonNode dataNode = root.get(AjaxResult.DATA_TAG);
            if (dataNode == null || !dataNode.isTextual())
            {
                filterChain.doFilter(request, response);
                return;
            }

            String plainJson = apiCryptoService.decryptText(dataNode.asText());
            CachedBodyRequestWrapper wrapper = new CachedBodyRequestWrapper(request, plainJson.getBytes(StandardCharsets.UTF_8));
            filterChain.doFilter(wrapper, response);
        }
        catch (Exception e)
        {
            writeDecryptError(response);
        }
    }

    private void writeDecryptError(HttpServletResponse response) throws IOException
    {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        response.setCharacterEncoding(Constants.UTF8);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        AjaxResult result = AjaxResult.error(400, "请求解密失败");
        response.getWriter().write(objectMapper.writeValueAsString(result));
    }
}
