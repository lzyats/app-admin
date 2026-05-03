package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.SysMiner;

public interface SysMinerMapper
{
    SysMiner selectMinerById(Long minerId);

    List<SysMiner> selectMinerList(SysMiner miner);

    int insertMiner(SysMiner miner);

    int updateMiner(SysMiner miner);

    int deleteMinerById(Long minerId);

    int deleteMinerByIds(Long[] minerIds);
}

