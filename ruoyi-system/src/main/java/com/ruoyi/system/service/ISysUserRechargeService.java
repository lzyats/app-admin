package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysUserRecharge;

/**
 * 用户充值服务接口
 */
public interface ISysUserRechargeService
{
    SysUserRecharge selectRechargeById(Long rechargeId);

    List<SysUserRecharge> selectRechargeList(SysUserRecharge recharge);

    int insertRecharge(SysUserRecharge recharge);

    int reviewRecharge(SysUserRecharge recharge);

    int deleteRechargeById(Long rechargeId);

    int deleteRechargeByIds(Long[] rechargeIds);
}
