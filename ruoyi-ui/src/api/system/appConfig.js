import request from '@/utils/request'
import { listConfig, addConfig, updateConfig, refreshCache } from '@/api/system/config'

export function getAppConfigRecords(query = {}) {
  return listConfig({
    pageNum: 1,
    pageSize: 1000,
    isAppConfig: '1',
    ...query
  })
}

export function getAppConfigOptions() {
  return request({
    url: '/app/config/options',
    method: 'get',
    headers: {
      isToken: false
    }
  })
}

export function getConfigRecordByKey(configKey) {
  return listConfig({ pageNum: 1, pageSize: 1, configKey })
}

export function saveConfigByKey({ configId, configName, configKey, configValue, remark }) {
  const payload = {
    configId,
    configName,
    configKey,
    configValue,
    configType: 'N',
    remark
  }
  if (configId) {
    return updateConfig(payload)
  }
  return addConfig(payload)
}

export function saveAppConfig(data) {
  return request({
    url: '/app/config/save',
    method: 'post',
    data
  })
}

export function refreshConfigCache() {
  return refreshCache()
}
