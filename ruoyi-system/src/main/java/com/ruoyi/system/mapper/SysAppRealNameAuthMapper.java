package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.SysAppRealNameAuth;

/**
 * APP实名认证 数据层
 *
 * @author ruoyi
 */
public interface SysAppRealNameAuthMapper
{
    /**
     * 查询实名认证列表
     *
     * @param auth 实名认证信息
     * @return 实名认证集合
     */
    public List<SysAppRealNameAuth> selectAuthList(SysAppRealNameAuth auth);

    /**
     * 通过用户ID查询实名认证信息
     *
     * @param userId 用户ID
     * @return 实名认证信息
     */
    public SysAppRealNameAuth selectAuthByUserId(Long userId);

    /**
     * 通过ID查询实名认证
     *
     * @param authId 认证ID
     * @return 实名认证信息
     */
    public SysAppRealNameAuth selectAuthById(Long authId);

    /**
     * 新增实名认证
     *
     * @param auth 实名认证信息
     * @return 结果
     */
    public int insertAuth(SysAppRealNameAuth auth);

    /**
     * 修改实名认证
     *
     * @param auth 实名认证信息
     * @return 结果
     */
    public int updateAuth(SysAppRealNameAuth auth);

    /**
     * 删除实名认证
     *
     * @param authId 认证ID
     * @return 结果
     */
    public int deleteAuthById(Long authId);

    /**
     * 批量删除实名认证
     *
     * @param authIds 需要删除的认证ID
     * @return 结果
     */
    public int deleteAuthByIds(Long[] authIds);
}