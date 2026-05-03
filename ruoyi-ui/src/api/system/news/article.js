import request from '@/utils/request'

export function listNewsArticle(query) {
  return request({
    url: '/system/news/article/list',
    method: 'get',
    params: query
  })
}

export function getNewsArticle(articleId) {
  return request({
    url: '/system/news/article/' + articleId,
    method: 'get'
  })
}

export function addNewsArticle(data) {
  return request({
    url: '/system/news/article',
    method: 'post',
    data
  })
}

export function updateNewsArticle(data) {
  return request({
    url: '/system/news/article',
    method: 'put',
    data
  })
}

export function delNewsArticle(articleId) {
  return request({
    url: '/system/news/article/' + articleId,
    method: 'delete'
  })
}
