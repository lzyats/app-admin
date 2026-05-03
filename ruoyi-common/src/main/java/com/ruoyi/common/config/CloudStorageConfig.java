package com.ruoyi.common.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * 云存储配置
 * 
 * @author ruoyi
 */
@Component
@ConfigurationProperties(prefix = "cloud.storage")
public class CloudStorageConfig {
    /**
     * 存储类型：local, oss, cos, s3
     */
    private String type;

    /**
     * OSS配置
     */
    private OssConfig oss;

    /**
     * COS配置
     */
    private CosConfig cos;

    /**
     * S3配置
     */
    private S3Config s3;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public OssConfig getOss() {
        return oss;
    }

    public void setOss(OssConfig oss) {
        this.oss = oss;
    }

    public CosConfig getCos() {
        return cos;
    }

    public void setCos(CosConfig cos) {
        this.cos = cos;
    }

    public S3Config getS3() {
        return s3;
    }

    public void setS3(S3Config s3) {
        this.s3 = s3;
    }

    /**
     * OSS配置
     */
    public static class OssConfig {
        private String endpoint;
        private String accessKey;
        private String secretKey;
        private String bucketName;
        private String domain;

        public String getEndpoint() {
            return endpoint;
        }

        public void setEndpoint(String endpoint) {
            this.endpoint = endpoint;
        }

        public String getAccessKey() {
            return accessKey;
        }

        public void setAccessKey(String accessKey) {
            this.accessKey = accessKey;
        }

        public String getSecretKey() {
            return secretKey;
        }

        public void setSecretKey(String secretKey) {
            this.secretKey = secretKey;
        }

        public String getBucketName() {
            return bucketName;
        }

        public void setBucketName(String bucketName) {
            this.bucketName = bucketName;
        }

        public String getDomain() {
            return domain;
        }

        public void setDomain(String domain) {
            this.domain = domain;
        }
    }

    /**
     * S3配置
     */
    public static class S3Config {
        private String endpoint;
        private String accessKey;
        private String secretKey;
        private String bucketName;
        private String region;
        private String domain;

        public String getEndpoint() {
            return endpoint;
        }

        public void setEndpoint(String endpoint) {
            this.endpoint = endpoint;
        }

        public String getAccessKey() {
            return accessKey;
        }

        public void setAccessKey(String accessKey) {
            this.accessKey = accessKey;
        }

        public String getSecretKey() {
            return secretKey;
        }

        public void setSecretKey(String secretKey) {
            this.secretKey = secretKey;
        }

        public String getBucketName() {
            return bucketName;
        }

        public void setBucketName(String bucketName) {
            this.bucketName = bucketName;
        }

        public String getRegion() {
            return region;
        }

        public void setRegion(String region) {
            this.region = region;
        }

        public String getDomain() {
            return domain;
        }

        public void setDomain(String domain) {
            this.domain = domain;
        }
    }

    /**
     * COS配置
     */
    public static class CosConfig {
        private String endpoint;
        private String accessKey;
        private String secretKey;
        private String bucketName;
        private String region;
        private String domain;
        private String appId;

        public String getEndpoint() {
            return endpoint;
        }

        public void setEndpoint(String endpoint) {
            this.endpoint = endpoint;
        }

        public String getAccessKey() {
            return accessKey;
        }

        public void setAccessKey(String accessKey) {
            this.accessKey = accessKey;
        }

        public String getSecretKey() {
            return secretKey;
        }

        public void setSecretKey(String secretKey) {
            this.secretKey = secretKey;
        }

        public String getBucketName() {
            return bucketName;
        }

        public void setBucketName(String bucketName) {
            this.bucketName = bucketName;
        }

        public String getRegion() {
            return region;
        }

        public void setRegion(String region) {
            this.region = region;
        }

        public String getDomain() {
            return domain;
        }

        public void setDomain(String domain) {
            this.domain = domain;
        }

        public String getAppId() {
            return appId;
        }

        public void setAppId(String appId) {
            this.appId = appId;
        }
    }
}