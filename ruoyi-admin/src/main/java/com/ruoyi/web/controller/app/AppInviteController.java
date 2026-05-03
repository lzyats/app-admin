package com.ruoyi.web.controller.app;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.Base64;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.Map;
import javax.imageio.ImageIO;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.utils.StringUtils;
import org.springframework.util.FastByteArrayOutputStream;

/**
 * 邀请页二维码接口。
 */
@RestController
@RequestMapping("/app/invite")
public class AppInviteController
{
    @PostMapping("/qr")
    public AjaxResult qr(@RequestBody InviteQrRequest request)
    {
        if (request == null || StringUtils.isEmpty(request.getContent()))
        {
            return AjaxResult.error("content 不能为空");
        }

        try
        {
            String qrImageBase64 = generateQrBase64(request.getContent().trim(), request.getSize());
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("qrImageBase64", qrImageBase64);
            data.put("contentType", "image/png");
            return AjaxResult.success(data);
        }
        catch (Exception e)
        {
            return AjaxResult.error("生成二维码失败");
        }
    }

    private String generateQrBase64(String content, Integer size) throws WriterException, IOException
    {
        int qrSize = (size == null || size < 200 || size > 1200) ? 360 : size;

        Map<EncodeHintType, Object> hints = new EnumMap<EncodeHintType, Object>(EncodeHintType.class);
        hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
        hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.M);
        hints.put(EncodeHintType.MARGIN, 0);

        BitMatrix bitMatrix = new MultiFormatWriter().encode(content, BarcodeFormat.QR_CODE, qrSize, qrSize, hints);
        BufferedImage image = trimWhitespace(MatrixToImageWriter.toBufferedImage(bitMatrix));

        FastByteArrayOutputStream os = new FastByteArrayOutputStream();
        ImageIO.write(image, "png", os);
        return Base64.getEncoder().encodeToString(os.toByteArray());
    }

    private BufferedImage trimWhitespace(BufferedImage image)
    {
        int minX = image.getWidth();
        int minY = image.getHeight();
        int maxX = -1;
        int maxY = -1;

        for (int y = 0; y < image.getHeight(); y++)
        {
            for (int x = 0; x < image.getWidth(); x++)
            {
                int argb = image.getRGB(x, y);
                int alpha = (argb >>> 24) & 0xFF;
                int red = (argb >>> 16) & 0xFF;
                int green = (argb >>> 8) & 0xFF;
                int blue = argb & 0xFF;
                if (alpha > 0 && (red < 250 || green < 250 || blue < 250))
                {
                    if (x < minX)
                    {
                        minX = x;
                    }
                    if (y < minY)
                    {
                        minY = y;
                    }
                    if (x > maxX)
                    {
                        maxX = x;
                    }
                    if (y > maxY)
                    {
                        maxY = y;
                    }
                }
            }
        }

        if (maxX < minX || maxY < minY)
        {
            return image;
        }

        int padding = Math.max(4, Math.min(image.getWidth(), image.getHeight()) / 40);
        int x = Math.max(0, minX - padding);
        int y = Math.max(0, minY - padding);
        int width = Math.min(image.getWidth() - x, (maxX - minX + 1) + padding * 2);
        int height = Math.min(image.getHeight() - y, (maxY - minY + 1) + padding * 2);
        return image.getSubimage(x, y, width, height);
    }

    public static class InviteQrRequest
    {
        private String content;
        private Integer size;

        public String getContent()
        {
            return content;
        }

        public void setContent(String content)
        {
            this.content = content;
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
