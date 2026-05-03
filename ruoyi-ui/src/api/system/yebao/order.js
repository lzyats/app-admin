import request from '@/utils/request'

export function listYebaoOrder(query) {
  return request({
    url: '/system/yebao/order/list',
    method: 'get',
    params: query
  })
}

export function getYebaoOrder(orderId) {
  return request({
    url: '/system/yebao/order/' + orderId,
    method: 'get'
  })
}
