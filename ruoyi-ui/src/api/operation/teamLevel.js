import request from '@/utils/request'

export function listTeamLevel(query) {
  return request({
    url: '/system/teamLevel/list',
    method: 'get',
    params: query
  })
}

export function getTeamLevel(teamLevelId) {
  return request({
    url: '/system/teamLevel/' + teamLevelId,
    method: 'get'
  })
}

export function addTeamLevel(data) {
  return request({
    url: '/system/teamLevel',
    method: 'post',
    data
  })
}

export function updateTeamLevel(data) {
  return request({
    url: '/system/teamLevel',
    method: 'put',
    data
  })
}

export function delTeamLevel(teamLevelId) {
  return request({
    url: '/system/teamLevel/' + teamLevelId,
    method: 'delete'
  })
}

export function checkTeamUpgrade(userId) {
  return request({
    url: '/system/teamLevel/checkUpgrade',
    method: 'post',
    params: { userId }
  })
}
