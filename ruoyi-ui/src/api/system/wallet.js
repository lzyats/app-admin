import request from '@/utils/request'

// 查询钱包列表
export function listWallet(query) {
  return request({
    url: '/system/wallet/list',
    method: 'get',
    params: query
  })
}

// 根据用户ID查询钱包
export function getWalletByUserId(userId, currencyType) {
  return request({
    url: `/system/wallet/user/${userId}`,
    method: 'get',
    params: currencyType ? { currencyType } : {}
  })
}

export function getWalletByUserIdAndCurrencyType(userId, currencyType) {
  return request({
    url: `/system/wallet/user/${userId}`,
    method: 'get',
    params: { currencyType }
  })
}

// 新增钱包
export function addWallet(data) {
  return request({
    url: '/system/wallet',
    method: 'post',
    data: data
  })
}

// 修改钱包
export function updateWallet(data) {
  return request({
    url: '/system/wallet',
    method: 'put',
    data: data
  })
}

export function adjustWallet(data) {
  return request({
    url: '/system/wallet/adjust',
    method: 'post',
    data
  })
}

// 删除钱包
export function deleteWallet(walletId) {
  return request({
    url: `/system/wallet/${walletId}`,
    method: 'delete'
  })
}

// 批量删除钱包
export function deleteWalletByIds(walletIds) {
  return request({
    url: '/system/wallet/batch',
    method: 'delete',
    data: walletIds
  })
}

// 查询钱包流水列表
export function listWalletLog(query) {
  return request({
    url: '/system/wallet/log/list',
    method: 'get',
    params: query
  })
}

// 根据用户ID查询钱包流水
export function getWalletLogsByUserId(userId) {
  return request({
    url: `/system/wallet/log/user/${userId}`,
    method: 'get'
  })
}

// 新增钱包流水
export function addWalletLog(data) {
  return request({
    url: '/system/wallet/log',
    method: 'post',
    data: data
  })
}

// 修改钱包流水
export function updateWalletLog(data) {
  return request({
    url: '/system/wallet/log',
    method: 'put',
    data: data
  })
}

// 删除钱包流水
export function deleteWalletLog(logId) {
  return request({
    url: `/system/wallet/log/${logId}`,
    method: 'delete'
  })
}

// 批量删除钱包流水
export function deleteWalletLogByIds(logIds) {
  return request({
    url: '/system/wallet/log/batch',
    method: 'delete',
    data: logIds
  })
}
