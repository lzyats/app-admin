package com.ruoyi.quartz.task;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.ruoyi.system.service.ISysInvestOrderService;

@Component("investOrderTask")
public class InvestOrderTask
{
    @Autowired
    private ISysInvestOrderService investOrderService;

    public void settleIncome()
    {
        investOrderService.settleDuePlans();
    }
}
