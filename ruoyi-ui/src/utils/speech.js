/**
 * 语音播报工具类
 * 使用浏览器原生 SpeechSynthesis API
 */

/**
 * 播报文本
 * @param {string} text 要播报的文本
 * @param {string} lang 语言代码，默认中文
 */
export function speakText(text, lang = 'zh-CN') {
  if (!window.speechSynthesis) {
    console.warn('当前浏览器不支持语音播报功能')
    return
  }

  // 取消之前的播报
  window.speechSynthesis.cancel()

  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = lang
  utterance.volume = 1
  utterance.rate = 1
  utterance.pitch = 1

  // 尝试使用中文语音
  const voices = window.speechSynthesis.getVoices()
  const chineseVoice = voices.find(v => v.lang.includes('zh') || v.lang.includes('CN'))
  if (chineseVoice) {
    utterance.voice = chineseVoice
  }

  window.speechSynthesis.speak(utterance)
}

/**
 * 播报业务提醒
 * @param {string} title 提醒标题
 * @param {string} content 提醒内容
 */
export function speakBusinessNotice(title, content) {
  const message = `您有新的后台业务提醒：${title}。${content}`
  speakText(message)
}

export default {
  speakText,
  speakBusinessNotice
}
