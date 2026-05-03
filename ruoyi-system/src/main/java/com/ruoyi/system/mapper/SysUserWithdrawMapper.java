package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.SysUserWithdraw;

/**
 * User withdraw mapper.
 */
public interface SysUserWithdrawMapper
{
    SysUserWithdraw selectWithdrawById(Long withdrawId);

    SysUserWithdraw selectWithdrawByRequestNo(String requestNo);

    List<SysUserWithdraw> selectWithdrawList(SysUserWithdraw withdraw);

    int insertWithdraw(SysUserWithdraw withdraw);

    int updateWithdraw(SysUserWithdraw withdraw);

    int deleteWithdrawById(Long withdrawId);

    int deleteWithdrawByIds(Long[] withdrawIds);
}
