<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="参数名称" prop="configName">
        <el-input
          v-model="queryParams.configName"
          placeholder="请输入参数名称"
          clearable
          style="width: 240px"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="参数键名" prop="configKey">
        <el-input
          v-model="queryParams.configKey"
          placeholder="请输入参数键名"
          clearable
          style="width: 240px"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="是否APP配置" prop="isAppConfig">
        <el-select v-model="queryParams.isAppConfig" placeholder="全部" clearable style="width: 160px">
          <el-option label="是" value="1" />
          <el-option label="否" value="0" />
        </el-select>
      </el-form-item>
      <el-form-item label="系统内置" prop="configType">
        <el-select v-model="queryParams.configType" placeholder="全部" clearable style="width: 160px">
          <el-option
            v-for="dict in dict.type.sys_yes_no"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="参数类型" prop="configValueType">
        <el-select v-model="queryParams.configValueType" placeholder="全部" clearable style="width: 160px">
          <el-option
            v-for="item in configValueTypeOptions"
            :key="item.value"
            :label="item.label"
            :value="item.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="创建时间">
        <el-date-picker
          v-model="dateRange"
          style="width: 240px"
          value-format="yyyy-MM-dd"
          type="daterange"
          range-separator="-"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="el-icon-plus"
          size="mini"
          @click="handleAdd"
          v-hasPermi="['system:config:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="el-icon-edit"
          size="mini"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['system:config:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-delete"
          size="mini"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['system:config:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="el-icon-download"
          size="mini"
          @click="handleExport"
          v-hasPermi="['system:config:export']"
        >导出</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="el-icon-refresh"
          size="mini"
          @click="handleRefreshCache"
          v-hasPermi="['system:config:edit']"
        >刷新缓存</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="configList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="参数主键" align="center" prop="configId" width="100" />
      <el-table-column label="参数名称" align="left" prop="configName" :show-overflow-tooltip="true" />
      <el-table-column label="参数键名" align="left" prop="configKey" :show-overflow-tooltip="true" />
      <el-table-column label="参数类型" align="center" prop="configValueType" width="100">
        <template slot-scope="scope">
          <el-tag size="mini" effect="dark" :type="configValueTypeTagType(scope.row.configValueType, scope.row.configValue)">
            {{ configValueTypeLabel(scope.row.configValueType, scope.row.configValue) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="参数键值" align="left" prop="configValue" :show-overflow-tooltip="true">
        <template slot-scope="scope">
          <div v-if="isImageType(scope.row.configValueType, scope.row.configValue)">
            <el-image
              :src="resolveAssetUrl(scope.row.configValue)"
              fit="cover"
              style="width: 40px; height: 40px; border-radius: 4px"
              :preview-src-list="[resolveAssetUrl(scope.row.configValue)]"
            />
          </div>
          <div v-else-if="isFileType(scope.row.configValueType, scope.row.configValue)">
            <el-link type="primary" :underline="false" :href="resolveAssetUrl(scope.row.configValue)" target="_blank">查看文件</el-link>
          </div>
          <div v-else-if="isSwitchType(scope.row.configValueType, scope.row.configValue)">
            <el-tag size="mini" :type="isSwitchOn(scope.row.configValue) ? 'success' : 'info'">
              {{ isSwitchOn(scope.row.configValue) ? '开启' : '关闭' }}
            </el-tag>
          </div>
          <div v-else-if="isSelectType(scope.row.configValueType, scope.row.configValue)">
            <el-tag size="mini" type="warning">
              {{ resolveSelectLabel(scope.row.configValue, scope.row.remark) }}
            </el-tag>
          </div>
          <span v-else>{{ scope.row.configValue }}</span>
        </template>
      </el-table-column>
      <el-table-column label="系统内置" align="center" prop="configType" width="90">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.sys_yes_no" :value="scope.row.configType" />
        </template>
      </el-table-column>
      <el-table-column label="是否APP配置" align="center" prop="isAppConfig" width="110">
        <template slot-scope="scope">
          <el-tag :type="isAppConfigTagType(scope.row.isAppConfig)">{{ isAppConfigLabel(scope.row.isAppConfig) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="备注" align="left" prop="remark" :show-overflow-tooltip="true" />
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="160">
        <template slot-scope="scope">
          <el-button
            size="mini"
            type="text"
            icon="el-icon-edit"
            @click="handleUpdate(scope.row)"
            v-hasPermi="['system:config:edit']"
          >修改</el-button>
          <el-button
            size="mini"
            type="text"
            icon="el-icon-delete"
            @click="handleDelete(scope.row)"
            v-hasPermi="['system:config:remove']"
          >删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />

    <el-dialog :title="title" :visible.sync="open" width="560px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="参数名称" prop="configName">
          <el-input v-model="form.configName" placeholder="请输入参数名称" />
        </el-form-item>
        <el-form-item label="参数键名" prop="configKey">
          <el-input v-model="form.configKey" placeholder="请输入参数键名" />
        </el-form-item>
        <el-form-item label="参数类型" prop="configValueType">
          <el-select v-model="form.configValueType" placeholder="请选择参数类型" style="width: 100%" @change="handleConfigValueTypeChange">
            <el-option
              v-for="item in configValueTypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="参数键值" prop="configValue">
          <image-upload
            v-if="isImageType(form.configValueType)"
            v-model="form.configValue"
            :limit="1"
            :file-type="['png','jpg','jpeg','gif','webp']"
            :is-show-tip="true"
          />
          <file-upload
            v-else-if="isFileType(form.configValueType)"
            v-model="form.configValue"
            :limit="1"
            :file-type="['pdf','doc','docx','xls','xlsx','ppt','pptx','txt','zip','rar']"
            :is-show-tip="true"
          />
          <el-date-picker
            v-else-if="isDateType(form.configValueType)"
            v-model="form.configValue"
            type="datetime"
            value-format="yyyy-MM-dd HH:mm:ss"
            format="yyyy-MM-dd HH:mm:ss"
            placeholder="请选择日期时间"
            style="width: 100%"
          />
          <el-switch
            v-else-if="isSwitchType(form.configValueType)"
            v-model="form.configValue"
            active-value="true"
            inactive-value="false"
            active-text="开启"
            inactive-text="关闭"
          />
          <el-select
            v-else-if="isSelectType(form.configValueType)"
            v-model="form.configValue"
            placeholder="请选择选项（从备注解析）"
            style="width: 100%"
            filterable
          >
            <el-option
              v-for="item in buildSelectOptions(form.remark)"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
            <el-option
              v-if="buildSelectOptions(form.remark).length === 0"
              label="请先在备注填写选项，例如：POINT,MONEY"
              value=""
              disabled
            />
          </el-select>
          <el-input v-else v-model="form.configValue" type="textarea" :rows="4" placeholder="请输入参数键值" />
        </el-form-item>
        <el-form-item label="系统内置" prop="configType">
          <el-radio-group v-model="form.configType">
            <el-radio
              v-for="dict in dict.type.sys_yes_no"
              :key="dict.value"
              :label="dict.value"
            >{{ dict.label }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="是否APP配置" prop="isAppConfig">
          <el-radio-group v-model="form.isAppConfig">
            <el-radio label="1">是</el-radio>
            <el-radio label="0">否</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="请输入备注（SELECT类型可填写选项，如：POINT,MONEY 或 1:启用;0:关闭）" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确定</el-button>
        <el-button @click="cancel">取消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listConfig, getConfig, delConfig, addConfig, updateConfig, refreshCache } from '@/api/system/config'

export default {
  name: 'Config',
  dicts: ['sys_yes_no'],
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      configList: [],
      title: '',
      open: false,
      dateRange: [],
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        configName: undefined,
        configKey: undefined,
        configType: undefined,
        isAppConfig: undefined,
        configValueType: undefined
      },
      configValueTypeOptions: [
        { label: '文本', value: 'TEXT' },
        { label: '图片', value: 'IMAGE' },
        { label: '文件', value: 'FILE' },
        { label: '日期', value: 'DATE' },
        { label: '开关', value: 'SWITCH' },
        { label: '下拉选择', value: 'SELECT' }
      ],
      form: {
        configId: undefined,
        configName: undefined,
        configKey: undefined,
        configValue: undefined,
        configValueType: 'TEXT',
        configType: 'N',
        isAppConfig: '0',
        remark: undefined
      },
      rules: {
        configName: [
          { required: true, message: '参数名称不能为空', trigger: 'blur' }
        ],
        configKey: [
          { required: true, message: '参数键名不能为空', trigger: 'blur' }
        ],
        configValue: [
          { required: true, message: '参数键值不能为空', trigger: 'blur' }
        ],
        configValueType: [
          { required: true, message: '参数类型不能为空', trigger: 'change' }
        ]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listConfig(this.addDateRange(this.queryParams, this.dateRange)).then(response => {
        this.configList = response.rows || []
        this.total = response.total || 0
        this.loading = false
      }).catch(() => {
        this.loading = false
      })
    },
    cancel() {
      this.open = false
      this.reset()
    },
    reset() {
      this.form = {
        configId: undefined,
        configName: undefined,
        configKey: undefined,
        configValue: undefined,
        configValueType: 'TEXT',
        configType: 'N',
        isAppConfig: '0',
        remark: undefined
      }
      this.resetForm('form')
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.dateRange = []
      this.resetForm('queryForm')
      this.handleQuery()
    },
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.configId)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '添加参数'
    },
    handleUpdate(row) {
      this.reset()
      const configId = row && row.configId ? row.configId : this.ids[0]
      getConfig(configId).then(response => {
        this.form = Object.assign({}, response.data, {
          configValueType: this.normalizeConfigValueType(response.data.configValueType, response.data.configValue),
          configType: response.data.configType || 'N',
          isAppConfig: response.data.isAppConfig || '0'
        })
        this.open = true
        this.title = '修改参数'
      })
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) {
          return
        }
        const request = this.form.configId ? updateConfig : addConfig
        this.form.configValueType = this.normalizeConfigValueType(this.form.configValueType, this.form.configValue)
        request(this.form).then(() => {
          this.$modal.msgSuccess('操作成功')
          this.open = false
          this.getList()
        })
      })
    },
    handleDelete(row) {
      const configIds = row && row.configId ? row.configId : this.ids
      this.$modal.confirm('是否确认删除选中的参数配置？').then(() => {
        return delConfig(configIds)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      }).catch(() => {})
    },
    handleRefreshCache() {
      this.$modal.confirm('是否确认刷新参数缓存？').then(() => {
        return refreshCache()
      }).then(() => {
        this.$modal.msgSuccess('刷新成功')
      }).catch(() => {})
    },
    handleExport() {
      this.download(
        'system/config/export',
        this.addDateRange({ ...this.queryParams }, this.dateRange),
        `参数配置_${new Date().getTime()}.xlsx`
      )
    },
    isAppConfigLabel(value) {
      return String(value) === '1' ? '是' : '否'
    },
    isAppConfigTagType(value) {
      return String(value) === '1' ? 'success' : 'info'
    },
    handleConfigValueTypeChange(value) {
      if (this.isSwitchType(value)) {
        if (this.form.configValue !== 'true' && this.form.configValue !== 'false') {
          this.form.configValue = 'false'
        }
        return
      }
      if (this.isSelectType(value)) {
        const options = this.buildSelectOptions(this.form.remark)
        const values = options.map(item => item.value)
        if (options.length > 0 && !values.includes(String(this.form.configValue || ''))) {
          this.form.configValue = options[0].value
        }
        return
      }
      if (this.isDateType(value) && !this.form.configValue) {
        this.form.configValue = this.parseTime(new Date(), '{y}-{m}-{d} {h}:{i}:{s}')
      }
      if (!this.form.configValue) {
        return
      }
      if (this.isImageType(value) || this.isFileType(value)) {
        return
      }
    },
    normalizeConfigValueType(type, value) {
      const text = String(type || '').toUpperCase()
      if (['TEXT', 'IMAGE', 'FILE', 'DATE', 'SWITCH', 'SELECT'].includes(text)) {
        return text
      }
      const val = String(value || '')
      if (/\.(png|jpg|jpeg|gif|webp)$/i.test(val)) {
        return 'IMAGE'
      }
      if (/\.(pdf|doc|docx|xls|xlsx|ppt|pptx|txt|zip|rar)$/i.test(val)) {
        return 'FILE'
      }
      if (/^(true|false|0|1)$/i.test(val.trim())) {
        return 'SWITCH'
      }
      if (/^\d{4}-\d{2}-\d{2}([ T]\d{2}:\d{2}(:\d{2})?)?$/.test(val.trim())) {
        return 'DATE'
      }
      return 'TEXT'
    },
    configValueTypeLabel(value, rawValue) {
      const type = this.normalizeConfigValueType(value, rawValue)
      const found = this.configValueTypeOptions.find(item => item.value === type)
      return found ? found.label : '文本'
    },
    configValueTypeTagType(value, rawValue) {
      const type = this.normalizeConfigValueType(value, rawValue)
      if (type === 'IMAGE') return 'success'
      if (type === 'FILE') return 'warning'
      if (type === 'DATE') return ''
      if (type === 'SWITCH') return 'info'
      if (type === 'SELECT') return 'warning'
      return ''
    },
    isImageType(value, rawValue) {
      return this.normalizeConfigValueType(value, rawValue) === 'IMAGE'
    },
    isFileType(value, rawValue) {
      return this.normalizeConfigValueType(value, rawValue) === 'FILE'
    },
    isDateType(value, rawValue) {
      return this.normalizeConfigValueType(value, rawValue) === 'DATE'
    },
    isSwitchType(value, rawValue) {
      return this.normalizeConfigValueType(value, rawValue) === 'SWITCH'
    },
    isSelectType(value, rawValue) {
      return this.normalizeConfigValueType(value, rawValue) === 'SELECT'
    },
    isSwitchOn(value) {
      const text = String(value || '').trim().toLowerCase()
      return text === 'true' || text === '1' || text === 'y'
    },
    buildSelectOptions(remark) {
      const raw = String(remark || '').trim()
      if (!raw) {
        return []
      }
      const blocks = raw
        .split(/\r?\n|[,;；，]/g)
        .map(item => item.trim())
        .filter(Boolean)
      const options = []
      for (const block of blocks) {
        const idx = block.includes(':') ? block.indexOf(':') : block.indexOf('=')
        if (idx > 0) {
          const value = block.slice(0, idx).trim()
          const label = block.slice(idx + 1).trim() || value
          if (value) {
            options.push({ value, label })
          }
          continue
        }
        options.push({ value: block, label: block })
      }
      return options
    },
    resolveSelectLabel(value, remark) {
      const rawValue = String(value || '').trim()
      const options = this.buildSelectOptions(remark)
      const found = options.find(item => item.value === rawValue)
      return found ? found.label : rawValue
    },
    resolveAssetUrl(url) {
      const raw = String(url || '').trim()
      if (!raw) {
        return ''
      }
      if (/^https?:\/\//i.test(raw)) {
        return raw
      }
      return process.env.VUE_APP_BASE_API + raw
    }
  }
}
</script>
