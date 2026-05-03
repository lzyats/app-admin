package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysYebaoConfig;

public interface ISysYebaoConfigService
{
    List<SysYebaoConfig> selectYebaoConfigList(SysYebaoConfig config);

    List<SysYebaoConfig> selectYebaoConfigAll();

    SysYebaoConfig selectYebaoConfigById(Long configId);

    SysYebaoConfig selectCurrentYebaoConfig();

    int insertYebaoConfig(SysYebaoConfig config);

    int updateYebaoConfig(SysYebaoConfig config);

    int deleteYebaoConfigById(Long configId);

    int deleteYebaoConfigByIds(Long[] configIds);
}
