import request from '@/utils/request'

export function listGrowthLog(query) {
  return request({
    url: '/system/growth/log/list',
    method: 'get',
    params: query
  })
}

export function increaseGrowthValue(data) {
  return request({
    url: '/system/growth/increase',
    method: 'post',
    data
  })
}

export function decreaseGrowthValue(data) {
  return request({
    url: '/system/growth/decrease',
    method: 'post',
    data
  })
}
