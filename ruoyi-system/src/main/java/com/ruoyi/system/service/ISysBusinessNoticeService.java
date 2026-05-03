package com.ruoyi.system.service;

/**
 * 业务提醒服务接口
 *
 * @author ruoyi
 */
public interface ISysBusinessNoticeService
{
    /**
     * 插入业务提醒消息
     *
     * @param title 提醒标题
     * @param content 提醒内容
     * @return 结果
     */
    int insertBusinessNotice(String title, String content);

    /**
     * 插入实名认证提醒消息
     *
     * @param userName 用户账号
     * @param realName 真实姓名
     * @return 结果
     */
    int insertRealNameAuthNotice(String userName, String realName);

    /**
     * 插入充值提醒消息
     *
     * @param userName 用户账号
     * @param amount 充值金额
     * @return 结果
     */
    int insertRechargeNotice(String userName, String amount);

    /**
     * 插入提现提醒消息
     *
     * @param userName 用户账号
     * @param amount 提现金额
     * @return 结果
     */
    int insertWithdrawNotice(String userName, String amount);
}
