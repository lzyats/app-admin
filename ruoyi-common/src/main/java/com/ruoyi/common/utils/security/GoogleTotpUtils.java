package com.ruoyi.common.utils.security;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public final class GoogleTotpUtils
{
    private static final String BASE32_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
    private static final int SECRET_BYTE_LENGTH = 20;
    private static final int TIME_STEP_SECONDS = 30;

    private GoogleTotpUtils()
    {
    }

    public static String generateSecret()
    {
        byte[] bytes = new byte[SECRET_BYTE_LENGTH];
        new SecureRandom().nextBytes(bytes);
        return encodeBase32(bytes);
    }

    public static boolean verifyCode(String secret, String code)
    {
        return verifyCode(secret, code, 1);
    }

    public static boolean verifyCode(String secret, String code, int window)
    {
        if (secret == null || secret.trim().isEmpty() || code == null || !code.matches("\\d{6}"))
        {
            return false;
        }
        byte[] key = decodeBase32(secret.trim().toUpperCase());
        long timeIndex = System.currentTimeMillis() / 1000L / TIME_STEP_SECONDS;
        for (int i = -window; i <= window; i++)
        {
            String expect = generateTotp(key, timeIndex + i);
            if (code.equals(expect))
            {
                return true;
            }
        }
        return false;
    }

    public static String buildOtpAuthUri(String issuer, String account, String secret)
    {
        String safeIssuer = issuer == null || issuer.trim().isEmpty() ? "RuoYi" : issuer.trim();
        String safeAccount = account == null || account.trim().isEmpty() ? "admin" : account.trim();
        String label = urlEncode(safeIssuer + ":" + safeAccount);
        return "otpauth://totp/" + label
            + "?secret=" + secret
            + "&issuer=" + urlEncode(safeIssuer)
            + "&algorithm=SHA1&digits=6&period=30";
    }

    private static String generateTotp(byte[] key, long counter)
    {
        try
        {
            byte[] data = new byte[8];
            long value = counter;
            for (int i = 7; i >= 0; i--)
            {
                data[i] = (byte) (value & 0xFF);
                value >>= 8;
            }
            Mac mac = Mac.getInstance("HmacSHA1");
            mac.init(new SecretKeySpec(key, "HmacSHA1"));
            byte[] hash = mac.doFinal(data);
            int offset = hash[hash.length - 1] & 0x0F;
            int binary = ((hash[offset] & 0x7F) << 24)
                | ((hash[offset + 1] & 0xFF) << 16)
                | ((hash[offset + 2] & 0xFF) << 8)
                | (hash[offset + 3] & 0xFF);
            int otp = binary % 1_000_000;
            return String.format("%06d", otp);
        }
        catch (Exception e)
        {
            return "";
        }
    }

    private static String encodeBase32(byte[] data)
    {
        StringBuilder sb = new StringBuilder();
        int currByte;
        int digit;
        int i = 0;
        int index = 0;
        while (i < data.length)
        {
            currByte = data[i] >= 0 ? data[i] : data[i] + 256;
            if (index > 3)
            {
                int nextByte = (i + 1) < data.length ? (data[i + 1] >= 0 ? data[i + 1] : data[i + 1] + 256) : 0;
                digit = currByte & (0xFF >> index);
                index = (index + 5) % 8;
                digit <<= index;
                digit |= nextByte >> (8 - index);
                i++;
            }
            else
            {
                digit = (currByte >> (8 - (index + 5))) & 0x1F;
                index = (index + 5) % 8;
                if (index == 0)
                {
                    i++;
                }
            }
            sb.append(BASE32_ALPHABET.charAt(digit));
        }
        return sb.toString();
    }

    private static byte[] decodeBase32(String base32)
    {
        String normalized = base32.replace("=", "").trim().toUpperCase();
        int numBytes = normalized.length() * 5 / 8;
        byte[] result = new byte[numBytes];
        int buffer = 0;
        int bitsLeft = 0;
        int index = 0;
        for (int i = 0; i < normalized.length(); i++)
        {
            int val = BASE32_ALPHABET.indexOf(normalized.charAt(i));
            if (val < 0)
            {
                continue;
            }
            buffer = (buffer << 5) | val;
            bitsLeft += 5;
            if (bitsLeft >= 8)
            {
                result[index++] = (byte) ((buffer >> (bitsLeft - 8)) & 0xFF);
                bitsLeft -= 8;
                if (index >= result.length)
                {
                    break;
                }
            }
        }
        return result;
    }

    private static String urlEncode(String text)
    {
        return URLEncoder.encode(text, StandardCharsets.UTF_8);
    }
}
