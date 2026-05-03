package com.ruoyi.web.controller.common;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import com.ruoyi.common.config.CloudStorageConfig;
import com.ruoyi.common.config.RuoYiConfig;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.file.FileUploadUtils;
import com.ruoyi.common.utils.file.FileUtils;
import com.ruoyi.framework.config.ServerConfig;
import com.ruoyi.system.service.ICloudStorageService;

/**
 * 閫氱敤璇锋眰澶勭悊
 * 
 * @author ruoyi
 */
@RestController
@RequestMapping("/common")
public class CommonController
{
    private static final Logger log = LoggerFactory.getLogger(CommonController.class);

    @Autowired
    private ServerConfig serverConfig;

    @Autowired
    private CloudStorageConfig cloudStorageConfig;

    @Autowired
    private ICloudStorageService cloudStorageService;

    private static final String FILE_DELIMITER = ",";

    /**
     * 閫氱敤涓嬭浇璇锋眰
     * 
     * @param fileName 鏂囦欢鍚嶇О
     * @param delete 鏄惁鍒犻櫎
     */
    @GetMapping("/download")
    public void fileDownload(String fileName, Boolean delete, HttpServletResponse response, HttpServletRequest request)
    {
        try
        {
            if (!FileUtils.checkAllowDownload(fileName))
            {
                throw new Exception(StringUtils.format("鏂囦欢鍚嶇О({})闈炴硶锛屼笉鍏佽涓嬭浇銆?", fileName));
            }
            String realFileName = System.currentTimeMillis() + fileName.substring(fileName.indexOf("_") + 1);
            String filePath = RuoYiConfig.getDownloadPath() + fileName;

            response.setContentType(MediaType.APPLICATION_OCTET_STREAM_VALUE);
            FileUtils.setAttachmentResponseHeader(response, realFileName);
            FileUtils.writeBytes(filePath, response.getOutputStream());
            if (delete)
            {
                FileUtils.deleteFile(filePath);
            }
        }
        catch (Exception e)
        {
            log.error("涓嬭浇鏂囦欢澶辫触", e);
        }
    }

    /**
     * 閫氱敤涓婁紶璇锋眰锛堝崟涓級
     */
    @PostMapping("/upload")
    public AjaxResult uploadFile(MultipartFile file) throws Exception
    {
        try
        {
            String storageType = cloudStorageConfig.getType();
            if (StringUtils.isNotBlank(storageType) && !"local".equalsIgnoreCase(storageType))
            {
                String url = cloudStorageService.uploadAvatar(file);
                AjaxResult ajax = AjaxResult.success();
                ajax.put("url", url);
                ajax.put("fileName", url);
                ajax.put("newFileName", FileUtils.getName(url));
                ajax.put("originalFilename", file.getOriginalFilename());
                return ajax;
            }

            String filePath = RuoYiConfig.getUploadPath();
            String fileName = FileUploadUtils.upload(filePath, file);
            String url = serverConfig.getUrl() + fileName;
            AjaxResult ajax = AjaxResult.success();
            ajax.put("url", url);
            ajax.put("fileName", fileName);
            ajax.put("newFileName", FileUtils.getName(fileName));
            ajax.put("originalFilename", file.getOriginalFilename());
            return ajax;
        }
        catch (Exception e)
        {
            return AjaxResult.error(e.getMessage());
        }
    }

    /**
     * 闃叉璇锋眰涓婁紶澶辫触
     */
    @PostMapping("/uploads")
    public AjaxResult uploadFiles(List<MultipartFile> files) throws Exception
    {
        try
        {
            String storageType = cloudStorageConfig.getType();
            List<String> urls = new ArrayList<String>();
            List<String> fileNames = new ArrayList<String>();
            List<String> newFileNames = new ArrayList<String>();
            List<String> originalFilenames = new ArrayList<String>();
            for (MultipartFile file : files)
            {
                String fileName;
                String url;
                if (StringUtils.isNotBlank(storageType) && !"local".equalsIgnoreCase(storageType))
                {
                    url = cloudStorageService.uploadAvatar(file);
                    fileName = url;
                }
                else
                {
                    String filePath = RuoYiConfig.getUploadPath();
                    fileName = FileUploadUtils.upload(filePath, file);
                    url = serverConfig.getUrl() + fileName;
                }
                urls.add(url);
                fileNames.add(fileName);
                newFileNames.add(FileUtils.getName(fileName));
                originalFilenames.add(file.getOriginalFilename());
            }
            AjaxResult ajax = AjaxResult.success();
            ajax.put("urls", StringUtils.join(urls, FILE_DELIMITER));
            ajax.put("fileNames", StringUtils.join(fileNames, FILE_DELIMITER));
            ajax.put("newFileNames", StringUtils.join(newFileNames, FILE_DELIMITER));
            ajax.put("originalFilenames", StringUtils.join(originalFilenames, FILE_DELIMITER));
            return ajax;
        }
        catch (Exception e)
        {
            return AjaxResult.error(e.getMessage());
        }
    }

    /**
     * 鏈湴璧勬簮閫氱敤涓嬭浇
     */
    @GetMapping("/download/resource")
    public void resourceDownload(String resource, HttpServletRequest request, HttpServletResponse response)
            throws Exception
    {
        try
        {
            if (!FileUtils.checkAllowDownload(resource))
            {
                throw new Exception(StringUtils.format("璧勬簮鏂囦欢({})闈炴硶锛屼笉鍏佽涓嬭浇銆?", resource));
            }
            // 鏈湴璧勬簮璺緞
            String localPath = RuoYiConfig.getProfile();
            // 鏁版嵁搴撹祫婧愬湴鍧€
            String downloadPath = localPath + FileUtils.stripPrefix(resource);
            // 涓嬭浇鍚嶇О
            String downloadName = StringUtils.substringAfterLast(downloadPath, "/");
            response.setContentType(MediaType.APPLICATION_OCTET_STREAM_VALUE);
            FileUtils.setAttachmentResponseHeader(response, downloadName);
            FileUtils.writeBytes(downloadPath, response.getOutputStream());
        }
        catch (Exception e)
        {
            log.error("涓嬭浇鏂囦欢澶辫触", e);
        }
    }

    /**
     * 棰勭鍚嶄笂浼?
     */
    @PostMapping("/upload/presigned")
    public AjaxResult presignedUpload(@RequestBody Map<String, String> params)
    {
        try
        {
            String fileName = params.get("fileName");
            String fileType = params.get("fileType");
            if (StringUtils.isBlank(fileName))
            {
                return AjaxResult.error("鏂囦欢鍚嶄笉鑳戒负绌?");
            }
            // 鑾峰彇瀛樺偍绫诲瀷瀵瑰簲鐨勬湇鍔?
            ICloudStorageService service = cloudStorageService.getService(cloudStorageConfig.getType());
            // 鐢熸垚棰勭鍚峌RL
            Map<String, Object> result = service.generatePresignedUrl(fileName, fileType);
            return AjaxResult.success(result);
        }
        catch (Exception e)
        {
            log.error("鐢熸垚棰勭鍚峌RL澶辫触", e);
            return AjaxResult.error(e.getMessage());
        }
    }

    /**
     * 涓婁紶鍥炶皟
     */
    @PostMapping("/upload/callback")
    public AjaxResult uploadCallback(@RequestBody Map<String, Object> params)
    {
        try
        {
            // 鑾峰彇瀛樺偍绫诲瀷瀵瑰簲鐨勬湇鍔?
            ICloudStorageService service = cloudStorageService.getService(cloudStorageConfig.getType());
            // 澶勭悊涓婁紶鍥炶皟
            boolean success = service.handleUploadCallback(params);
            if (success)
            {
                return AjaxResult.success("鍥炶皟澶勭悊鎴愬姛");
            }
            else
            {
                return AjaxResult.error("鍥炶皟澶勭悊澶辫触");
            }
        }
        catch (Exception e)
        {
            log.error("澶勭悊涓婁紶鍥炶皟澶辫触", e);
            return AjaxResult.error(e.getMessage());
        }
    }
}

