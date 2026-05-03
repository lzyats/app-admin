package com.ruoyi.system.service.impl;

import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.multipart.MultipartFile;
import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception;
import com.ruoyi.common.config.CloudStorageConfig;
import com.ruoyi.system.service.ICloudStorageService;

/**
 * 云存储服务实现
 *
 * @author ruoyi
 */
public class CloudStorageServiceImpl implements ICloudStorageService {
    private static final Logger log = LoggerFactory.getLogger(CloudStorageServiceImpl.class);
    private CloudStorageConfig config;

    public CloudStorageServiceImpl(CloudStorageConfig config) {
        this.config = config;
    }

    @Override
    public Map<String, Object> generatePresignedUrl(String fileName, String fileType) {
        // 根据存储类型获取对应实现
        String storageType = config.getType();
        log.info("CloudStorageConfig type: {}", storageType);
        log.info("CloudStorageConfig s3 endpoint: {}", config.getS3() != null ? config.getS3().getEndpoint() : "null");
        ICloudStorageService service = getService(storageType);
        log.info("Using storage service: {}", service.getClass().getSimpleName());
        return service.generatePresignedUrl(fileName, fileType);
    }

    @Override
    public boolean handleUploadCallback(Map<String, Object> params) {
        // 根据存储类型获取对应实现
        ICloudStorageService service = getService(config.getType());
        return service.handleUploadCallback(params);
    }

    @Override
    public String uploadAvatar(MultipartFile file) throws Exception {
        // 根据存储类型获取对应实现
        ICloudStorageService service = getService(config.getType());
        return service.uploadAvatar(file);
    }

    @Override
    public ICloudStorageService getService(String storageType) {
        switch (storageType) {
            case "oss":
                return new OssCloudStorageService(config);
            case "cos":
                return new CosCloudStorageService(config);
            case "s3":
                return new S3CloudStorageService(config);
            case "local":
            default:
                return new LocalCloudStorageService(config);
        }
    }

    /**
     * 本地存储实现
     */
    private static class LocalCloudStorageService implements ICloudStorageService {
        private CloudStorageConfig config;

        public LocalCloudStorageService(CloudStorageConfig config) {
            this.config = config;
        }

        @Override
        public Map<String, Object> generatePresignedUrl(String fileName, String fileType) {
            // 本地存储不需要预签名，直接返回本地路径
            Map<String, Object> result = new HashMap<>();
            result.put("url", "/common/upload");
            result.put("key", fileName);
            result.put("type", "local");
            return result;
        }

        @Override
        public boolean handleUploadCallback(Map<String, Object> params) {
            // 本地存储不需要回调处理
            return true;
        }

        @Override
        public ICloudStorageService getService(String storageType) {
            return this;
        }

        @Override
        public String uploadAvatar(MultipartFile file) throws Exception {
            // 本地存储不支持头像上传，由 Controller 层处理
            throw new UnsupportedOperationException("Local storage does not support this method, use FileUploadUtils instead");
        }
    }

    /**
     * OSS存储实现
     */
    private static class OssCloudStorageService implements ICloudStorageService {
        private static final Logger log = LoggerFactory.getLogger(OssCloudStorageService.class);
        private CloudStorageConfig config;

        public OssCloudStorageService(CloudStorageConfig config) {
            this.config = config;
        }

        @Override
        public Map<String, Object> generatePresignedUrl(String fileName, String fileType) {
            Map<String, Object> result = new HashMap<>();
            result.put("url", config.getOss().getEndpoint() + "/" + config.getOss().getBucketName());
            result.put("key", fileName);
            result.put("type", "oss");
            result.put("accessKey", config.getOss().getAccessKey());
            result.put("signature", "oss-signature");
            result.put("policy", "oss-policy");
            result.put("expire", System.currentTimeMillis() + 3600000);
            return result;
        }

        @Override
        public boolean handleUploadCallback(Map<String, Object> params) {
            return true;
        }

        @Override
        public ICloudStorageService getService(String storageType) {
            return this;
        }

        @Override
        public String uploadAvatar(MultipartFile file) throws Exception {
            CloudStorageConfig.OssConfig ossConfig = config.getOss();
            if (ossConfig == null) {
                throw new RuntimeException("OSS configuration is null");
            }

            // 构建 OSS 客户端
            OSS ossClient = buildOssClient(ossConfig);

            // 生成唯一文件名
            String originalFilename = file.getOriginalFilename();
            String fileExtension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String key = "avatar/" + UUID.randomUUID().toString().replace("-", "") + fileExtension;

            try {
                // 上传文件到 OSS
                ossClient.putObject(
                        ossConfig.getBucketName(),
                        key,
                        file.getInputStream()
                );

                log.info("Avatar uploaded to OSS: bucket={}, key={}", ossConfig.getBucketName(), key);

                // 返回访问URL
                String domain = ossConfig.getDomain();
                if (domain == null || domain.isEmpty()) {
                    domain = ossConfig.getEndpoint() + "/" + ossConfig.getBucketName();
                }
                return domain + "/" + key;

            } catch (Exception e) {
                log.error("Failed to upload avatar to OSS: {}", e.getMessage(), e);
                throw new RuntimeException("Failed to upload avatar to OSS: " + e.getMessage(), e);
            } finally {
                ossClient.shutdown();
            }
        }

        private OSS buildOssClient(CloudStorageConfig.OssConfig ossConfig) {
            return new OSSClientBuilder().build(
                    ossConfig.getEndpoint(),
                    ossConfig.getAccessKey(),
                    ossConfig.getSecretKey()
            );
        }
    }

    /**
     * COS存储实现
     */
    private static class CosCloudStorageService implements ICloudStorageService {
        private CloudStorageConfig config;

        public CosCloudStorageService(CloudStorageConfig config) {
            this.config = config;
        }

        @Override
        public Map<String, Object> generatePresignedUrl(String fileName, String fileType) {
            Map<String, Object> result = new HashMap<>();
            result.put("url", config.getCos().getEndpoint() + "/" + config.getCos().getBucketName());
            result.put("key", fileName);
            result.put("type", "cos");
            result.put("accessKey", config.getCos().getAccessKey());
            result.put("signature", "cos-signature");
            result.put("policy", "cos-policy");
            result.put("expire", System.currentTimeMillis() + 3600000);
            return result;
        }

        @Override
        public boolean handleUploadCallback(Map<String, Object> params) {
            return true;
        }

        @Override
        public ICloudStorageService getService(String storageType) {
            return this;
        }

        @Override
        public String uploadAvatar(MultipartFile file) throws Exception {
            // TODO: 实现COS上传逻辑
            // 需要引入腾讯云COS SDK
            throw new UnsupportedOperationException("COS upload not implemented, please implement COS SDK integration");
        }
    }

    /**
     * S3存储实现
     */
    private static class S3CloudStorageService implements ICloudStorageService {
        private static final Logger log = LoggerFactory.getLogger(S3CloudStorageService.class);
        private CloudStorageConfig config;

        public S3CloudStorageService(CloudStorageConfig config) {
            this.config = config;
        }

        @Override
        public Map<String, Object> generatePresignedUrl(String fileName, String fileType) {
            Map<String, Object> result = new HashMap<>();
            result.put("url", config.getS3().getEndpoint() + "/" + config.getS3().getBucketName());
            result.put("key", fileName);
            result.put("type", "s3");
            result.put("accessKey", config.getS3().getAccessKey());
            result.put("signature", "s3-signature");
            result.put("policy", "s3-policy");
            result.put("expire", System.currentTimeMillis() + 3600000);
            return result;
        }

        @Override
        public boolean handleUploadCallback(Map<String, Object> params) {
            return true;
        }

        @Override
        public ICloudStorageService getService(String storageType) {
            return this;
        }

        @Override
        public String uploadAvatar(MultipartFile file) throws Exception {
            CloudStorageConfig.S3Config s3Config = config.getS3();
            if (s3Config == null) {
                throw new RuntimeException("S3 configuration is null");
            }

            // 构建 S3 客户端
            S3Client s3Client = buildS3Client(s3Config);

            // 生成唯一文件名
            String originalFilename = file.getOriginalFilename();
            String fileExtension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String key = "avatar/" + UUID.randomUUID().toString().replace("-", "") + fileExtension;

            try {
                // 上传文件到 S3
                PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                        .bucket(s3Config.getBucketName())
                        .key(key)
                        .contentType(file.getContentType())
                        .build();

                s3Client.putObject(putObjectRequest, RequestBody.fromBytes(file.getBytes()));

                log.info("Avatar uploaded to S3: bucket={}, key={}", s3Config.getBucketName(), key);

                // 返回访问URL
                String domain = s3Config.getDomain();
                if (domain == null || domain.isEmpty()) {
                    domain = s3Config.getEndpoint() + "/" + s3Config.getBucketName();
                }
                return domain + "/" + key;

            } catch (S3Exception e) {
                log.error("Failed to upload avatar to S3: {}", e.getMessage(), e);
                throw new RuntimeException("Failed to upload avatar to S3: " + e.getMessage(), e);
            } finally {
                s3Client.close();
            }
        }

        private S3Client buildS3Client(CloudStorageConfig.S3Config s3Config) {
            AwsBasicCredentials credentials = AwsBasicCredentials.create(
                    s3Config.getAccessKey(),
                    s3Config.getSecretKey()
            );

            // 解析region
            Region region = Region.of(s3Config.getRegion());

            return S3Client.builder()
                    .region(region)
                    .endpointOverride(URI.create(s3Config.getEndpoint()))
                    .credentialsProvider(StaticCredentialsProvider.create(credentials))
                    .forcePathStyle(true) // 重要：对于MinIO和其他S3兼容存储必须使用路径样式
                    .build();
        }
    }
}