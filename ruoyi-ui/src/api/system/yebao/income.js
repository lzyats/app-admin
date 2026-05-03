import request from '@/utils/request'

export function listYebaoIncome(query) {
  return request({
    url: '/system/yebao/income/list',
    method: 'get',
    params: query
  })
}

export function getYebaoIncome(incomeId) {
  return request({
    url: '/system/yebao/income/' + incomeId,
    method: 'get'
  })
}
