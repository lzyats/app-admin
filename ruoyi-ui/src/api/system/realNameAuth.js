import request from '@/utils/request'

export function listRealNameAuth(query) {
  return request({
    url: '/system/realNameAuth/list',
    method: 'get',
    params: query
  })
}

export function getRealNameAuth(authId) {
  return request({
    url: '/system/realNameAuth/' + authId,
    method: 'get'
  })
}

export function updateRealNameAuth(data) {
  return request({
    url: '/system/realNameAuth',
    method: 'put',
    data: data
  })
}

export function delRealNameAuth(authId) {
  return request({
    url: '/system/realNameAuth/' + authId,
    method: 'delete'
  })
}