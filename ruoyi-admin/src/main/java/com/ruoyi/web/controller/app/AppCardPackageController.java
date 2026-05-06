package com.ruoyi.web.controller.app;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.system.mapper.SysCardPackageMapper;
import com.ruoyi.system.service.ISysLevelTrialTemplateService;

/**
 * APP 卡包接口。
 */
@RestController
@RequestMapping("/app/cardPackage")
public class AppCardPackageController extends BaseController
{
    @Autowired
    private SysCardPackageMapper cardPackageMapper;

    @Autowired
    private ISysLevelTrialTemplateService levelTrialTemplateService;

    @GetMapping("/coupons")
    public AjaxResult coupons()
    {
        List<Map<String, Object>> list = cardPackageMapper.selectMyCouponCards(getUserId());
        return AjaxResult.success(list);
    }

    @GetMapping("/trials")
    public AjaxResult trials()
    {
        List<Map<String, Object>> list = cardPackageMapper.selectMyTrialCards(getUserId());
        return AjaxResult.success(list);
    }

    @PostMapping("/trials/use")
    public AjaxResult useTrial(@RequestBody Map<String, Object> body)
    {
        Long userTrialId = parseLong(body == null ? null : body.get("userTrialId"), 0L);
        if (userTrialId == null || userTrialId <= 0L)
        {
            throw new ServiceException("体验卡ID不能为空");
        }
        Map<String, Object> result = levelTrialTemplateService.startTrialCard(getUserId(), userTrialId, SecurityUtils.getUsername());
        return AjaxResult.success(result);
    }

    @PostMapping("/trials/start")
    public AjaxResult startTrial(@RequestBody Map<String, Object> body)
    {
        Long userTrialId = parseLong(body == null ? null : body.get("userTrialId"), 0L);
        if (userTrialId == null || userTrialId <= 0L)
        {
            throw new ServiceException("体验卡ID不能为空");
        }
        Map<String, Object> result = levelTrialTemplateService.startTrialCard(getUserId(), userTrialId, SecurityUtils.getUsername());
        return AjaxResult.success(result);
    }

    @PostMapping("/trials/end")
    public AjaxResult endTrial(@RequestBody Map<String, Object> body)
    {
        Long userTrialId = parseLong(body == null ? null : body.get("userTrialId"), 0L);
        if (userTrialId == null || userTrialId <= 0L)
        {
            throw new ServiceException("体验卡ID不能为空");
        }
        Map<String, Object> result = levelTrialTemplateService.endTrialCard(getUserId(), userTrialId, SecurityUtils.getUsername());
        return AjaxResult.success(result);
    }

    private Long parseLong(Object value, Long defaultValue)
    {
        if (value == null)
        {
            return defaultValue;
        }
        try
        {
            String text = String.valueOf(value).trim();
            if (text.isEmpty() || "null".equalsIgnoreCase(text))
            {
                return defaultValue;
            }
            return Long.valueOf(text);
        }
        catch (Exception e)
        {
            return defaultValue;
        }
    }
}
