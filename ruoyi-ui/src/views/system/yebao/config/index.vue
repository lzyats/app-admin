<template>
  <div class="app-container">
    <el-card class="mb16">
      <template slot="header">
        <div class="card-header">
          <span>余额宝配置</span>
          <el-button v-hasPermi="['system:yebao:config:add']" type="primary" size="small" @click="handleAdd">
            <i class="el-icon-plus"></i> 新增
          </el-button>
        </div>
      </template>

      <el-alert
        title="余额宝说明"
        type="info"
        :closable="false"
        show-icon
        class="mb12"
      >
        <template slot="description">
          <div class="rule-list">
            <div>当前模块仅用于余额宝，与后续理财产品独立。</div>
            <div>每份金额固定为 100 元，收益率由后台配置。</div>
            <div>每日 24:00 结算前一天收益，不足 24 小时顺延。</div>
            <div>所有金额按 2 位小数严格入账，避免浮点误差。</div>
          </div>
        </template>
      </el-alert>

      <el-row :gutter="12" class="mb12">
        <el-col :xs="24" :sm="12" :md="8">
          <div class="summary-card">
            <div class="summary-label">默认每份金额</div>
            <div class="summary-value">{{ defaultUnitAmount.toFixed(2) }}</div>
          </div>
        </el-col>
        <el-col :xs="24" :sm="12" :md="8">
          <div class="summary-card">
            <div class="summary-label">年化收益率</div>
            <div class="summary-value">{{ previewRateText }}</div>
          </div>
        </el-col>
        <el-col :xs="24" :sm="24" :md="8">
          <div class="summary-card">
            <div class="summary-label">结算规则</div>
            <div class="summary-value summary-value-small">按日结算，未满 24 小时顺延</div>
          </div>
        </el-col>
      </el-row>

      <el-card class="mb12 task-template" shadow="never">
        <template slot="header">
          <span>定时任务模板</span>
        </template>
        <div class="template-grid">
          <div class="template-item">
            <div class="template-label">任务名称</div>
            <div class="template-value">余额宝收益结算</div>
          </div>
          <div class="template-item">
            <div class="template-label">调用目标</div>
            <div class="template-value mono">yebaoTask.settleIncome</div>
          </div>
          <div class="template-item">
            <div class="template-label">Cron 表达式</div>
            <div class="template-value mono">0 0 0 * * ?</div>
          </div>
          <div class="template-item template-item-full">
            <div class="template-label">说明</div>
            <div class="template-value">请到“系统监控 -> 定时任务”新增以上任务，状态启用后即会每天 0 点执行余额宝收益结算。</div>
          </div>
        </div>
      </el-card>

      <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch">
        <el-form-item label="配置名称" prop="configName">
          <el-input
            v-model="queryParams.configName"
            placeholder="请输入配置名称"
            clearable
            style="width: 180px"
          />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 120px">
            <el-option label="正常" value="0" />
            <el-option label="停用" value="1" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" size="small" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" size="small" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="configList" border style="width: 100%">
        <el-table-column label="配置ID" prop="configId" width="90" />
        <el-table-column label="配置名称" prop="configName" min-width="160" />
        <el-table-column label="年化收益率(%)" prop="annualRate" width="130">
          <template slot-scope="scope">{{ formatRate(scope.row.annualRate) }}</template>
        </el-table-column>
        <el-table-column label="每份金额" prop="unitAmount" width="120">
          <template slot-scope="scope">{{ formatAmount(scope.row.unitAmount) }}</template>
        </el-table-column>
        <el-table-column label="状态" prop="status" width="100">
          <template slot-scope="scope">
            <el-tag :type="scope.row.status === '0' ? 'success' : 'danger'">
              {{ scope.row.status === '0' ? '正常' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="备注" prop="remark" min-width="180" />
        <el-table-column label="更新时间" prop="updateTime" width="170" />
        <el-table-column label="操作" width="180" fixed="right">
          <template slot-scope="scope">
            <el-button v-hasPermi="['system:yebao:config:edit']" type="text" size="mini" @click="handleEdit(scope.row)">修改</el-button>
            <el-button v-hasPermi="['system:yebao:config:remove']" type="text" size="mini" @click="handleDelete(scope.row)">删除</el-button>
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
    </el-card>

    <el-dialog :title="dialogTitle" :visible.sync="dialogVisible" width="560px" append-to-body>
      <el-form :model="form" :rules="rules" ref="form" label-width="120px">
        <el-form-item label="配置名称" prop="configName">
          <el-input v-model="form.configName" placeholder="请输入配置名称" />
        </el-form-item>
        <el-form-item label="年化收益率(%)" prop="annualRate">
          <el-input-number
            v-model="form.annualRate"
            :precision="4"
            :step="0.1"
            :min="0"
            controls-position="right"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="每份金额" prop="unitAmount">
          <el-input-number
            v-model="form.unitAmount"
            :precision="2"
            :step="1"
            :min="0"
            controls-position="right"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="每份成长值" prop="growthValuePerUnit">
          <el-input-number
            v-model="form.growthValuePerUnit"
            :precision="4"
            :step="0.1"
            :min="0"
            controls-position="right"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="请选择状态" style="width: 100%">
            <el-option label="正常" value="0" />
            <el-option label="停用" value="1" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listYebaoConfig, getYebaoConfig, addYebaoConfig, updateYebaoConfig, delYebaoConfig } from '@/api/system/yebao/config'

export default {
  name: 'YebaoConfig',
  data() {
    return {
      loading: false,
      showSearch: true,
      configList: [],
      total: 0,
      dialogVisible: false,
      dialogTitle: '新增余额宝配置',
      defaultUnitAmount: 100,
      previewRateText: '3.6500%',
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        configName: null,
        status: null
      },
      form: {
        configId: null,
        configName: '',
        annualRate: 3.65,
        unitAmount: 100,
        growthValuePerUnit: 0, // 新增成长值字段
        status: '0',
        remark: ''
      },
      rules: {
        configName: [{ required: true, message: '请输入配置名称', trigger: 'blur' }],
        annualRate: [{ required: true, message: '请输入年化收益率', trigger: 'blur' }],
        unitAmount: [{ required: true, message: '请输入每份金额', trigger: 'blur' }],
        growthValuePerUnit: [{ required: true, message: '请输入每份成长值', trigger: 'blur' }],
        status: [{ required: true, message: '请选择状态', trigger: 'change' }]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    formatAmount(value) {
      return Number(value || 0).toFixed(2)
    },
    formatRate(value) {
      return Number(value || 0).toFixed(4) + '%'
    },
    getList() {
      this.loading = true
      listYebaoConfig(this.queryParams)
        .then((res) => {
          this.configList = res.rows || []
          this.total = res.total || 0
        })
        .finally(() => {
          this.loading = false
        })
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.$refs.queryForm.resetFields()
      this.handleQuery()
    },
    handleAdd() {
      this.dialogTitle = '新增余额宝配置'
      this.form = {
        configId: null,
        configName: '',
        annualRate: 3.65,
        unitAmount: 100,
        growthValuePerUnit: 0, // 初始化成长值
        status: '0',
        remark: ''
      }
      this.dialogVisible = true
    },
    handleEdit(row) {
      getYebaoConfig(row.configId).then((res) => {
        this.dialogTitle = '修改余额宝配置'
        this.form = res.data || res
        this.dialogVisible = true
      })
    },
    submitForm() {
      this.$refs.form.validate((valid) => {
        if (!valid) {
          return
        }
        const api = this.form.configId ? updateYebaoConfig : addYebaoConfig
        api(this.form).then(() => {
          this.$modal.msgSuccess('操作成功')
          this.dialogVisible = false
          this.getList()
        })
      })
    },
    handleDelete(row) {
      this.$modal
        .confirm('是否确认删除该配置？')
        .then(() => delYebaoConfig(row.configId))
        .then(() => {
          this.$modal.msgSuccess('删除成功')
          this.getList()
        })
    }
  }
}
</script>

<style scoped>
.mb12 {
  margin-bottom: 12px;
}

.mb16 {
  margin-bottom: 16px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.rule-list {
  line-height: 1.8;
}

.summary-card {
  border: 1px solid #ebeef5;
  border-radius: 8px;
  padding: 14px 16px;
  background: linear-gradient(180deg, #fbfdff 0%, #f7fbff 100%);
}

.summary-label {
  color: #909399;
  font-size: 13px;
  margin-bottom: 8px;
}

.summary-value {
  color: #303133;
  font-size: 22px;
  font-weight: 700;
}

.summary-value-small {
  font-size: 16px;
  line-height: 1.5;
}

.task-template {
  border-radius: 8px;
}

.template-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
}

.template-item-full {
  grid-column: 1 / -1;
}

.template-label {
  color: #909399;
  font-size: 13px;
  margin-bottom: 6px;
}

.template-value {
  color: #303133;
  font-size: 14px;
  line-height: 1.6;
  word-break: break-all;
}

.mono {
  font-family: Consolas, Monaco, 'Courier New', monospace;
}

@media (max-width: 768px) {
  .template-grid {
    grid-template-columns: 1fr;
  }
}
</style>
