<template>
  <div class="app-container">
    <el-card shadow="never">
      <div slot="header" class="clearfix">
        <span>线路二维码生成</span>
      </div>

      <el-form ref="form" :model="form" :rules="rules" label-width="110px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="线路名称" prop="name">
              <el-input v-model.trim="form.name" placeholder="例如：国内线路一(推荐)" maxlength="50" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="二维码尺寸" prop="size">
              <el-input-number v-model="form.size" :min="200" :max="1200" :step="20" controls-position="right" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="HTTP 地址" prop="httpUrl">
              <el-input v-model.trim="form.httpUrl" placeholder="http://43.139.165.6:6666" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="WS 地址" prop="wsUrl">
              <el-input v-model.trim="form.wsUrl" placeholder="ws://43.139.165.6:7777" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item>
          <el-button
            type="primary"
            icon="el-icon-magic-stick"
            :loading="loading"
            @click="handleGenerate"
          >一键生成</el-button>
          <el-button
            type="success"
            icon="el-icon-download"
            :disabled="!qrDataUrl"
            @click="handleDownload"
          >下载二维码图片</el-button>
          <el-button icon="el-icon-refresh-left" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card v-if="qrDataUrl" class="result-card" shadow="never">
      <div slot="header" class="clearfix">
        <span>生成结果</span>
      </div>
      <el-row :gutter="20">
        <el-col :span="8">
          <div class="qr-preview-wrap">
            <img :src="qrDataUrl" alt="线路二维码" class="qr-image" />
          </div>
        </el-col>
        <el-col :span="16">
          <el-form label-width="110px">
            <el-form-item label="加密字符串">
              <el-input type="textarea" :rows="6" v-model="encryptedText" readonly />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" plain icon="el-icon-document-copy" @click="copyEncryptedText">复制加密字符串</el-button>
            </el-form-item>
          </el-form>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script>
import { generateLineQr } from '@/api/tool/lineQr'

export default {
  name: 'LineQr',
  data() {
    return {
      loading: false,
      form: {
        name: '',
        httpUrl: '',
        wsUrl: '',
        size: 360
      },
      rules: {
        name: [{ required: true, message: '请输入线路名称', trigger: 'blur' }],
        httpUrl: [
          { required: true, message: '请输入 HTTP 地址', trigger: 'blur' },
          { type: 'url', message: 'HTTP 地址格式不正确', trigger: 'blur' }
        ],
        wsUrl: [
          { required: true, message: '请输入 WS 地址', trigger: 'blur' },
          { validator: (rule, value, callback) => this.validateWsUrl(value, callback), trigger: 'blur' }
        ]
      },
      encryptedText: '',
      qrDataUrl: ''
    }
  },
  methods: {
    validateWsUrl(value, callback) {
      if (!value) {
        callback(new Error('请输入 WS 地址'))
        return
      }
      if (!(value.startsWith('ws://') || value.startsWith('wss://'))) {
        callback(new Error('WS 地址必须以 ws:// 或 wss:// 开头'))
        return
      }
      callback()
    },
    handleGenerate() {
      this.$refs.form.validate(valid => {
        if (!valid) {
          return
        }
        this.loading = true
        generateLineQr(this.form).then(res => {
          const data = (res && res.data) || {}
          if (!data.qrImageBase64) {
            this.$modal.msgError('未返回二维码图片数据')
            return
          }
          this.encryptedText = data.encryptedText || ''
          this.qrDataUrl = 'data:image/png;base64,' + data.qrImageBase64
          this.$modal.msgSuccess('二维码生成成功')
        }).finally(() => {
          this.loading = false
        })
      })
    },
    handleDownload() {
      if (!this.qrDataUrl) {
        this.$modal.msgWarning('请先生成二维码')
        return
      }
      const safeName = (this.form.name || 'line_qr').replace(/[\\\\/:*?\"<>|\\s]+/g, '_')
      const filename = safeName + '.png'
      const link = document.createElement('a')
      link.href = this.qrDataUrl
      link.download = filename
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
    },
    copyEncryptedText() {
      if (!this.encryptedText) {
        this.$modal.msgWarning('当前无可复制内容')
        return
      }
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(this.encryptedText).then(() => {
          this.$modal.msgSuccess('复制成功')
        }).catch(() => {
          this.$modal.msgError('复制失败，请手动复制')
        })
        return
      }
      this.$modal.msgWarning('当前浏览器不支持自动复制，请手动复制')
    },
    handleReset() {
      this.resetForm('form')
      this.form.size = 360
      this.encryptedText = ''
      this.qrDataUrl = ''
    }
  }
}
</script>

<style lang="scss" scoped>
.result-card {
  margin-top: 16px;
}

.qr-preview-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 320px;
  border: 1px dashed #dcdfe6;
  border-radius: 8px;
  background: #fff;
}

.qr-image {
  width: 280px;
  height: 280px;
  object-fit: contain;
}
</style>
