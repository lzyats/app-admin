package com.ruoyi.system.service;

import java.util.Map;
import org.springframework.web.multipart.MultipartFile;

/**
 * 云存储服务接口
 *
 * @author ruoyi
 */
public interface ICloudStorageService {
    /**
     * 生成预签名上传URL
     *
     * @param fileName 文件名
     * @param fileType 文件类型
     * @return 预签名信息，包含url、key等
     */
    Map<String, Object> generatePresignedUrl(String fileName, String fileType);

    /**
     * 处理上传回调
     *
     * @param params 回调参数
     * @return 处理结果
     */
    boolean handleUploadCallback(Map<String, Object> params);

    /**
     * 根据存储类型获取对应实现
     *
     * @param storageType 存储类型
     * @return 云存储服务实现
     */
    ICloudStorageService getService(String storageType);

    /**
     * 上传头像文件
     *
     * @param file 头像文件
     * @return 头像URL
     */
    String uploadAvatar(MultipartFile file) throws Exception;
}