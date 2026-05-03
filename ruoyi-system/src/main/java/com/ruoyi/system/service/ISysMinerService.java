package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysMiner;

public interface ISysMinerService
{
    SysMiner selectMinerById(Long minerId);

    List<SysMiner> selectMinerList(SysMiner miner);

    int insertMiner(SysMiner miner);

    int updateMiner(SysMiner miner);

    int deleteMinerByIds(Long[] minerIds);
}

