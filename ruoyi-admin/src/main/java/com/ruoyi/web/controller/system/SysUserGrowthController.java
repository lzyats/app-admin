package com.ruoyi.web.controller.system;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUserGrowthLog;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.service.ISysGrowthValueService;
import com.ruoyi.system.service.ISysUserGrowthLogService;

/**
 * 用户成长值管理
 */
@RestController
@RequestMapping("/system/growth")
public class SysUserGrowthController extends BaseController
{
    @Autowired
    private ISysGrowthValueService growthValueService;

    @Autowired
    private ISysUserGrowthLogService growthLogService;

    @PreAuthorize("@ss.hasPermi('system:user:list')")
    @GetMapping("/log/list")
    public TableDataInfo logList(SysUserGrowthLog growthLog)
    {
        startPage();
        List<SysUserGrowthLog> list = growthLogService.selectGrowthLogList(growthLog);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('system:user:edit')")
    @Log(title = "成长值增加", businessType = BusinessType.UPDATE)
    @PostMapping("/increase")
    public AjaxResult increase(@RequestBody GrowthChangeBody body)
    {
        validateBody(body);
        boolean success = growthValueService.increaseGrowthValue(
            body.getUserId(),
            body.getGrowthValue(),
            normalizeSourceType(body.getSourceType(), "manual"),
            body.getSourceId(),
            body.getSourceNo(),
            body.getRemark()
        );
        return toAjax(success ? 1 : 0);
    }

    @PreAuthorize("@ss.hasPermi('system:user:edit')")
    @Log(title = "成长值扣除", businessType = BusinessType.UPDATE)
    @PostMapping("/decrease")
    public AjaxResult decrease(@RequestBody GrowthChangeBody body)
    {
        validateBody(body);
        boolean success = growthValueService.decreaseGrowthValue(
            body.getUserId(),
            body.getGrowthValue(),
            normalizeSourceType(body.getSourceType(), "manual"),
            body.getSourceId(),
            body.getSourceNo(),
            body.getRemark()
        );
        return toAjax(success ? 1 : 0);
    }

    private void validateBody(GrowthChangeBody body)
    {
        if (body == null || body.getUserId() == null)
        {
            throw new ServiceException("用户ID不能为空");
        }
        if (body.getGrowthValue() == null || body.getGrowthValue() <= 0)
        {
            throw new ServiceException("成长值必须大于0");
        }
    }

    private String normalizeSourceType(String sourceType, String defaultType)
    {
        if (StringUtils.isBlank(sourceType))
        {
            return defaultType;
        }
        return sourceType.trim().toLowerCase();
    }

    public static class GrowthChangeBody
    {
        private Long userId;
        private Long growthValue;
        private String sourceType;
        private Long sourceId;
        private String sourceNo;
        private String remark;

        public Long getUserId()
        {
            return userId;
        }

        public void setUserId(Long userId)
        {
            this.userId = userId;
        }

        public Long getGrowthValue()
        {
            return growthValue;
        }

        public void setGrowthValue(Long growthValue)
        {
            this.growthValue = growthValue;
        }

        public String getSourceType()
        {
            return sourceType;
        }

        public void setSourceType(String sourceType)
        {
            this.sourceType = sourceType;
        }

        public Long getSourceId()
        {
            return sourceId;
        }

        public void setSourceId(Long sourceId)
        {
            this.sourceId = sourceId;
        }

        public String getSourceNo()
        {
            return sourceNo;
        }

        public void setSourceNo(String sourceNo)
        {
            this.sourceNo = sourceNo;
        }

        public String getRemark()
        {
            return remark;
        }

        public void setRemark(String remark)
        {
            this.remark = remark;
        }
    }
}
