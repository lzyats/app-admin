package com.ruoyi.system.service.impl;

import com.ruoyi.common.core.domain.entity.SysUserWallet;
import com.ruoyi.system.mapper.SysUserWalletMapper;
import com.ruoyi.system.service.ISysUserWalletService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

/**
 * 用户钱包服务实现类
 *
 * @author ruoyi
 */
@Service
public class SysUserWalletServiceImpl implements ISysUserWalletService {

    @Autowired
    private SysUserWalletMapper walletMapper;

    @Override
    public SysUserWallet selectWalletByUserId(Long userId) {
        return walletMapper.selectWalletByUserId(userId);
    }

    @Override
    public SysUserWallet selectWalletByUserIdAndCurrencyType(Long userId, String currencyType) {
        return walletMapper.selectWalletByUserIdAndCurrencyType(userId, currencyType);
    }

    @Override
    public SysUserWallet selectWalletByUserIdAndCurrencyTypeForUpdate(Long userId, String currencyType) {
        return walletMapper.selectWalletByUserIdAndCurrencyTypeForUpdate(userId, currencyType);
    }

    @Override
    public SysUserWallet selectWalletById(Long walletId) {
        return walletMapper.selectWalletById(walletId);
    }

    @Override
    public List<SysUserWallet> selectWalletList(SysUserWallet wallet) {
        return walletMapper.selectWalletList(wallet);
    }

    @Override
    public int insertWallet(SysUserWallet wallet) {
        return walletMapper.insertWallet(wallet);
    }

    @Override
    public int updateWallet(SysUserWallet wallet) {
        return walletMapper.updateWallet(wallet);
    }

    @Override
    public int deleteWalletById(Long walletId) {
        return walletMapper.deleteWalletById(walletId);
    }

    @Override
    public int deleteWalletByIds(Long[] walletIds) {
        return walletMapper.deleteWalletByIds(walletIds);
    }
}
