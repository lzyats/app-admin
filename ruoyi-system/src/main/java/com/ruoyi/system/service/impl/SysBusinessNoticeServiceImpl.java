package com.ruoyi.system.service.impl;

import java.util.Date;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.domain.SysNotice;
import com.ruoyi.system.mapper.SysNoticeMapper;
import com.ruoyi.system.service.ISysBusinessNoticeService;

/**
 * 业务通知服务实现类。
 */
@Service
public class SysBusinessNoticeServiceImpl implements ISysBusinessNoticeService
{
    private static final String NOTICE_TYPE_BUSINESS = "3";

    @Autowired
    private SysNoticeMapper noticeMapper;

    @Override
    public int insertBusinessNotice(String title, String content)
    {
        SysNotice notice = new SysNotice();
        notice.setNoticeTitle(title);
        notice.setNoticeContent(content);
        notice.setNoticeType(NOTICE_TYPE_BUSINESS);
        notice.setStatus("0");
        notice.setCreateBy("system");
        notice.setCreateTime(new Date());
        return noticeMapper.insertNotice(notice);
    }

    @Override
    public int insertRealNameAuthNotice(String userName, String realName)
    {
        return insertBusinessNotice(
            "实名认证待审核",
            String.format("用户 %s（账号：%s）提交了实名认证申请。", realName, userName));
    }

    @Override
    public int insertRechargeNotice(String userName, String amount)
    {
        return insertBusinessNotice(
            "充值申请待审核",
            String.format("用户 %s 提交了一笔充值申请，金额 %s。", userName, amount));
    }

    @Override
    public int insertWithdrawNotice(String userName, String amount)
    {
        return insertBusinessNotice(
            "提现申请待审核",
            String.format("用户 %s 提交了一笔提现申请，金额 %s。", userName, amount));
    }
}
