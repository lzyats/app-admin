import request from '@/utils/request'

export function listTeamStats(query) {
  return request({
    url: '/system/teamStats/list',
    method: 'get',
    params: query
  })
}

export function listTeamStatEvents(query) {
  return request({
    url: '/system/teamStats/event/list',
    method: 'get',
    params: query
  })
}

export function getTeamStatsConfig() {
  return request({
    url: '/system/teamStats/config',
    method: 'get'
  })
}

export function rebuildTeamStats(statDate) {
  return request({
    url: '/system/teamStats/rebuild',
    method: 'post',
    params: { statDate }
  })
}
