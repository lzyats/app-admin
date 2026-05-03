package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysUserWithdraw;

/**
 * User withdraw service.
 */
public interface ISysUserWithdrawService
{
    SysUserWithdraw selectWithdrawById(Long withdrawId);

    List<SysUserWithdraw> selectWithdrawList(SysUserWithdraw withdraw);

    int insertWithdraw(SysUserWithdraw withdraw);

    int reviewWithdraw(SysUserWithdraw withdraw);

    int deleteWithdrawById(Long withdrawId);

    int deleteWithdrawByIds(Long[] withdrawIds);
}
