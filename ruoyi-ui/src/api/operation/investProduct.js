import request from '@/utils/request'

export function listInvestProduct(query) {
  return request({
    url: '/system/invest/product/list',
    method: 'get',
    params: query
  })
}

export function getInvestProduct(productId) {
  return request({
    url: '/system/invest/product/' + productId,
    method: 'get'
  })
}

export function addInvestProduct(data) {
  return request({
    url: '/system/invest/product',
    method: 'post',
    data
  })
}

export function updateInvestProduct(data) {
  return request({
    url: '/system/invest/product',
    method: 'put',
    data
  })
}

export function delInvestProduct(productId) {
  return request({
    url: '/system/invest/product/' + productId,
    method: 'delete'
  })
}

export function listInvestTag(query) {
  return request({
    url: '/system/invest/tag/list',
    method: 'get',
    params: query
  })
}
