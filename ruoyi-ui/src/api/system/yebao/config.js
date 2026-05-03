import request from '@/utils/request'

export function listYebaoConfig(query) {
  return request({
    url: '/system/yebao/config/list',
    method: 'get',
    params: query
  })
}

export function getYebaoConfig(configId) {
  return request({
    url: '/system/yebao/config/' + configId,
    method: 'get'
  })
}

export function addYebaoConfig(data) {
  return request({
    url: '/system/yebao/config',
    method: 'post',
    data
  })
}

export function updateYebaoConfig(data) {
  return request({
    url: '/system/yebao/config',
    method: 'put',
    data
  })
}

export function delYebaoConfig(configId) {
  return request({
    url: '/system/yebao/config/' + configId,
    method: 'delete'
  })
}
