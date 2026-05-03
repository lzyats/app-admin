<template>
  <div class="app-container">
    <el-card>
      <template slot="header">
        <div class="card-header">
          <span>成长值管理</span>
          <div>
            <el-button type="primary" size="small" @click="openAdjustDialog('increase')">
              <i class="el-icon-plus"></i> 增加成长值
            </el-button>
            <el-button type="danger" size="small" @click="openAdjustDialog('decrease')">
              <i class="el-icon-minus"></i> 扣除成长值
            </el-button>
          </div>
        </div>
      </template>

      <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch">
        <el-form-item label="用户ID" prop="userId">
          <el-input v-model="queryParams.userId" placeholder="请输入用户ID" clearable style="width: 180px" />
        </el-form-item>
        <el-form-item label="用户名" prop="userName">
          <el-input v-model="queryParams.userName" placeholder="请输入用户名" clearable style="width: 180px" />
        </el-form-item>
        <el-form-item label="变动类型" prop="changeType">
          <el-select v-model="queryParams.changeType" placeholder="全部" clearable style="width: 140px">
            <el-option label="增加" value="increase" />
            <el-option label="扣除" value="decrease" />
          </el-select>
        </el-form-item>
        <el-form-item label="来源类型" prop="sourceType">
          <el-input v-model="queryParams.sourceType" placeholder="如 manual / yebao_settlement" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="时间范围">
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
          <el-button type="primary" icon="el-icon-search" size="small" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" size="small" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="logList" border style="width: 100%">
        <el-table-column label="日志ID" prop="logId" width="90" />
        <el-table-column label="用户ID" prop="userId" width="90" />
        <el-table-column label="用户名" prop="userName" min-width="120" />
        <el-table-column label="变动类型" prop="changeType" width="100">
          <template slot-scope="scope">
            <el-tag size="small" :type="scope.row.changeType === 'increase' ? 'success' : 'danger'">
              {{ scope.row.changeType === 'increase' ? '增加' : '扣除' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="变动值" prop="changeValue" width="100">
          <template slot-scope="scope">
            <span :style="{ color: Number(scope.row.changeValue) >= 0 ? '#67c23a' : '#f56c6c' }">
              {{ formatSignedValue(scope.row.changeValue) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="变动前" prop="growthValueBefore" width="100" />
        <el-table-column label="变动后" prop="growthValueAfter" width="100" />
        <el-table-column label="来源类型" prop="sourceType" width="150" />
        <el-table-column label="来源单号" prop="sourceNo" width="170" :show-overflow-tooltip="true" />
        <el-table-column label="操作人" prop="operatorName" width="120" />
        <el-table-column label="备注" prop="remark" min-width="180" :show-overflow-tooltip="true" />
        <el-table-column label="时间" prop="createTime" width="170" />
        <el-table-column label="操作" width="120" fixed="right">
          <template slot-scope="scope">
            <el-button type="text" size="mini" @click="openAdjustDialog('increase', scope.row)">增加</el-button>
            <el-button type="text" size="mini" @click="openAdjustDialog('decrease', scope.row)">扣除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />
    </el-card>

    <el-dialog :title="adjustDialogTitle" :visible.sync="adjustDialogVisible" width="560px" append-to-body>
      <el-form :model="adjustForm" :rules="adjustRules" ref="adjustForm" label-width="100px">
        <el-form-item label="用户ID" prop="userId">
          <el-input-number v-model="adjustForm.userId" :min="1" controls-position="right" style="width: 100%" />
        </el-form-item>
        <el-form-item label="成长值" prop="growthValue">
          <el-input-number v-model="adjustForm.growthValue" :min="1" controls-position="right" style="width: 100%" />
        </el-form-item>
        <el-form-item label="来源类型" prop="sourceType">
          <el-input v-model="adjustForm.sourceType" placeholder="默认 manual" />
        </el-form-item>
        <el-form-item label="来源单号">
          <el-input v-model="adjustForm.sourceNo" placeholder="可选" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="adjustForm.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="adjustDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitAdjust">确定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listGrowthLog, increaseGrowthValue, decreaseGrowthValue } from '@/api/system/growth'

export default {
  name: 'GrowthManagement',
  data() {
    return {
      loading: false,
      showSearch: true,
      logList: [],
      total: 0,
      dateRange: [],
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userId: undefined,
        userName: undefined,
        changeType: undefined,
        sourceType: undefined
      },
      adjustDialogVisible: false,
      adjustDialogType: 'increase',
      adjustForm: {
        userId: undefined,
        growthValue: undefined,
        sourceType: 'manual',
        sourceNo: '',
        remark: ''
      },
      adjustRules: {
        userId: [{ required: true, message: '请输入用户ID', trigger: 'blur' }],
        growthValue: [{ required: true, message: '请输入成长值', trigger: 'blur' }]
      }
    }
  },
  computed: {
    adjustDialogTitle() {
      return this.adjustDialogType === 'increase' ? '增加成长值' : '扣除成长值'
    }
  },
  created() {
    this.initQueryFromRoute()
    this.getList()
  },
  methods: {
    initQueryFromRoute() {
      const userId = this.$route.query.userId
      const userName = this.$route.query.userName
      if (userId) {
        this.queryParams.userId = Number(userId)
      }
      if (userName) {
        this.queryParams.userName = userName
      }
    },
    formatSignedValue(value) {
      const num = Number(value || 0)
      if (num > 0) {
        return `+${num}`
      }
      return `${num}`
    },
    getList() {
      this.loading = true
      listGrowthLog(this.addDateRange(this.queryParams, this.dateRange)).then(res => {
        this.logList = res.rows || []
        this.total = res.total || 0
      }).finally(() => {
        this.loading = false
      })
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.dateRange = []
      this.resetForm('queryForm')
      this.queryParams.pageNum = 1
      this.queryParams.pageSize = 10
      this.handleQuery()
    },
    openAdjustDialog(type, row) {
      this.adjustDialogType = type
      this.adjustForm = {
        userId: row ? row.userId : (this.queryParams.userId || undefined),
        growthValue: undefined,
        sourceType: 'manual',
        sourceNo: '',
        remark: ''
      }
      this.adjustDialogVisible = true
    },
    submitAdjust() {
      this.$refs.adjustForm.validate(valid => {
        if (!valid) {
          return
        }
        const payload = {
          userId: this.adjustForm.userId,
          growthValue: this.adjustForm.growthValue,
          sourceType: this.adjustForm.sourceType || 'manual',
          sourceNo: this.adjustForm.sourceNo,
          remark: this.adjustForm.remark
        }
        const api = this.adjustDialogType === 'increase' ? increaseGrowthValue : decreaseGrowthValue
        api(payload).then(() => {
          this.$modal.msgSuccess('操作成功')
          this.adjustDialogVisible = false
          this.getList()
        })
      })
    }
  }
}
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
