package com.ruoyi.system.mapper;

import com.ruoyi.common.core.domain.entity.SysUserWalletLog;
import java.util.List;

/**
 * 用户账变Mapper接口
 * 
 * @author ruoyi
 */
public interface SysUserWalletLogMapper {
    /**
     * 根据用户ID查询账变记录
     * 
     * @param userId 用户ID
     * @return 账变记录列表
     */
    public List<SysUserWalletLog> selectLogsByUserId(Long userId);
    
    /**
     * 根据钱包ID查询账变记录
     * 
     * @param walletId 钱包ID
     * @return 账变记录列表
     */
    public List<SysUserWalletLog> selectLogsByWalletId(Long walletId);
    
    /**
     * 根据账变ID查询账变记录
     * 
     * @param logId 账变ID
     * @return 账变记录
     */
    public SysUserWalletLog selectLogById(Long logId);
    
    /**
     * 查询账变记录列表
     * 
     * @param log 账变记录
     * @return 账变记录列表
     */
    public List<SysUserWalletLog> selectLogList(SysUserWalletLog log);
    
    /**
     * 新增账变记录
     * 
     * @param log 账变记录
     * @return 结果
     */
    public int insertLog(SysUserWalletLog log);
    
    /**
     * 修改账变记录
     * 
     * @param log 账变记录
     * @return 结果
     */
    public int updateLog(SysUserWalletLog log);
    
    /**
     * 删除账变记录
     * 
     * @param logId 账变ID
     * @return 结果
     */
    public int deleteLogById(Long logId);
    
    /**
     * 批量删除账变记录
     * 
     * @param logIds 账变ID列表
     * @return 结果
     */
    public int deleteLogByIds(Long[] logIds);
}