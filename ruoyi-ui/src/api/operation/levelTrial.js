import request from '@/utils/request'

export function listLevelTrial(query) {
  return request({
    url: '/system/invest/trial/list',
    method: 'get',
    params: query
  })
}

export function getLevelTrial(trialId) {
  return request({
    url: '/system/invest/trial/' + trialId,
    method: 'get'
  })
}

export function addLevelTrial(data) {
  return request({
    url: '/system/invest/trial',
    method: 'post',
    data
  })
}

export function updateLevelTrial(data) {
  return request({
    url: '/system/invest/trial',
    method: 'put',
    data
  })
}

export function delLevelTrial(trialId) {
  return request({
    url: '/system/invest/trial/' + trialId,
    method: 'delete'
  })
}

export function grantLevelTrial(data) {
  return request({
    url: '/system/invest/trial/grant',
    method: 'post',
    data
  })
}
