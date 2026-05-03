package com.ruoyi.quartz.task;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.ruoyi.system.service.ISysYebaoOrderService;

@Component("yebaoTask")
public class YebaoTask
{
    @Autowired
    private ISysYebaoOrderService yebaoOrderService;

    public void settleIncome()
    {
        yebaoOrderService.settleDueIncome();
    }
}
