import request from '@/utils/request'

export function listNewsCategory(query) {
  return request({
    url: '/system/news/category/list',
    method: 'get',
    params: query
  })
}

export function listNewsCategoryAll() {
  return request({
    url: '/system/news/category/listAll',
    method: 'get'
  })
}

export function getNewsCategory(categoryId) {
  return request({
    url: '/system/news/category/' + categoryId,
    method: 'get'
  })
}

export function addNewsCategory(data) {
  return request({
    url: '/system/news/category',
    method: 'post',
    data
  })
}

export function updateNewsCategory(data) {
  return request({
    url: '/system/news/category',
    method: 'put',
    data
  })
}

export function delNewsCategory(categoryId) {
  return request({
    url: '/system/news/category/' + categoryId,
    method: 'delete'
  })
}
