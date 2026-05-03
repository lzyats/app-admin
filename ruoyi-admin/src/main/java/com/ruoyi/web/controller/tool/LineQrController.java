package com.ruoyi.web.controller.tool;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.util.Base64;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.Map;
import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import javax.imageio.ImageIO;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.util.FastByteArrayOutputStream;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.alibaba.fastjson2.JSON;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.utils.StringUtils;

/**
 * 线路二维码工具
 *
 * 说明：
 * 1. 先将线路 JSON 使用 AES/CBC/PKCS5Padding 加密为 Base64 密文；
 * 2. 再将密文生成二维码，供 Flutter 扫码后解密导入。
 */
@RestController
@RequestMapping("/tool/line/qr")
public class LineQrController
{
    private static final String AES_TRANSFORMATION = "AES/CBC/PKCS5Padding";

    @Value("${line-qr.security.seed:}")
    private String seed;

    /**
     * 生成线路加密二维码
     */
    @PostMapping("/generate")
    public AjaxResult generate(@RequestBody LineQrGenerateRequest request)
    {
        if (request == null)
        {
            return AjaxResult.error("请求参数不能为空");
        }
        if (StringUtils.isEmpty(seed))
        {
            return AjaxResult.error("line-qr.security.seed 未配置");
        }
        if (StringUtils.isEmpty(request.getName()) || StringUtils.isEmpty(request.getHttpUrl()) || StringUtils.isEmpty(request.getWsUrl()))
        {
            return AjaxResult.error("name/httpUrl/wsUrl 不能为空");
        }

        try
        {
            Map<String, String> payload = new HashMap<String, String>();
            payload.put("name", request.getName().trim());
            payload.put("httpUrl", request.getHttpUrl().trim());
            payload.put("wsUrl", request.getWsUrl().trim());

            String plainJson = JSON.toJSONString(payload);
            String encryptedText = encryptWithSeed(plainJson, seed);
            String qrBase64 = generateQrBase64(encryptedText, request.getSize());

            Map<String, Object> data = new HashMap<String, Object>();
            data.put("encryptedText", encryptedText);
            data.put("qrImageBase64", qrBase64);
            data.put("contentType", "image/png");
            data.put("payload", payload);
            return AjaxResult.success(data);
        }
        catch (IllegalArgumentException e)
        {
            return AjaxResult.error(e.getMessage());
        }
        catch (Exception e)
        {
            return AjaxResult.error("生成二维码失败");
        }
    }

    private String encryptWithSeed(String plainText, String cryptoSeed)
    {
        try
        {
            byte[] keyBytes = sha256Bytes(cryptoSeed);
            byte[] ivBytes = md5Bytes(cryptoSeed);
            Cipher cipher = Cipher.getInstance(AES_TRANSFORMATION);
            SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
            IvParameterSpec ivSpec = new IvParameterSpec(ivBytes);
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec);
            byte[] encrypted = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(encrypted);
        }
        catch (GeneralSecurityException e)
        {
            throw new IllegalArgumentException("线路二维码加密失败", e);
        }
    }

    private byte[] sha256Bytes(String text) throws GeneralSecurityException
    {
        MessageDigest sha256 = MessageDigest.getInstance("SHA-256");
        return sha256.digest(text.getBytes(StandardCharsets.UTF_8));
    }

    private byte[] md5Bytes(String text) throws GeneralSecurityException
    {
        MessageDigest md5 = MessageDigest.getInstance("MD5");
        return md5.digest(text.getBytes(StandardCharsets.UTF_8));
    }

    private String generateQrBase64(String content, Integer size) throws WriterException, IOException
    {
        int qrSize = (size == null || size < 200 || size > 1200) ? 360 : size;

        Map<EncodeHintType, Object> hints = new EnumMap<EncodeHintType, Object>(EncodeHintType.class);
        hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
        hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.M);
        hints.put(EncodeHintType.MARGIN, 1);

        BitMatrix bitMatrix = new MultiFormatWriter().encode(content, BarcodeFormat.QR_CODE, qrSize, qrSize, hints);
        BufferedImage image = MatrixToImageWriter.toBufferedImage(bitMatrix);

        FastByteArrayOutputStream os = new FastByteArrayOutputStream();
        ImageIO.write(image, "png", os);
        return Base64.getEncoder().encodeToString(os.toByteArray());
    }

    public static class LineQrGenerateRequest
    {
        /** 线路名称 */
        private String name;

        /** HTTP 地址 */
        private String httpUrl;

        /** WebSocket 地址 */
        private String wsUrl;

        /** 二维码尺寸（可选，默认 360） */
        private Integer size;

        public String getName()
        {
            return name;
        }

        public void setName(String name)
        {
            this.name = name;
        }

        public String getHttpUrl()
        {
            return httpUrl;
        }

        public void setHttpUrl(String httpUrl)
        {
            this.httpUrl = httpUrl;
        }

        public String getWsUrl()
        {
            return wsUrl;
        }

        public void setWsUrl(String wsUrl)
        {
            this.wsUrl = wsUrl;
        }

        public Integer getSize()
        {
            return size;
        }

        public void setSize(Integer size)
        {
            this.size = size;
        }
    }
}
