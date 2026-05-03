import request from '@/utils/request'

export function listUserLevel(query) {
  return request({
    url: '/system/userLevel/list',
    method: 'get',
    params: query
  })
}

export function getUserLevel(levelId) {
  return request({
    url: '/system/userLevel/' + levelId,
    method: 'get'
  })
}

export function addUserLevel(data) {
  return request({
    url: '/system/userLevel',
    method: 'post',
    data
  })
}

export function updateUserLevel(data) {
  return request({
    url: '/system/userLevel',
    method: 'put',
    data
  })
}

export function delUserLevel(levelId) {
  return request({
    url: '/system/userLevel/' + levelId,
    method: 'delete'
  })
}

export function listUserLevelOptions() {
  return request({
    url: '/system/userLevel/options',
    method: 'get'
  })
}
