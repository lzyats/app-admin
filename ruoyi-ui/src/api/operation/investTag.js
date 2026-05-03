import request from '@/utils/request'

export function listInvestTag(query) {
  return request({
    url: '/system/invest/tag/list',
    method: 'get',
    params: query
  })
}

export function getInvestTag(tagId) {
  return request({
    url: '/system/invest/tag/' + tagId,
    method: 'get'
  })
}

export function addInvestTag(data) {
  return request({
    url: '/system/invest/tag',
    method: 'post',
    data
  })
}

export function updateInvestTag(data) {
  return request({
    url: '/system/invest/tag',
    method: 'put',
    data
  })
}

export function delInvestTag(tagId) {
  return request({
    url: '/system/invest/tag/' + tagId,
    method: 'delete'
  })
}
