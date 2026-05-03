<template>
  <div class="app-container">
    <el-card>
      <template slot="header">
        <div class="page-header">
          <span>积分账户管理</span>
          <el-button icon="el-icon-refresh" size="mini" @click="getList">刷新</el-button>
        </div>
      </template>

      <el-form :model="queryParams" :inline="true" v-show="showSearch" size="small" label-width="80px">
        <el-form-item label="用户名" prop="userName">
          <el-input
            v-model="queryParams.userName"
            placeholder="请输入用户名"
            clearable
            style="width: 180px"
            @keyup.enter.native="handleQuery"
          />
        </el-form-item>
        <el-form-item label="用户ID" prop="userId">
          <el-input
            v-model="queryParams.userId"
            placeholder="请输入用户ID"
            clearable
            style="width: 180px"
            @keyup.enter.native="handleQuery"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" size="small" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" size="small" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="accountList" border>
        <el-table-column label="账户ID" prop="pointAccountId" width="100" />
        <el-table-column label="用户ID" prop="userId" width="100" />
        <el-table-column label="用户名" prop="userName" width="120" />
        <el-table-column label="可用积分" prop="availablePoints" width="120" />
        <el-table-column label="冻结积分" prop="frozenPoints" width="120" />
        <el-table-column label="累计获得" prop="totalEarned" width="120" />
        <el-table-column label="累计消费" prop="totalSpent" width="120" />
        <el-table-column label="人工调整" prop="totalAdjusted" width="120" />
        <el-table-column label="更新时间" prop="updateTime" width="170">
          <template slot-scope="scope">
            <span>{{ formatDate(scope.row.updateTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="260">
          <template slot-scope="scope">
            <el-button type="text" size="mini" @click="handleDetail(scope.row)">详情</el-button>
            <el-button type="text" size="mini" @click="handleViewLogs(scope.row)">流水</el-button>
            <el-button type="text" size="mini" @click="handleGrant(scope.row)">发放</el-button>
            <el-button type="text" size="mini" @click="handleDeduct(scope.row)">扣减</el-button>
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

    <el-dialog :title="changeDialogTitle" :visible.sync="changeVisible" width="560px" append-to-body>
      <el-form :model="changeForm" label-width="100px" size="small">
        <el-form-item label="用户ID">
          <el-input v-model="changeForm.userId" readonly />
        </el-form-item>
        <el-form-item label="用户名">
          <el-input v-model="changeForm.userName" readonly />
        </el-form-item>
        <el-form-item label="积分数量">
          <el-input-number v-model="changeForm.points" :min="1" :step="1" :precision="0" style="width: 100%" />
        </el-form-item>
        <el-form-item label="来源类型">
          <el-input v-model="changeForm.sourceType" placeholder="manual / invest / activity / redeem / lottery" />
        </el-form-item>
        <el-form-item label="来源单号">
          <el-input v-model="changeForm.sourceNo" placeholder="可选" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="changeForm.remark" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="changeVisible = false">取消</el-button>
        <el-button type="primary" @click="submitChange">提交</el-button>
      </div>
    </el-dialog>

    <el-dialog title="积分账户详情" :visible.sync="detailVisible" width="560px" append-to-body>
      <el-form :model="detailForm" label-width="110px" size="small">
        <el-form-item label="账户ID"><el-input v-model="detailForm.pointAccountId" readonly /></el-form-item>
        <el-form-item label="用户ID"><el-input v-model="detailForm.userId" readonly /></el-form-item>
        <el-form-item label="用户名"><el-input v-model="detailForm.userName" readonly /></el-form-item>
        <el-row :gutter="12">
          <el-col :span="12"><el-form-item label="可用积分"><el-input v-model="detailForm.availablePoints" readonly /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="冻结积分"><el-input v-model="detailForm.frozenPoints" readonly /></el-form-item></el-col>
        </el-row>
        <el-row :gutter="12">
          <el-col :span="12"><el-form-item label="累计获得"><el-input v-model="detailForm.totalEarned" readonly /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="累计消费"><el-input v-model="detailForm.totalSpent" readonly /></el-form-item></el-col>
        </el-row>
        <el-form-item label="人工调整"><el-input v-model="detailForm.totalAdjusted" readonly /></el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="detailVisible = false">关闭</el-button>
      </div>
    </el-dialog>

    <el-dialog :title="logsDialogTitle" :visible.sync="logsVisible" width="920px" append-to-body>
      <el-alert
        :title="logsHint"
        type="info"
        :closable="false"
        show-icon
        style="margin-bottom: 12px"
      />
      <el-table v-loading="logsLoading" :data="logsList" border>
        <el-table-column label="账变ID" prop="logId" width="90" />
        <el-table-column label="变动积分" prop="points" width="100" />
        <el-table-column label="变动前" prop="pointsBefore" width="100" />
        <el-table-column label="变动后" prop="pointsAfter" width="100" />
        <el-table-column label="变动类型" prop="changeType" width="110" />
        <el-table-column label="来源类型" prop="sourceType" width="110" />
        <el-table-column label="来源单号" prop="sourceNo" min-width="160" />
        <el-table-column label="操作人" prop="operatorName" width="120" />
        <el-table-column label="时间" prop="createTime" width="170">
          <template slot-scope="scope">
            <span>{{ formatDate(scope.row.createTime) }}</span>
          </template>
        </el-table-column>
      </el-table>
      <pagination
        v-show="logsTotal > 0"
        :total="logsTotal"
        :page.sync="logsQuery.pageNum"
        :limit.sync="logsQuery.pageSize"
        @pagination="loadLogs"
      />
      <div slot="footer" class="dialog-footer">
        <el-button @click="logsVisible = false">关闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { deductPoints, getPointAccount, grantPoints, listPointAccount, listPointLog } from '@/api/system/point'

export default {
  name: 'PointAccountManagement',
  data() {
    return {
      loading: false,
      showSearch: true,
      accountList: [],
      total: 0,
      detailVisible: false,
      detailForm: {},
      changeVisible: false,
      changeDialogTitle: '积分发放',
      changeMode: 'grant',
      changeForm: {
        userId: null,
        userName: '',
        points: 1,
        sourceType: 'manual',
        sourceNo: '',
        remark: ''
      },
      logsVisible: false,
      logsLoading: false,
      logsList: [],
      logsTotal: 0,
      logsDialogTitle: '积分流水明细',
      logsHint: '当前账户的积分账变记录，按时间倒序展示。',
      logsQuery: {
        pageNum: 1,
        pageSize: 10,
        pointAccountId: undefined
      },
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userId: undefined,
        userName: undefined
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listPointAccount(this.queryParams)
        .then((res) => {
          this.accountList = res.rows || []
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
      this.queryParams.userId = undefined
      this.queryParams.userName = undefined
      this.handleQuery()
    },
    formatDate(value) {
      return this.parseTime(value, '{y}-{m}-{d} {h}:{i}:{s}') || '-'
    },
    handleDetail(row) {
      getPointAccount(row.pointAccountId)
        .then((res) => {
          this.detailForm = res.data || row
          this.detailVisible = true
        })
        .catch(() => {
          this.detailForm = row
          this.detailVisible = true
        })
    },
    handleViewLogs(row) {
      this.logsDialogTitle = `积分流水明细${row.userName ? ' - ' + row.userName : ''}`
      this.logsQuery = {
        pageNum: 1,
        pageSize: 10,
        pointAccountId: row.pointAccountId
      }
      this.logsVisible = true
      this.loadLogs()
    },
    loadLogs() {
      if (!this.logsQuery.pointAccountId) {
        this.logsList = []
        this.logsTotal = 0
        return
      }
      this.logsLoading = true
      listPointLog(this.logsQuery)
        .then((res) => {
          this.logsList = res.rows || []
          this.logsTotal = res.total || 0
        })
        .finally(() => {
          this.logsLoading = false
        })
    },
    handleGrant(row) {
      this.changeMode = 'grant'
      this.changeDialogTitle = '积分发放'
      this.changeForm = {
        userId: row.userId,
        userName: row.userName,
        points: 1,
        sourceType: 'manual',
        sourceNo: '',
        remark: ''
      }
      this.changeVisible = true
    },
    handleDeduct(row) {
      this.changeMode = 'deduct'
      this.changeDialogTitle = '积分扣减'
      this.changeForm = {
        userId: row.userId,
        userName: row.userName,
        points: 1,
        sourceType: 'manual',
        sourceNo: '',
        remark: ''
      }
      this.changeVisible = true
    },
    submitChange() {
      const action = this.changeMode === 'deduct' ? deductPoints : grantPoints
      action(this.changeForm).then(() => {
        this.$modal.msgSuccess('操作成功')
        this.changeVisible = false
        this.getList()
      })
    }
  }
}
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 16px;
  font-weight: 600;
}
</style>
