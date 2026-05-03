package com.ruoyi.system.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysYebaoConfig;

public interface SysYebaoConfigMapper
{
    List<SysYebaoConfig> selectYebaoConfigList(SysYebaoConfig config);

    List<SysYebaoConfig> selectYebaoConfigAll();

    SysYebaoConfig selectYebaoConfigById(@Param("configId") Long configId);

    SysYebaoConfig selectCurrentYebaoConfig();

    int insertYebaoConfig(SysYebaoConfig config);

    int updateYebaoConfig(SysYebaoConfig config);

    int deleteYebaoConfigById(@Param("configId") Long configId);

    int deleteYebaoConfigByIds(Long[] configIds);
}
