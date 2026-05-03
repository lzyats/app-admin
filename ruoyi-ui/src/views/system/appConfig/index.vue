<template>
  <div class="app-container">
    <el-card>
      <template slot="header">
        <div class="card-header">
          <span>APP 配置管理</span>
          <div class="header-actions">
            <el-button type="primary" icon="el-icon-check" :loading="saving" @click="handleSave">保存</el-button>
            <el-button icon="el-icon-refresh" :loading="loading" @click="loadAll">刷新</el-button>
          </div>
        </div>
      </template>

      <el-alert
        title="直接读取数据库中已勾选“是否APP配置”的参数，JSON、数字、文本都会按参数表原值展示和保存。"
        type="info"
        :closable="false"
        show-icon
      />

      <el-divider>配置项</el-divider>

      <template v-if="optionGroups.length > 0">
        <el-card
          v-for="group in optionGroups"
          :key="group.key"
          shadow="never"
          class="group-card"
        >
          <div slot="header" class="group-card-header">
            <span>{{ group.label }}</span>
            <span class="group-card-count">{{ group.items.length }} 项</span>
          </div>
          <el-table v-loading="loading" :data="group.items" border>
            <el-table-column label="显示名称" prop="name" min-width="180" />
            <el-table-column label="配置键" prop="configKey" min-width="240" />
            <el-table-column label="数据库值" min-width="200">
              <template slot-scope="scope">
                <template v-if="scope.row.valueType === 'bool'">
                  <el-tag :type="scope.row.currentValue ? 'success' : 'info'">
                    {{ scope.row.currentValue ? '开启' : '关闭' }}
                  </el-tag>
                </template>
                <template v-else>
                  <span class="value-text">{{ scope.row.configValueText }}</span>
                </template>
              </template>
            </el-table-column>
            <el-table-column label="操作" min-width="280">
              <template slot-scope="scope">
                <el-select
                  v-if="scope.row.valueType === 'bool'"
                  v-model="scope.row.currentValue"
                  size="mini"
                  style="width: 160px;"
                >
                  <el-option label="开启" :value="true" />
                  <el-option label="关闭" :value="false" />
                </el-select>
                <el-input-number
                  v-else-if="scope.row.valueType === 'number'"
                  v-model="scope.row.currentValue"
                  :min="0"
                  :precision="2"
                  :controls="false"
                  size="mini"
                  style="width: 140px;"
                />
                <el-select
                  v-else-if="scope.row.item === 'signRewardType'"
                  v-model="scope.row.currentValue"
                  size="mini"
                  style="width: 180px;"
                >
                  <el-option label="积分" value="POINT" />
                  <el-option label="现金" value="MONEY" />
                </el-select>
                <el-select
                  v-else-if="scope.row.item === 'investCurrencyMode'"
                  v-model="scope.row.currentValue"
                  size="mini"
                  style="width: 180px;"
                >
                  <el-option label="1 - 单币种" :value="1" />
                  <el-option label="2 - 双币种" :value="2" />
                </el-select>
                <el-button
                  v-else-if="scope.row.valueType === 'json'"
                  type="primary"
                  plain
                  size="mini"
                  icon="el-icon-edit"
                  @click="openJsonEditor(scope.row)"
                >
                  编辑 JSON
                </el-button>
                <el-input
                  v-else
                  v-model="scope.row.currentValue"
                  size="mini"
                  style="width: 320px;"
                  :placeholder="scope.row.configKey || '请输入内容'"
                />
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </template>

      <el-empty v-else description="暂无 APP 配置，请先在参数管理中勾选“是否APP配置”" />

      <div class="footer-actions">
        <el-button type="primary" icon="el-icon-check" :loading="saving" @click="handleSave">保存</el-button>
        <el-button icon="el-icon-refresh" :loading="loading" @click="loadAll">刷新</el-button>
      </div>
    </el-card>

    <el-dialog
      title="编辑 JSON 配置"
      :visible.sync="jsonDialog.visible"
      width="720px"
      append-to-body
      @close="closeJsonEditor"
    >
      <el-alert
        title="请直接编辑 JSON 原文，保存前会校验格式。"
        type="info"
        :closable="false"
        show-icon
        class="json-alert"
      />
      <el-input
        v-model="jsonDialog.value"
        type="textarea"
        :rows="16"
        placeholder='例如：[{"level":1,"percent":5,"amount":500}]'
      />
      <span slot="footer" class="dialog-footer">
        <el-button @click="closeJsonEditor">取消</el-button>
        <el-button type="primary" @click="confirmJsonEditor">确定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import { getAppConfigRecords, saveAppConfig } from '@/api/system/appConfig'

export default {
  name: 'AppConfigManage',
  data() {
    return {
      loading: false,
      saving: false,
      options: [],
      jsonDialog: {
        visible: false,
        value: '',
        target: null
      }
    }
  },
  computed: {
    optionGroups() {
      const order = ['bool', 'number', 'select', 'json', 'text']
      const labels = {
        bool: '开关类',
        number: '数值类',
        select: '选择类',
        json: 'JSON 配置类',
        text: '文本类'
      }
      const grouped = new Map()
      for (const option of this.options) {
        const type = String(option.valueType || 'text').toLowerCase()
        const key = order.includes(type) ? type : 'text'
        if (!grouped.has(key)) {
          grouped.set(key, [])
        }
        grouped.get(key).push(option)
      }
      return order
        .filter((key) => grouped.has(key))
        .map((key) => ({
          key,
          label: labels[key] || '其他',
          items: grouped.get(key)
        }))
    }
  },
  created() {
    this.loadAll()
  },
  methods: {
    async loadAll() {
      this.loading = true
      try {
        const response = await getAppConfigRecords()
        const records = this.resolveRecordList(response)
        this.options = records
          .map((record) => this.normalizeRecord(record))
          .filter((option) => option !== null)
          .sort((left, right) => Number(left.configId || 0) - Number(right.configId || 0))
      } catch (e) {
        this.options = []
        this.$modal.msgError('读取 APP 配置失败，请检查后台参数管理和权限')
      } finally {
        this.loading = false
      }
    },
    resolveRecordList(response) {
      if (!response) {
        return []
      }
      if (Array.isArray(response)) {
        return response
      }
      if (Array.isArray(response.rows)) {
        return response.rows
      }
      if (response.data && Array.isArray(response.data)) {
        return response.data
      }
      if (response.data && Array.isArray(response.data.rows)) {
        return response.data.rows
      }
      return []
    },
    normalizeRecord(record) {
      if (!record || typeof record !== 'object') {
        return null
      }
      const configKey = String(record.configKey ?? '').trim()
      if (!configKey) {
        return null
      }
      const configValueText = record.configValue === undefined || record.configValue === null
        ? ''
        : String(record.configValue)
      const valueType = this.inferValueType({
        item: configKey,
        configKey,
        defaultValue: configValueText
      }, record.valueType)
      return {
        configId: record.configId,
        item: configKey,
        name: String(record.configName ?? '').trim() || configKey,
        configKey,
        configValueText,
        defaultValue: configValueText,
        valueType,
        currentValue: this.parseValue(configValueText, valueType, configValueText, configKey),
        remark: String(record.remark ?? ''),
        isAppConfig: String(record.isAppConfig ?? '1')
      }
    },
    inferValueType(option, remoteType) {
      const explicitType = String(remoteType ?? '').trim().toLowerCase()
      if (['bool', 'number', 'json', 'select', 'text'].includes(explicitType)) {
        return explicitType
      }
      const item = String(option.item ?? '')
      const raw = option.defaultValue
      if (item === 'signRewardType' || item === 'investCurrencyMode') {
        return 'select'
      }
      if (item === 'inviteRewardRule' || item === 'signContinuousRewardRule') {
        return 'json'
      }
      if (this.looksLikeBool(raw)) {
        return 'bool'
      }
      if (this.looksLikeNumber(raw)) {
        return 'number'
      }
      if (this.looksLikeJson(raw)) {
        return 'json'
      }
      return 'text'
    },
    looksLikeBool(raw) {
      const lowerValue = String(raw ?? '').trim().toLowerCase()
      return ['true', 'false'].includes(lowerValue)
    },
    looksLikeNumber(raw) {
      if (raw === null || raw === undefined || raw === '') {
        return false
      }
      const parsed = Number(raw)
      return Number.isFinite(parsed) && String(raw).trim() !== ''
    },
    looksLikeJson(raw) {
      if (raw === null || raw === undefined) {
        return false
      }
      const text = String(raw).trim()
      return text.startsWith('{') || text.startsWith('[')
    },
    parseValue(raw, valueType, defaultValue, item) {
      if (raw === undefined || raw === null || raw === '') {
        return defaultValue
      }
      if (item === 'investCurrencyMode') {
        const num = parseInt(raw, 10)
        return num === 2 ? 2 : 1
      }
      if (item === 'signRewardType') {
        const text = String(raw).trim().toUpperCase()
        return text === 'MONEY' ? 'MONEY' : 'POINT'
      }
      if (valueType === 'json' || item === 'inviteRewardRule' || item === 'signContinuousRewardRule') {
        return String(raw)
      }
      if (valueType === 'bool') {
        const text = String(raw).trim().toLowerCase()
        return text === 'true'
      }
      if (valueType === 'number') {
        const num = parseFloat(raw)
        return Number.isNaN(num) ? defaultValue : num
      }
      return String(raw)
    },
    buildConfigValue(option) {
      if (option.item === 'investCurrencyMode') {
        return option.currentValue === 2 ? '2' : '1'
      }
      if (option.item === 'signRewardType') {
        return option.currentValue === 'MONEY' ? 'MONEY' : 'POINT'
      }
      if (option.valueType === 'json' || option.item === 'inviteRewardRule' || option.item === 'signContinuousRewardRule') {
        return String(option.currentValue || '')
      }
      if (option.valueType === 'bool') {
        return option.currentValue ? 'true' : 'false'
      }
      return String(option.currentValue)
    },
    openJsonEditor(row) {
      this.jsonDialog.target = row
      this.jsonDialog.value = String(row.currentValue ?? row.configValueText ?? '')
      this.jsonDialog.visible = true
    },
    closeJsonEditor() {
      this.jsonDialog.visible = false
      this.jsonDialog.value = ''
      this.jsonDialog.target = null
    },
    confirmJsonEditor() {
      const target = this.jsonDialog.target
      if (!target) {
        this.closeJsonEditor()
        return
      }
      const raw = String(this.jsonDialog.value ?? '').trim()
      if (raw) {
        try {
          JSON.parse(raw)
        } catch (e) {
          this.$modal.msgError('JSON 格式不正确，请先修正后再保存')
          return
        }
      }
      target.currentValue = raw
      target.configValueText = raw
      this.closeJsonEditor()
    },
    async handleSave() {
      this.saving = true
      try {
        const payload = {
          options: this.options.map((option) => ({
            configName: option.name,
            configKey: option.configKey,
            configValue: this.buildConfigValue(option),
            remark: option.remark || '后台 APP 配置管理保存',
            isAppConfig: '1'
          }))
        }
        await saveAppConfig(payload)
        this.$modal.msgSuccess('保存成功，APP 配置缓存已刷新')
        await this.loadAll()
      } catch (e) {
        this.$modal.msgError('保存失败，请检查后端日志或权限')
      } finally {
        this.saving = false
      }
    }
  }
}
</script>

<style scoped>
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 16px;
  font-weight: 600;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.footer-actions {
  margin-top: 16px;
  display: flex;
  gap: 10px;
}

.group-card {
  margin-bottom: 16px;
}

.group-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 14px;
  font-weight: 600;
}

.group-card-count {
  color: #909399;
  font-size: 12px;
  font-weight: 400;
}

.value-text {
  word-break: break-all;
  white-space: pre-wrap;
}

.json-alert {
  margin-bottom: 12px;
}
</style>
