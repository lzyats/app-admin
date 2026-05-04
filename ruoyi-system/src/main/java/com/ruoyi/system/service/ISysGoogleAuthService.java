package com.ruoyi.system.service;

import java.util.Map;

public interface ISysGoogleAuthService
{
    Map<String, Object> status(Long userId, String userName);

    Map<String, Object> initBind(Long userId, String userName);

    void bind(Long userId, String userName, String code);

    void unbind(Long userId, String code);

    void validateOperation(Long userId, String googleCode);
}
