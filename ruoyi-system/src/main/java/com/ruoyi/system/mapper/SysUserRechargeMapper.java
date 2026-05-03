package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.SysUserRecharge;

/**
 * 用户充值 Mapper
 */
public interface SysUserRechargeMapper
{
    SysUserRecharge selectRechargeById(Long rechargeId);

    List<SysUserRecharge> selectRechargeList(SysUserRecharge recharge);

    int insertRecharge(SysUserRecharge recharge);

    int updateRecharge(SysUserRecharge recharge);

    int deleteRechargeById(Long rechargeId);

    int deleteRechargeByIds(Long[] rechargeIds);
}
