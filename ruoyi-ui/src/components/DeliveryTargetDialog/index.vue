<template>
  <el-dialog :title="title" :visible.sync="dialogVisible" :width="width" append-to-body @close="handleClose">
    <el-form :model="grantForm" label-width="110px">
      <el-row>
        <el-col :span="12">
          <el-form-item :label="businessIdLabel">
            <el-input :value="businessIdDisplay" disabled />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="发放类型">
            <el-input v-model="grantForm.grantType" placeholder="MANUAL/ACTIVITY" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-form-item label="送达方式">
        <el-radio-group v-model="grantForm.grantTargetType" @change="handleGrantModeChange">
          <el-radio label="ALL">发送所有人</el-radio>
          <el-radio label="LEVEL">发送指定级别</el-radio>
          <el-radio label="REGISTER">按注册时间</el-radio>
          <el-radio label="FILTER">条件检索</el-radio>
        </el-radio-group>
      </el-form-item>

      <el-alert
        v-if="grantForm.grantTargetType === 'ALL'"
        title="将向当前可见范围内的全部正常用户发放。"
        type="info"
        :closable="false"
        show-icon
      />

      <el-row v-if="grantForm.grantTargetType === 'LEVEL'">
        <el-col :span="12">
          <el-form-item label="用户级别">
            <el-input-number v-model="grantForm.level" :min="0" style="width: 100%" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row v-if="grantForm.grantTargetType === 'REGISTER'">
        <el-col :span="12">
          <el-form-item label="注册时间">
            <el-date-picker
              v-model="grantForm.registerRange"
              type="datetimerange"
              range-separator="至"
              start-placeholder="开始时间"
              end-placeholder="结束时间"
              value-format="yyyy-MM-dd HH:mm:ss"
              style="width: 100%"
            />
          </el-form-item>
        </el-col>
      </el-row>

      <template v-if="grantForm.grantTargetType === 'FILTER'">
        <el-card shadow="never" class="mb8">
          <div slot="header" class="clearfix">
            <span>条件检索</span>
          </div>
          <el-form :model="audienceQuery" ref="audienceQueryForm" size="small" :inline="true" label-width="90px">
            <el-form-item label="用户名" prop="userName">
              <el-input v-model="audienceQuery.userName" clearable placeholder="用户名" />
            </el-form-item>
            <el-form-item label="昵称" prop="nickName">
              <el-input v-model="audienceQuery.nickName" clearable placeholder="昵称" />
            </el-form-item>
            <el-form-item label="真实姓名" prop="realName">
              <el-input v-model="audienceQuery.realName" clearable placeholder="真实姓名" />
            </el-form-item>
            <el-form-item label="手机号" prop="phonenumber">
              <el-input v-model="audienceQuery.phonenumber" clearable placeholder="手机号" />
            </el-form-item>
            <el-form-item label="级别" prop="level">
              <el-input-number v-model="audienceQuery.level" :min="0" />
            </el-form-item>
            <el-form-item label="状态" prop="status">
              <el-select v-model="audienceQuery.status" clearable style="width: 140px" placeholder="全部状态">
                <el-option label="正常" value="0" />
                <el-option label="停用" value="1" />
              </el-select>
            </el-form-item>
            <el-form-item label="实名状态" prop="realNameStatus">
              <el-select v-model="audienceQuery.realNameStatus" clearable style="width: 150px" placeholder="全部实名状态">
                <el-option label="未实名" value="0" />
                <el-option label="审核中" value="1" />
                <el-option label="已实名" value="2" />
                <el-option label="已驳回" value="3" />
              </el-select>
            </el-form-item>
            <el-form-item label="注册时间">
              <el-date-picker
                v-model="audienceQuery.registerRange"
                type="datetimerange"
                range-separator="至"
                start-placeholder="开始时间"
                end-placeholder="结束时间"
                value-format="yyyy-MM-dd HH:mm:ss"
                style="width: 320px"
              />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" icon="el-icon-search" size="mini" @click="loadAudienceList">查询</el-button>
              <el-button icon="el-icon-refresh" size="mini" @click="resetAudienceQuery">重置</el-button>
            </el-form-item>
          </el-form>

          <el-alert
            :title="selectedAudienceIds.length > 0 ? '已勾选 ' + selectedAudienceIds.length + ' 个用户，确认后仅向勾选用户发放。' : '未勾选用户时，将按当前检索条件全部发放。'"
            type="warning"
            :closable="false"
            show-icon
            class="mb8"
          />

          <el-table
            ref="audienceTable"
            v-loading="audienceLoading"
            :data="audienceList"
            row-key="userId"
            @selection-change="handleAudienceSelectionChange"
          >
            <el-table-column type="selection" width="55" :reserve-selection="true" />
            <el-table-column label="用户ID" prop="userId" width="90" />
            <el-table-column label="用户名" prop="userName" min-width="120" />
            <el-table-column label="昵称" prop="nickName" min-width="120" />
            <el-table-column label="级别" prop="level" width="90" />
            <el-table-column label="手机号" prop="phonenumber" min-width="130" />
            <el-table-column label="实名状态" prop="realNameStatus" width="100">
              <template slot-scope="scope">{{ formatRealNameStatus(scope.row.realNameStatus) }}</template>
            </el-table-column>
            <el-table-column label="状态" prop="status" width="90">
              <template slot-scope="scope">{{ formatUserStatus(scope.row.status) }}</template>
            </el-table-column>
            <el-table-column label="注册时间" prop="createTime" min-width="170" />
          </el-table>

          <pagination
            v-show="audienceTotal > 0"
            :total="audienceTotal"
            :page.sync="audienceQuery.pageNum"
            :limit.sync="audienceQuery.pageSize"
            @pagination="loadAudienceList"
          />
        </el-card>
      </template>

      <el-form-item label="备注">
        <el-input v-model="grantForm.remark" type="textarea" :rows="3" placeholder="请输入发放备注" />
      </el-form-item>
    </el-form>
    <div slot="footer" class="dialog-footer">
      <el-button type="primary" :loading="confirmLoading" @click="handleConfirm">确定发放</el-button>
      <el-button @click="handleCancel">取 消</el-button>
    </div>
  </el-dialog>
</template>

<script>
const defaultGrantForm = () => ({
  grantTargetType: 'ALL',
  grantType: 'MANUAL',
  level: undefined,
  registerRange: [],
  remark: undefined
})

const defaultAudienceQuery = () => ({
  pageNum: 1,
  pageSize: 10,
  userName: undefined,
  nickName: undefined,
  realName: undefined,
  phonenumber: undefined,
  level: undefined,
  status: '0',
  realNameStatus: undefined,
  registerRange: []
})

export default {
  name: 'DeliveryTargetDialog',
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    title: {
      type: String,
      default: '送达对象选择'
    },
    width: {
      type: String,
      default: '1180px'
    },
    businessId: {
      type: [String, Number],
      default: undefined
    },
    businessIdLabel: {
      type: String,
      default: '业务ID'
    },
    audienceFetcher: {
      type: Function,
      required: true
    },
    confirmLoading: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      grantForm: defaultGrantForm(),
      audienceLoading: false,
      audienceList: [],
      audienceTotal: 0,
      audienceQuery: defaultAudienceQuery(),
      selectedAudienceIds: []
    }
  },
  computed: {
    dialogVisible: {
      get() {
        return this.visible
      },
      set(val) {
        this.$emit('update:visible', val)
      }
    },
    businessIdDisplay() {
      return this.businessId === undefined || this.businessId === null ? '-' : String(this.businessId)
    }
  },
  watch: {
    visible(val) {
      if (val) {
        this.resetDialogState()
        if (this.grantForm.grantTargetType === 'FILTER') {
          this.loadAudienceList()
        }
      } else {
        this.resetDialogState()
      }
    }
  },
  methods: {
    resetDialogState() {
      this.grantForm = defaultGrantForm()
      this.audienceQuery = defaultAudienceQuery()
      this.audienceLoading = false
      this.audienceList = []
      this.audienceTotal = 0
      this.selectedAudienceIds = []
      this.$nextTick(() => {
        if (this.$refs.audienceTable && this.$refs.audienceTable.clearSelection) {
          this.$refs.audienceTable.clearSelection()
        }
      })
    },
    handleClose() {
      this.$emit('update:visible', false)
    },
    handleCancel() {
      this.$emit('update:visible', false)
    },
    handleGrantModeChange() {
      this.selectedAudienceIds = []
      this.audienceList = []
      this.audienceTotal = 0
      this.$nextTick(() => {
        if (this.$refs.audienceTable && this.$refs.audienceTable.clearSelection) {
          this.$refs.audienceTable.clearSelection()
        }
      })
      if (this.grantForm.grantTargetType === 'FILTER') {
        this.loadAudienceList()
      }
    },
    buildAudienceParams() {
      const params = Object.assign({}, this.audienceQuery)
      if (Array.isArray(params.registerRange) && params.registerRange.length === 2) {
        params.beginTime = params.registerRange[0]
        params.endTime = params.registerRange[1]
      }
      delete params.registerRange
      return params
    },
    loadAudienceList() {
      if (this.grantForm.grantTargetType !== 'FILTER') {
        return
      }
      this.audienceLoading = true
      Promise.resolve(this.audienceFetcher(this.buildAudienceParams())).then(res => {
        this.audienceList = res.rows || []
        this.audienceTotal = res.total || 0
        this.audienceLoading = false
      }).catch(() => {
        this.audienceLoading = false
      })
    },
    resetAudienceQuery() {
      this.audienceQuery = defaultAudienceQuery()
      this.$nextTick(() => {
        if (this.$refs.audienceQueryForm) {
          this.resetForm('audienceQueryForm')
        }
      })
    },
    handleAudienceSelectionChange(selection) {
      this.selectedAudienceIds = selection.map(item => item.userId)
    },
    buildPayload() {
      const isFilterMode = this.grantForm.grantTargetType === 'FILTER'
      const isRegisterMode = this.grantForm.grantTargetType === 'REGISTER'
      return {
        grantTargetType: this.grantForm.grantTargetType,
        grantType: this.grantForm.grantType,
        level: this.grantForm.level,
        remark: this.grantForm.remark,
        userIds: this.selectedAudienceIds,
        userName: isFilterMode ? this.audienceQuery.userName : undefined,
        nickName: isFilterMode ? this.audienceQuery.nickName : undefined,
        realName: isFilterMode ? this.audienceQuery.realName : undefined,
        phonenumber: isFilterMode ? this.audienceQuery.phonenumber : undefined,
        status: isFilterMode ? (this.audienceQuery.status || '0') : '0',
        realNameStatus: isFilterMode ? this.audienceQuery.realNameStatus : undefined,
        beginTime: isRegisterMode
          ? (Array.isArray(this.grantForm.registerRange) && this.grantForm.registerRange.length === 2 ? this.grantForm.registerRange[0] : undefined)
          : (isFilterMode && Array.isArray(this.audienceQuery.registerRange) && this.audienceQuery.registerRange.length === 2 ? this.audienceQuery.registerRange[0] : undefined),
        endTime: isRegisterMode
          ? (Array.isArray(this.grantForm.registerRange) && this.grantForm.registerRange.length === 2 ? this.grantForm.registerRange[1] : undefined)
          : (isFilterMode && Array.isArray(this.audienceQuery.registerRange) && this.audienceQuery.registerRange.length === 2 ? this.audienceQuery.registerRange[1] : undefined)
      }
    },
    handleConfirm() {
      if (this.grantForm.grantTargetType === 'LEVEL' && (this.grantForm.level === undefined || this.grantForm.level === null || this.grantForm.level === '')) {
        this.$modal.msgWarning('请先填写用户级别')
        return
      }
      if (this.grantForm.grantTargetType === 'REGISTER' && (!Array.isArray(this.grantForm.registerRange) || this.grantForm.registerRange.length !== 2)) {
        this.$modal.msgWarning('请先选择注册时间范围')
        return
      }
      if (this.grantForm.grantTargetType === 'FILTER' && this.selectedAudienceIds.length === 0) {
        this.$modal.confirm('当前未勾选用户，将按当前检索条件全部发放，是否继续？').then(() => {
          this.$emit('confirm', this.buildPayload())
        }).catch(() => {})
        return
      }
      this.$emit('confirm', this.buildPayload())
    },
    formatRealNameStatus(status) {
      const map = {
        '0': '未实名',
        '1': '审核中',
        '2': '已实名',
        '3': '已驳回'
      }
      return map[String(status)] || '-'
    },
    formatUserStatus(status) {
      return String(status) === '0' ? '正常' : '停用'
    }
  }
}
</script>
