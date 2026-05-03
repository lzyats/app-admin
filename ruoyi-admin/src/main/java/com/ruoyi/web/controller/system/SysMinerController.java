package com.ruoyi.web.controller.system;

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
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.SysMiner;
import com.ruoyi.system.service.ISysMinerService;

@RestController
@RequestMapping("/system/miner")
public class SysMinerController extends BaseController
{
    @Autowired
    private ISysMinerService minerService;

    @PreAuthorize("@ss.hasPermi('system:miner:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysMiner miner)
    {
        startPage();
        List<SysMiner> list = minerService.selectMinerList(miner);
        return getDataTable(list);
    }

    @GetMapping(value = "/{minerId}")
    public AjaxResult getInfo(@PathVariable Long minerId)
    {
        return success(minerService.selectMinerById(minerId));
    }

    @PreAuthorize("@ss.hasPermi('system:miner:add')")
    @Log(title = "矿机", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysMiner miner)
    {
        miner.setCreateBy(getUsername());
        return toAjax(minerService.insertMiner(miner));
    }

    @PreAuthorize("@ss.hasPermi('system:miner:edit')")
    @Log(title = "矿机", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysMiner miner)
    {
        miner.setUpdateBy(getUsername());
        return toAjax(minerService.updateMiner(miner));
    }

    @PreAuthorize("@ss.hasPermi('system:miner:remove')")
    @Log(title = "矿机", businessType = BusinessType.DELETE)
    @DeleteMapping("/{minerIds}")
    public AjaxResult remove(@PathVariable Long[] minerIds)
    {
        return toAjax(minerService.deleteMinerByIds(minerIds));
    }
}

