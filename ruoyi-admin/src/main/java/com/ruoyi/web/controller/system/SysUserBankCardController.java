package com.ruoyi.web.controller.system;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.system.domain.SysUserBankCard;
import com.ruoyi.system.service.ISysUserBankCardService;

/**
 * Bank card management.
 */
@RestController
@RequestMapping("/system/bankCard")
public class SysUserBankCardController extends BaseController
{
    @Autowired
    private ISysUserBankCardService bankCardService;

    @GetMapping("/list")
    @PreAuthorize("@ss.hasPermi('operation:bankCard:list')")
    public TableDataInfo list(SysUserBankCard bankCard)
    {
        startPage();
        List<SysUserBankCard> list = bankCardService.selectBankCardList(bankCard);
        return getDataTable(list);
    }

    @GetMapping("/{bankCardId}")
    @PreAuthorize("@ss.hasPermi('operation:bankCard:list')")
    public AjaxResult getInfo(@PathVariable Long bankCardId)
    {
        return success(bankCardService.selectBankCardById(bankCardId));
    }

    @DeleteMapping("/{bankCardIds}")
    @PreAuthorize("@ss.hasPermi('operation:bankCard:remove')")
    @Log(title = "Bank card delete", businessType = BusinessType.DELETE)
    public AjaxResult remove(@PathVariable Long[] bankCardIds)
    {
        return toAjax(bankCardService.deleteBankCardByIds(bankCardIds));
    }
}
