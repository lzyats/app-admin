import request from '@/utils/request'

export function listBankCard(query) {
  return request({
    url: '/system/bankCard/list',
    method: 'get',
    params: query
  })
}

export function getBankCard(bankCardId) {
  return request({
    url: `/system/bankCard/${bankCardId}`,
    method: 'get'
  })
}

export function deleteBankCard(bankCardId) {
  return request({
    url: `/system/bankCard/${bankCardId}`,
    method: 'delete'
  })
}
