import request from '@/utils/request'

export function listCouponTemplate(query) {
  return request({
    url: '/system/invest/coupon/list',
    method: 'get',
    params: query
  })
}

export function getCouponTemplate(couponId) {
  return request({
    url: '/system/invest/coupon/' + couponId,
    method: 'get'
  })
}

export function addCouponTemplate(data) {
  return request({
    url: '/system/invest/coupon',
    method: 'post',
    data
  })
}

export function updateCouponTemplate(data) {
  return request({
    url: '/system/invest/coupon',
    method: 'put',
    data
  })
}

export function delCouponTemplate(couponId) {
  return request({
    url: '/system/invest/coupon/' + couponId,
    method: 'delete'
  })
}

export function grantCoupon(data) {
  return request({
    url: '/system/invest/coupon/grant',
    method: 'post',
    data
  })
}
