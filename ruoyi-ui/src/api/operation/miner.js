import request from '@/utils/request'

export function listMiner(query) {
  return request({
    url: '/system/miner/list',
    method: 'get',
    params: query
  })
}

export function getMiner(minerId) {
  return request({
    url: '/system/miner/' + minerId,
    method: 'get'
  })
}

export function addMiner(data) {
  return request({
    url: '/system/miner',
    method: 'post',
    data
  })
}

export function updateMiner(data) {
  return request({
    url: '/system/miner',
    method: 'put',
    data
  })
}

export function delMiner(minerId) {
  return request({
    url: '/system/miner/' + minerId,
    method: 'delete'
  })
}

