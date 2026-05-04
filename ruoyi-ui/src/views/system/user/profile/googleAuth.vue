<template>
  <div class="google-auth-wrap">
    <el-alert
      v-if="status.enabled"
      title="Google 验证已开启，敏感操作需要输入 6 位动态码。"
      type="success"
      :closable="false"
      show-icon
    />
    <el-alert
      v-else
      title="Google 验证未开启，请先绑定后再执行敏感操作。"
      type="warning"
      :closable="false"
      show-icon
    />

    <div class="actions">
      <el-button type="primary" @click="handleInitBind">发起绑定</el-button>
      <el-button v-if="status.enabled" type="danger" plain @click="handleUnbind">解绑</el-button>
    </div>

    <el-card v-if="bindData.secret" class="bind-card" shadow="never">
      <div v-if="bindData.qrImageBase64" class="qr-wrap">
        <img :src="'data:image/png;base64,' + bindData.qrImageBase64" alt="Google 绑定二维码" class="qr-image" />
        <div class="qr-tip">请使用 Google Authenticator 扫码绑定</div>
      </div>
      <div class="row"><span class="label">手动密钥：</span><span class="value">{{ bindData.secret }}</span></div>
      <div class="row"><span class="label">otpauth：</span><span class="value break">{{ bindData.otpAuthUrl }}</span></div>
      <el-input
        v-model="bindCode"
        maxlength="6"
        placeholder="请输入 Google Authenticator 的 6 位验证码"
        style="margin-top: 12px; width: 320px"
      />
      <div style="margin-top: 12px">
        <el-button type="primary" @click="confirmBind">确认绑定</el-button>
      </div>
    </el-card>
  </div>
</template>

<script>
import { bindGoogle2fa, getGoogle2faStatus, initGoogle2fa, unbindGoogle2fa } from '@/api/system/user'

export default {
  name: 'GoogleAuth',
  data() {
    return {
      status: {
        enabled: false
      },
      bindData: {},
      bindCode: ''
    }
  },
  created() {
    this.loadStatus()
  },
  methods: {
    loadStatus() {
      getGoogle2faStatus().then((res) => {
        this.status = res.data || { enabled: false }
      })
    },
    handleInitBind() {
      initGoogle2fa().then((res) => {
        this.bindData = res.data || {}
        this.bindCode = ''
        this.$modal.msgSuccess('已生成绑定信息，请在 Google Authenticator 中添加后输入验证码确认')
      })
    },
    confirmBind() {
      if (!/^\d{6}$/.test(this.bindCode)) {
        this.$modal.msgError('请输入 6 位数字验证码')
        return
      }
      bindGoogle2fa(this.bindCode).then(() => {
        this.$modal.msgSuccess('绑定成功')
        this.bindData = {}
        this.bindCode = ''
        this.loadStatus()
      })
    },
    handleUnbind() {
      this.$prompt('请输入 Google 验证码后确认解绑', '确认解绑', {
        confirmButtonText: '确认',
        cancelButtonText: '取消',
        inputPattern: /^\d{6}$/,
        inputErrorMessage: '请输入 6 位数字验证码'
      }).then(({ value }) => {
        return unbindGoogle2fa(value)
      }).then(() => {
        this.$modal.msgSuccess('解绑成功')
        this.bindData = {}
        this.bindCode = ''
        this.loadStatus()
      }).catch(() => {})
    }
  }
}
</script>

<style scoped>
.google-auth-wrap {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.actions {
  display: flex;
  gap: 12px;
}

.bind-card {
  border: 1px dashed #dcdfe6;
}

.qr-wrap {
  margin-bottom: 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.qr-image {
  width: 220px;
  height: 220px;
  object-fit: contain;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  padding: 8px;
  background: #fff;
}

.qr-tip {
  margin-top: 8px;
  color: #909399;
  font-size: 12px;
}

.row {
  margin-bottom: 8px;
  line-height: 1.6;
}

.label {
  font-weight: 600;
}

.value {
  color: #606266;
}

.break {
  word-break: break-all;
}
</style>
