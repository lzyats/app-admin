package com.ruoyi.system.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.SysUserBankCard;

public interface SysUserBankCardMapper
{
    SysUserBankCard selectBankCardById(Long bankCardId);

    List<SysUserBankCard> selectBankCardList(SysUserBankCard bankCard);

    int countBankCardByUserIdAndCurrencyType(@Param("userId") Long userId, @Param("currencyType") String currencyType);

    int insertBankCard(SysUserBankCard bankCard);

    int deleteBankCardById(Long bankCardId);

    int deleteBankCardByIds(Long[] bankCardIds);
}
