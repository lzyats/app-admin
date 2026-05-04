import request from '@/utils/request'

export function listYebaoOrder(query) {
  return request({
    url: '/system/invest/order/list',
    method: 'get',
    params: query
  })
}

export function getYebaoOrder(orderId) {
  return request({
    url: '/system/invest/order/' + orderId,
    method: 'get'
  })
}

export function getYebaoOrderDetail(orderId) {
  return request({
    url: '/system/invest/order/detail/' + orderId,
    method: 'get'
  })
}

export function redeemInvestOrder(data) {
  return request({
    url: '/system/invest/order/redeem',
    method: 'post',
    data
  })
}

export function settleInvestOrder(data) {
  return request({
    url: '/system/invest/order/settle',
    method: 'post',
    data
  })
}
