package com.ruoyi.system.service;

import com.ruoyi.common.core.domain.entity.SysUserWallet;
import java.util.List;

/**
 * 用户钱包服务接口
 *
 * @author ruoyi
 */
public interface ISysUserWalletService {
    /**
     * 根据用户ID查询钱包
     *
     * @param userId 用户ID
     * @return 钱包信息
     */
    public SysUserWallet selectWalletByUserId(Long userId);

    /**
     * 根据用户ID和币种查询钱包
     *
     * @param userId 用户ID
     * @param currencyType 币种类型
     * @return 钱包信息
     */
    public SysUserWallet selectWalletByUserIdAndCurrencyType(Long userId, String currencyType);

    public SysUserWallet selectWalletByUserIdAndCurrencyTypeForUpdate(Long userId, String currencyType);

    /**
     * 根据钱包ID查询钱包
     *
     * @param walletId 钱包ID
     * @return 钱包信息
     */
    public SysUserWallet selectWalletById(Long walletId);

    /**
     * 查询钱包列表
     *
     * @param wallet 钱包信息
     * @return 钱包列表
     */
    public List<SysUserWallet> selectWalletList(SysUserWallet wallet);

    /**
     * 新增钱包
     *
     * @param wallet 钱包信息
     * @return 结果
     */
    public int insertWallet(SysUserWallet wallet);

    /**
     * 修改钱包
     *
     * @param wallet 钱包信息
     * @return 结果
     */
    public int updateWallet(SysUserWallet wallet);

    /**
     * 删除钱包
     *
     * @param walletId 钱包ID
     * @return 结果
     */
    public int deleteWalletById(Long walletId);

    /**
     * 批量删除钱包
     *
     * @param walletIds 钱包ID列表
     * @return 结果
     */
    public int deleteWalletByIds(Long[] walletIds);
}
