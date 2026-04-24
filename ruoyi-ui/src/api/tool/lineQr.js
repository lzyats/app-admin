import request from '@/utils/request'

// 生成线路加密二维码
export function generateLineQr(data) {
  return request({
    url: '/tool/line/qr/generate',
    method: 'post',
    data: data
  })
}

