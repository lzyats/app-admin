package com.ruoyi.system.mapper;

import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysUserWagWallet;

public interface SysUserWagWalletMapper
{
    SysUserWagWallet selectByUserId(@Param("userId") Long userId);

    SysUserWagWallet selectByUserIdForUpdate(@Param("userId") Long userId);

    int insertWallet(SysUserWagWallet wallet);

    int updateWallet(SysUserWagWallet wallet);
}

