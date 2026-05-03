package com.ruoyi.web.controller.system;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.system.domain.SysYebaoIncomeLog;
import com.ruoyi.system.service.ISysYebaoIncomeLogService;

@RestController
@RequestMapping("/system/yebao/income")
public class SysYebaoIncomeLogController extends BaseController
{
    @Autowired
    private ISysYebaoIncomeLogService incomeLogService;

    @PreAuthorize("@ss.hasPermi('system:yebao:income:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysYebaoIncomeLog log)
    {
        startPage();
        List<SysYebaoIncomeLog> list = incomeLogService.selectYebaoIncomeLogList(log);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('system:yebao:income:query')")
    @GetMapping(value = "/{incomeId}")
    public AjaxResult getInfo(@PathVariable Long incomeId)
    {
        return success(incomeLogService.selectYebaoIncomeLogById(incomeId));
    }
}
