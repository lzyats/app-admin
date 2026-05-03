package com.ruoyi.system.service;

import com.ruoyi.common.core.domain.entity.SysUser;

/**
 * 成长值 业务层
 * 
 * @author ruoyi
 */
public interface ISysGrowthValueService {

    /**
     * 增加用户成长值
     *
     * @param userId 用户ID
     * @param growthValue 增加的成长值
     * @param sourceType 来源类型 (e.g., invest, activity, reward, manual)
     * @param sourceId 来源ID
     * @param sourceNo 来源单号
     * @param remark 备注
     * @return 是否成功
     */
    boolean increaseGrowthValue(Long userId, Long growthValue, String sourceType, Long sourceId, String sourceNo, String remark);

    /**
     * 扣除用户成长值
     *
     * @param userId 用户ID
     * @param growthValue 扣除的成长值
     * @param sourceType 来源类型 (e.g., manual)
     * @param sourceId 来源ID
     * @param sourceNo 来源单号
     * @param remark 备注
     * @return 是否成功
     */
    boolean decreaseGrowthValue(Long userId, Long growthValue, String sourceType, Long sourceId, String sourceNo, String remark);

    /**
     * 检查并升级用户会员等级
     *
     * @param userId 用户ID
     * @param currentGrowthValue 用户当前成长值
     * @return 是否升级成功
     */
    boolean checkAndUpgradeUserLevel(Long userId, Long currentGrowthValue);
}
