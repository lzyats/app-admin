import {
  addNewsArticle,
  delNewsArticle,
  getNewsArticle,
  listNewsArticle,
  updateNewsArticle
} from '@/api/system/news/article'

export function listAppAd(query) {
  return listNewsArticle(query)
}

export function getAppAd(articleId) {
  return getNewsArticle(articleId)
}

export function addAppAd(data) {
  return addNewsArticle(data)
}

export function updateAppAd(data) {
  return updateNewsArticle(data)
}

export function delAppAd(articleId) {
  return delNewsArticle(articleId)
}
