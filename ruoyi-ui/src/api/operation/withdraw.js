import request from '@/utils/request'

export function listWithdraw(query) {
  return request({
    url: '/system/withdraw/list',
    method: 'get',
    params: query
  })
}

export function getWithdraw(withdrawId) {
  return request({
    url: `/system/withdraw/${withdrawId}`,
    method: 'get'
  })
}

export function reviewWithdraw(data) {
  return request({
    url: '/system/withdraw',
    method: 'put',
    data
  })
}

export function deleteWithdraw(withdrawId) {
  return request({
    url: `/system/withdraw/${withdrawId}`,
    method: 'delete'
  })
}
