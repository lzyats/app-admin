package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.SysUserBankCard;

public interface ISysUserBankCardService
{
    SysUserBankCard selectBankCardById(Long bankCardId);

    List<SysUserBankCard> selectBankCardList(SysUserBankCard bankCard);

    int selectBankCardCountByUserIdAndCurrencyType(Long userId, String currencyType);

    int insertBankCard(SysUserBankCard bankCard);

    int deleteBankCardById(Long bankCardId);

    int deleteBankCardByIds(Long[] bankCardIds);
}
