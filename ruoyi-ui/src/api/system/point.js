import request from '@/utils/request'

export function listPointAccount(query) {
  return request({
    url: '/system/point/account/list',
    method: 'get',
    params: query
  })
}

export function getPointAccount(pointAccountId) {
  return request({
    url: `/system/point/account/${pointAccountId}`,
    method: 'get'
  })
}

export function addPointAccount(data) {
  return request({
    url: '/system/point/account',
    method: 'post',
    data
  })
}

export function updatePointAccount(data) {
  return request({
    url: '/system/point/account',
    method: 'put',
    data
  })
}

export function deletePointAccount(pointAccountId) {
  return request({
    url: `/system/point/account/${pointAccountId}`,
    method: 'delete'
  })
}

export function deletePointAccountByIds(pointAccountIds) {
  return request({
    url: `/system/point/account/${pointAccountIds}`,
    method: 'delete'
  })
}

export function grantPoints(data) {
  return request({
    url: '/system/point/account/grant',
    method: 'post',
    data
  })
}

export function deductPoints(data) {
  return request({
    url: '/system/point/account/deduct',
    method: 'post',
    data
  })
}

export function listPointLog(query) {
  return request({
    url: '/system/point/log/list',
    method: 'get',
    params: query
  })
}

export function getPointLog(logId) {
  return request({
    url: `/system/point/log/${logId}`,
    method: 'get'
  })
}

export function updatePointLog(data) {
  return request({
    url: '/system/point/log',
    method: 'put',
    data
  })
}

export function deletePointLog(logId) {
  return request({
    url: `/system/point/log/${logId}`,
    method: 'delete'
  })
}

export function deletePointLogByIds(logIds) {
  return request({
    url: `/system/point/log/${logIds}`,
    method: 'delete'
  })
}
