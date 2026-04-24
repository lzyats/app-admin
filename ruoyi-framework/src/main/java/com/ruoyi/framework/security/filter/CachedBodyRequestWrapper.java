package com.ruoyi.framework.security.filter;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import jakarta.servlet.ReadListener;
import jakarta.servlet.ServletInputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;

/**
 * 可替换请求体的包装器
 *
 * @author ruoyi
 */
public class CachedBodyRequestWrapper extends HttpServletRequestWrapper
{
    private final byte[] body;

    public CachedBodyRequestWrapper(HttpServletRequest request, byte[] body)
    {
        super(request);
        this.body = body;
    }

    @Override
    public ServletInputStream getInputStream()
    {
        ByteArrayInputStream bais = new ByteArrayInputStream(body);
        return new ServletInputStream()
        {
            @Override
            public int read()
            {
                return bais.read();
            }

            @Override
            public boolean isFinished()
            {
                return bais.available() == 0;
            }

            @Override
            public boolean isReady()
            {
                return true;
            }

            @Override
            public void setReadListener(ReadListener readListener)
            {
            }
        };
    }

    @Override
    public BufferedReader getReader() throws IOException
    {
        return new BufferedReader(new InputStreamReader(getInputStream(), StandardCharsets.UTF_8));
    }

    @Override
    public int getContentLength()
    {
        return body.length;
    }

    @Override
    public long getContentLengthLong()
    {
        return body.length;
    }
}
