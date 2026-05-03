package com.ruoyi.system.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.ruoyi.common.config.CloudStorageConfig;
import com.ruoyi.system.service.ICloudStorageService;
import com.ruoyi.system.service.impl.CloudStorageServiceImpl;

/**
 * 云存储配置
 * 
 * @author ruoyi
 */
@Configuration
public class CloudStorageServiceConfig {
    @Autowired
    private CloudStorageConfig cloudStorageConfig;

    @Bean
    public ICloudStorageService cloudStorageService() {
        return new CloudStorageServiceImpl(cloudStorageConfig);
    }
}