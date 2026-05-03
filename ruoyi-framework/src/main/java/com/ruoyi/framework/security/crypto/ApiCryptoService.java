package com.ruoyi.framework.security.crypto;

import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import com.ruoyi.common.utils.StringUtils;
import jakarta.servlet.http.HttpServletRequest;
import tools.jackson.databind.ObjectMapper;

/**
 * API 鐎靛湱袨閸旂姾袙鐎靛棙婀囬崝?
 *
 * 接口说明。
 * 接口说明。
 * 接口说明。
 *
 * @author ruoyi
 */
@Component
public class ApiCryptoService
{
    private static final String AES_TRANSFORMATION = "AES/CBC/PKCS5Padding";

    private final ObjectMapper objectMapper;

    @Value("${api-security.aes.enabled:false}")
    private boolean enabled;

    @Value("${api-security.aes.header:X-Api-Encrypt}")
    private String encryptHeader;

    @Value("${api-security.aes.headerValue:1}")
    private String encryptHeaderValue;

    @Value("${api-security.aes.key:}")
    private String key;

    @Value("${api-security.aes.iv:}")
    private String iv;

    @Value("${api-security.aes.encryptResponsePaths:}")
    private String encryptResponsePaths;

    private static final AntPathMatcher PATH_MATCHER = new AntPathMatcher();

    public ApiCryptoService(ObjectMapper objectMapper)
    {
        this.objectMapper = objectMapper;
    }

    public boolean shouldDecryptRequest(HttpServletRequest request)
    {
        if (!enabled)
        {
            return false;
        }
        String headerValue = request.getHeader(encryptHeader);
        return StringUtils.isNotEmpty(headerValue) && StringUtils.equalsIgnoreCase(headerValue, encryptHeaderValue);
    }

    public boolean shouldEncryptResponse(HttpServletRequest request)
    {
        if (!enabled)
        {
            return false;
        }
        if (shouldDecryptRequest(request))
        {
            return true;
        }
        return shouldEncryptByPath(request);
    }

    public String getEncryptHeader()
    {
        return encryptHeader;
    }

    public String getEncryptHeaderValue()
    {
        return encryptHeaderValue;
    }

    public String decryptText(String cipherText)
    {
        validateKeyAndIv();
        if (StringUtils.isEmpty(cipherText))
        {
            return "";
        }

        try
        {
            Cipher cipher = Cipher.getInstance(AES_TRANSFORMATION);
            SecretKeySpec keySpec = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "AES");
            IvParameterSpec ivSpec = new IvParameterSpec(iv.getBytes(StandardCharsets.UTF_8));
            cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec);
            byte[] plainBytes = cipher.doFinal(Base64.getDecoder().decode(cipherText));
            return new String(plainBytes, StandardCharsets.UTF_8);
        }
        catch (GeneralSecurityException e)
        {
            throw new IllegalArgumentException("AES鐟欙絽鐦戞径杈Е", e);
        }
    }

    public String encryptAny(Object rawData)
    {
        validateKeyAndIv();
        String plainText = toJsonText(rawData);
        if (StringUtils.isEmpty(plainText))
        {
            return "";
        }

        try
        {
            Cipher cipher = Cipher.getInstance(AES_TRANSFORMATION);
            SecretKeySpec keySpec = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "AES");
            IvParameterSpec ivSpec = new IvParameterSpec(iv.getBytes(StandardCharsets.UTF_8));
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec);
            byte[] cipherBytes = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(cipherBytes);
        }
        catch (GeneralSecurityException e)
        {
            throw new IllegalArgumentException("AES閸旂姴鐦戞径杈Е", e);
        }
    }

    private String toJsonText(Object rawData)
    {
        if (rawData == null)
        {
            return "";
        }
        if (rawData instanceof String text)
        {
            return text;
        }
        try
        {
            return objectMapper.writeValueAsString(rawData);
        }
        catch (Exception e)
        {
            throw new IllegalArgumentException("对象序列化失败", e);
        }
    }

    private void validateKeyAndIv()
    {
        if (!enabled)
        {
            return;
        }
        int keyLength = key == null ? 0 : key.length();
        int ivLength = iv == null ? 0 : iv.length();
        if (!(keyLength == 16 || keyLength == 24 || keyLength == 32))
        {
            throw new IllegalStateException("api-security.aes.key 闂€鍨韫囧懘銆忛弰?16/24/32");
        }
        if (ivLength != 16)
        {
            throw new IllegalStateException("api-security.aes.iv 闂€鍨韫囧懘銆忛弰?16");
        }
    }

    private boolean shouldEncryptByPath(HttpServletRequest request)
    {
        if (StringUtils.isEmpty(encryptResponsePaths))
        {
            return false;
        }
        String uri = request.getRequestURI();
        String[] patterns = encryptResponsePaths.split(",");
        for (String patternRaw : patterns)
        {
            String pattern = patternRaw == null ? "" : patternRaw.trim();
            if (StringUtils.isEmpty(pattern))
            {
                continue;
            }
            if (PATH_MATCHER.match(pattern, uri))
            {
                return true;
            }
        }
        return false;
    }
}
