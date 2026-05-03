package com.ruoyi.web.controller.app;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.system.domain.SysUserLevel;
import com.ruoyi.system.service.ISysUserLevelService;

@RestController
@RequestMapping("/app/userLevel")
public class AppUserLevelController extends BaseController {
    @Autowired
    private ISysUserLevelService userLevelService;

    @GetMapping("/options")
    public AjaxResult options() {
        List<SysUserLevel> list = userLevelService.selectEnabledOptionsCached();
        return AjaxResult.success(list);
    }
}

