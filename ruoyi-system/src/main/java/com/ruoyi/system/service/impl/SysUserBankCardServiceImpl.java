package com.ruoyi.system.service.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.constant.CacheConstants;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.core.text.Convert;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.SysUserBankCard;
import com.ruoyi.system.mapper.SysUserBankCardMapper;
import com.ruoyi.system.service.ISysConfigService;
import com.ruoyi.system.service.ISysUserBankCardService;
import com.ruoyi.system.service.ISysUserService;

/**
 * User bank card service implementation.
 */
@Service
public class SysUserBankCardServiceImpl implements ISysUserBankCardService
{
    private static final int REAL_NAME_APPROVED = 3;
    private static final int MAX_CARD_PER_CURRENCY = 2;

    @Autowired
    private SysUserBankCardMapper bankCardMapper;

    @Autowired
    private RedisCache redisCache;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private ISysUserService userService;

    @Override
    public SysUserBankCard selectBankCardById(Long bankCardId)
    {
        if (bankCardId == null)
        {
            return null;
        }
        String cacheKey = getBankCardIdCacheKey(bankCardId);
        try
        {
            String cached = redisCache.getCacheObject(cacheKey);
            if (StringUtils.isNotBlank(cached))
            {
                return JSON.parseObject(cached, SysUserBankCard.class);
            }
        }
        catch (Exception e)
        {
            // 忽略缓存异常，回源数据库
        }

        SysUserBankCard bankCard = bankCardMapper.selectBankCardById(bankCardId);
        if (bankCard != null)
        {
            try
            {
                redisCache.setCacheObject(cacheKey, JSON.toJSONString(bankCard));
            }
            catch (Exception e)
            {
                // 忽略缓存写入失败
            }
        }
        return bankCard;
    }

    @Override
    public List<SysUserBankCard> selectBankCardList(SysUserBankCard bankCard)
    {
        if (bankCard != null && bankCard.getUserId() != null && bankCard.getUserId() > 0)
        {
            String cacheKey = getBankCardListCacheKey(bankCard);
            try
            {
                String cached = redisCache.getCacheObject(cacheKey);
                if (StringUtils.isNotBlank(cached))
                {
                    return JSON.parseArray(cached, SysUserBankCard.class);
                }
            }
            catch (Exception e)
            {
                // 忽略缓存异常，回源数据库
            }

            List<SysUserBankCard> list = bankCardMapper.selectBankCardList(bankCard);
            try
            {
                redisCache.setCacheObject(cacheKey, JSON.toJSONString(list == null ? new ArrayList<>() : list));
            }
            catch (Exception e)
            {
                // 忽略缓存写入失败
            }
            return list;
        }

        return bankCardMapper.selectBankCardList(bankCard);
    }

    @Override
    public int selectBankCardCountByUserIdAndCurrencyType(Long userId, String currencyType)
    {
        String normalizedCurrency = normalizeCurrencyType(currencyType);
        String cacheKey = getBankCardCountCacheKey(userId, normalizedCurrency);
        try
        {
            String cached = redisCache.getCacheObject(cacheKey);
            if (StringUtils.isNotBlank(cached))
            {
                return Integer.parseInt(cached);
            }
        }
        catch (Exception e)
        {
            // 忽略缓存异常，回源数据库
        }

        int count = bankCardMapper.countBankCardByUserIdAndCurrencyType(userId, normalizedCurrency);
        try
        {
            redisCache.setCacheObject(cacheKey, String.valueOf(count));
        }
        catch (Exception e)
        {
            // 忽略缓存写入失败
        }
        return count;
    }

    @Override
    @Transactional
    public int insertBankCard(SysUserBankCard bankCard)
    {
        normalizeBankCard(bankCard);
        int existingCount = bankCardMapper.countBankCardByUserIdAndCurrencyType(bankCard.getUserId(), bankCard.getCurrencyType());
        if (existingCount >= MAX_CARD_PER_CURRENCY)
        {
            throw new ServiceException("Each currency can bind up to 2 cards.");
        }
        bankCard.setCreateTime(new Date());
        bankCard.setUpdateTime(new Date());
        int row = bankCardMapper.insertBankCard(bankCard);
        if (row > 0)
        {
            resetBankCardCache();
        }
        return row;
    }

    @Override
    public int deleteBankCardById(Long bankCardId)
    {
        int row = bankCardMapper.deleteBankCardById(bankCardId);
        if (row > 0)
        {
            resetBankCardCache();
        }
        return row;
    }

    @Override
    public int deleteBankCardByIds(Long[] bankCardIds)
    {
        int row = bankCardMapper.deleteBankCardByIds(bankCardIds);
        if (row > 0)
        {
            resetBankCardCache();
        }
        return row;
    }

    private void normalizeBankCard(SysUserBankCard bankCard)
    {
        if (bankCard == null)
        {
            throw new ServiceException("Bank card data cannot be empty.");
        }
        if (bankCard.getUserId() == null || bankCard.getUserId() <= 0)
        {
            throw new ServiceException("User ID cannot be empty.");
        }

        int investMode = Convert.toInt(configService.selectConfigByKey("app.currency.investMode"), 1);
        String currencyType = normalizeCurrencyType(bankCard.getCurrencyType());
        if (investMode == 1)
        {
            currencyType = "CNY";
        }
        if ("USD".equals(currencyType) && investMode != 2)
        {
            throw new ServiceException("USD bank cards are available only in dual-currency mode.");
        }
        bankCard.setCurrencyType(currencyType);

        SysUser user = userService.selectUserById(bankCard.getUserId());
        if (user == null)
        {
            throw new ServiceException("User does not exist.");
        }

        if ("CNY".equals(currencyType))
        {
            if (user.getRealNameStatus() == null || user.getRealNameStatus() != REAL_NAME_APPROVED)
            {
                throw new ServiceException("Real-name approval is required before binding an RMB card.");
            }
            bankCard.setBankName(StringUtils.trim(bankCard.getBankName()));
            bankCard.setAccountNo(StringUtils.trim(bankCard.getAccountNo()));
            bankCard.setAccountName(StringUtils.trim(bankCard.getAccountName()));
            if (StringUtils.isBlank(bankCard.getBankName()) || StringUtils.isBlank(bankCard.getAccountNo()) || StringUtils.isBlank(bankCard.getAccountName()))
            {
                throw new ServiceException("Bank name, account number and account name are required for RMB cards.");
            }
            bankCard.setWalletAddress(null);
        }
        else
        {
            bankCard.setWalletAddress(StringUtils.trim(bankCard.getWalletAddress()));
            if (StringUtils.isBlank(bankCard.getWalletAddress()))
            {
                throw new ServiceException("Wallet address is required for USD cards.");
            }
            bankCard.setBankName(null);
            bankCard.setAccountNo(null);
            bankCard.setAccountName(null);
        }
        bankCard.setUserName(StringUtils.trim(bankCard.getUserName()));
        if (StringUtils.isBlank(bankCard.getUserName()))
        {
            bankCard.setUserName(user.getUserName());
        }
    }

    private String normalizeCurrencyType(String currencyType)
    {
        if (StringUtils.isBlank(currencyType))
        {
            return "CNY";
        }
        String normalized = currencyType.trim().toUpperCase();
        return "USD".equals(normalized) ? "USD" : "CNY";
    }

    private void clearBankCardCache()
    {
        try
        {
            Collection<String> keys = redisCache.keys(CacheConstants.BANK_CARD_KEY + "*");
            if (keys != null && !keys.isEmpty())
            {
                redisCache.deleteObject(keys);
            }
        }
        catch (Exception e)
        {
            // 忽略缓存清理异常
        }
    }

    private void resetBankCardCache()
    {
        clearBankCardCache();
    }

    private String getBankCardIdCacheKey(Long bankCardId)
    {
        return CacheConstants.BANK_CARD_KEY + "id:" + bankCardId;
    }

    private String getBankCardCountCacheKey(Long userId, String currencyType)
    {
        return CacheConstants.BANK_CARD_KEY + "count:" + userId + ":" + currencyType;
    }

    private String getBankCardListCacheKey(SysUserBankCard bankCard)
    {
        StringBuilder key = new StringBuilder(CacheConstants.BANK_CARD_KEY).append("list:");
        key.append(bankCard.getUserId()).append(":");
        key.append(StringUtils.defaultString(bankCard.getBankCardId() == null ? null : String.valueOf(bankCard.getBankCardId()))).append(":");
        key.append(StringUtils.defaultString(bankCard.getUserName())).append(":");
        key.append(StringUtils.defaultString(bankCard.getCurrencyType())).append(":");
        key.append(StringUtils.defaultString(bankCard.getBankName())).append(":");
        key.append(StringUtils.defaultString(bankCard.getAccountNo())).append(":");
        key.append(StringUtils.defaultString(bankCard.getAccountName())).append(":");
        key.append(StringUtils.defaultString(bankCard.getWalletAddress()));
        return key.toString();
    }
}
