package com.ruoyi.framework.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import tools.jackson.databind.ObjectMapper;

/**
 * Jackson 基础配置。
 *
 * 兼容 API 加解密过滤器和响应加密切面直接注入 ObjectMapper。
 */
@Configuration
public class JacksonConfig
{
    @Bean
    public ObjectMapper objectMapper()
    {
        return new ObjectMapper();
    }
}
