import request from '@/utils/request'

export function listRecharge(query) {
  return request({
    url: '/system/recharge/list',
    method: 'get',
    params: query
  })
}

export function getRecharge(rechargeId) {
  return request({
    url: `/system/recharge/${rechargeId}`,
    method: 'get'
  })
}

export function reviewRecharge(data) {
  return request({
    url: '/system/recharge',
    method: 'put',
    data
  })
}

export function deleteRecharge(rechargeId) {
  return request({
    url: `/system/recharge/${rechargeId}`,
    method: 'delete'
  })
}
