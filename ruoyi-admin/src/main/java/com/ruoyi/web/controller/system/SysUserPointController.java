package com.ruoyi.web.controller.system;

import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysUserPointAccount;
import com.ruoyi.common.core.domain.entity.SysUserPointLog;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.service.ISysUserPointLogService;
import com.ruoyi.system.service.ISysUserPointService;

/**
 * 用户积分管理控制器
 */
@RestController
@RequestMapping("/system/point")
public class SysUserPointController extends BaseController {
    @Autowired
    private ISysUserPointService pointService;

    @Autowired
    private ISysUserPointLogService pointLogService;

    @GetMapping("/account/list")
    @PreAuthorize("@ss.hasPermi('system:point:list')")
    public TableDataInfo accountList(SysUserPointAccount pointAccount) {
        startPage();
        List<SysUserPointAccount> list = pointService.selectPointAccountList(pointAccount);
        return getDataTable(list);
    }

    @GetMapping("/account/{pointAccountId}")
    @PreAuthorize("@ss.hasPermi('system:point:query')")
    public AjaxResult getAccount(@PathVariable Long pointAccountId) {
        return success(pointService.selectPointAccountById(pointAccountId));
    }

    @PostMapping("/account")
    @PreAuthorize("@ss.hasPermi('system:point:add')")
    @Log(title = "积分账户新增", businessType = BusinessType.INSERT)
    public AjaxResult addAccount(@RequestBody SysUserPointAccount pointAccount) {
        if (pointAccount.getUserId() == null) {
            return error("User ID cannot be empty.");
        }
        ensureDefaults(pointAccount);
        return toAjax(pointService.insertPointAccount(pointAccount));
    }

    @PutMapping("/account")
    @PreAuthorize("@ss.hasPermi('system:point:edit')")
    @Log(title = "积分账户修改", businessType = BusinessType.UPDATE)
    public AjaxResult editAccount(@RequestBody SysUserPointAccount pointAccount) {
        if (pointAccount.getPointAccountId() == null) {
            return error("Point account ID cannot be empty.");
        }
        return toAjax(pointService.updatePointAccount(pointAccount));
    }

    @DeleteMapping("/account/{pointAccountIds}")
    @PreAuthorize("@ss.hasPermi('system:point:remove')")
    @Log(title = "积分账户删除", businessType = BusinessType.DELETE)
    public AjaxResult removeAccount(@PathVariable Long[] pointAccountIds) {
        return toAjax(pointService.deletePointAccountByIds(pointAccountIds));
    }

    @PostMapping("/account/grant")
    @PreAuthorize("@ss.hasPermi('system:point:edit')")
    @Log(title = "积分发放", businessType = BusinessType.UPDATE)
    public AjaxResult grant(@RequestBody PointChangeBody body) {
        if (body.getUserId() == null || body.getPoints() == null || body.getPoints() <= 0) {
            return error("User ID and points are required.");
        }
        return toAjax(pointService.grantPoints(body.getUserId(), body.getUserName(), body.getPoints(), normalizeSourceType(body.getSourceType()), body.getSourceId(), body.getSourceNo(), body.getRemark()));
    }

    @PostMapping("/account/deduct")
    @PreAuthorize("@ss.hasPermi('system:point:edit')")
    @Log(title = "积分扣减", businessType = BusinessType.UPDATE)
    public AjaxResult deduct(@RequestBody PointChangeBody body) {
        if (body.getUserId() == null || body.getPoints() == null || body.getPoints() <= 0) {
            return error("User ID and points are required.");
        }
        return toAjax(pointService.spendPoints(body.getUserId(), body.getUserName(), body.getPoints(), normalizeSourceType(body.getSourceType()), body.getSourceId(), body.getSourceNo(), body.getRemark()));
    }

    @GetMapping("/log/list")
    @PreAuthorize("@ss.hasPermi('system:point:log:list')")
    public TableDataInfo logList(SysUserPointLog pointLog) {
        startPage();
        List<SysUserPointLog> list = pointLogService.selectPointLogList(pointLog);
        return getDataTable(list);
    }

    @GetMapping("/log/{logId}")
    @PreAuthorize("@ss.hasPermi('system:point:log:query')")
    public AjaxResult getLog(@PathVariable Long logId) {
        return success(pointLogService.selectPointLogById(logId));
    }

    @PutMapping("/log")
    @PreAuthorize("@ss.hasPermi('system:point:log:edit')")
    @Log(title = "积分账变修改", businessType = BusinessType.UPDATE)
    public AjaxResult editLog(@RequestBody SysUserPointLog pointLog) {
        if (pointLog.getLogId() == null) {
            return error("Log ID cannot be empty.");
        }
        return toAjax(pointLogService.updatePointLog(pointLog));
    }

    @DeleteMapping("/log/{logIds}")
    @PreAuthorize("@ss.hasPermi('system:point:log:remove')")
    @Log(title = "积分账变删除", businessType = BusinessType.DELETE)
    public AjaxResult removeLog(@PathVariable Long[] logIds) {
        return toAjax(pointLogService.deletePointLogByIds(logIds));
    }

    private void ensureDefaults(SysUserPointAccount pointAccount) {
        if (StringUtils.isBlank(pointAccount.getUserName())) {
            pointAccount.setUserName(SecurityUtils.getUsername());
        }
        if (pointAccount.getAvailablePoints() == null) {
            pointAccount.setAvailablePoints(0L);
        }
        if (pointAccount.getFrozenPoints() == null) {
            pointAccount.setFrozenPoints(0L);
        }
        if (pointAccount.getTotalEarned() == null) {
            pointAccount.setTotalEarned(0L);
        }
        if (pointAccount.getTotalSpent() == null) {
            pointAccount.setTotalSpent(0L);
        }
        if (pointAccount.getTotalAdjusted() == null) {
            pointAccount.setTotalAdjusted(0L);
        }
        Date now = new Date();
        if (pointAccount.getCreateTime() == null) {
            pointAccount.setCreateTime(now);
        }
        pointAccount.setUpdateTime(now);
    }

    private String normalizeSourceType(String sourceType) {
        if (StringUtils.isBlank(sourceType)) {
            return "manual";
        }
        return sourceType.trim().toLowerCase();
    }

    public static class PointChangeBody {
        private Long userId;
        private String userName;
        private Long points;
        private String sourceType;
        private Long sourceId;
        private String sourceNo;
        private String remark;

        public Long getUserId() {
            return userId;
        }

        public void setUserId(Long userId) {
            this.userId = userId;
        }

        public String getUserName() {
            return userName;
        }

        public void setUserName(String userName) {
            this.userName = userName;
        }

        public Long getPoints() {
            return points;
        }

        public void setPoints(Long points) {
            this.points = points;
        }

        public String getSourceType() {
            return sourceType;
        }

        public void setSourceType(String sourceType) {
            this.sourceType = sourceType;
        }

        public Long getSourceId() {
            return sourceId;
        }

        public void setSourceId(Long sourceId) {
            this.sourceId = sourceId;
        }

        public String getSourceNo() {
            return sourceNo;
        }

        public void setSourceNo(String sourceNo) {
            this.sourceNo = sourceNo;
        }

        public String getRemark() {
            return remark;
        }

        public void setRemark(String remark) {
            this.remark = remark;
        }
    }
}
