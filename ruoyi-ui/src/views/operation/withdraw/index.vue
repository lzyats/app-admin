<template>
  <div class="app-container">
    <el-card>
      <template slot="header">
        <div class="page-header">
          <span>提现管理</span>
          <el-button icon="el-icon-refresh" size="mini" @click="getList">刷新</el-button>
        </div>
      </template>

      <el-form
        ref="queryForm"
        :model="queryParams"
        :inline="true"
        v-show="showSearch"
        size="small"
        label-width="80px"
      >
        <el-form-item label="订单号" prop="orderNo">
          <el-input
            v-model="queryParams.orderNo"
            placeholder="请输入订单号"
            clearable
            style="width: 180px"
            @keyup.enter.native="handleQuery"
          />
        </el-form-item>
        <el-form-item label="用户名" prop="userName">
          <el-input
            v-model="queryParams.userName"
            placeholder="请输入用户名"
            clearable
            style="width: 180px"
            @keyup.enter.native="handleQuery"
          />
        </el-form-item>
        <el-form-item label="币种" prop="currencyType">
          <el-select v-model="queryParams.currencyType" placeholder="全部" clearable style="width: 140px">
            <el-option v-for="item in currencyOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="方式" prop="withdrawMethod">
          <el-select v-model="queryParams.withdrawMethod" placeholder="全部" clearable style="width: 140px">
            <el-option v-for="item in methodOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 140px">
            <el-option v-for="item in statusOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" size="small" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" size="small" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="withdrawList" border>
        <el-table-column label="订单号" prop="orderNo" min-width="180" />
        <el-table-column label="用户名" prop="userName" width="120" />
        <el-table-column label="用户ID" prop="userId" width="100" />
        <el-table-column label="币种" prop="currencyType" width="100">
          <template slot-scope="scope">
            <el-tag size="small" :type="scope.row.currencyType === 'USD' ? 'warning' : 'success'">
              {{ getCurrencyLabel(scope.row.currencyType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="方式" prop="withdrawMethod" width="120">
          <template slot-scope="scope">
            {{ getMethodLabel(scope.row.withdrawMethod) }}
          </template>
        </el-table-column>
        <el-table-column label="金额" prop="amount" width="110">
          <template slot-scope="scope">
            {{ formatAmount(scope.row.amount) }}
          </template>
        </el-table-column>
        <el-table-column label="状态" prop="status" width="110">
          <template slot-scope="scope">
            <el-tag size="small" :type="getStatusType(scope.row.status)">
              {{ getStatusLabel(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="提交时间" prop="submitTime" width="170">
          <template slot-scope="scope">
            <span>{{ formatDate(scope.row.submitTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="审核人" prop="reviewUserName" width="120">
          <template slot-scope="scope">
            {{ scope.row.reviewUserName || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="审核时间" prop="reviewTime" width="170">
          <template slot-scope="scope">
            <span>{{ formatDate(scope.row.reviewTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right" width="180">
          <template slot-scope="scope">
            <el-button type="text" size="mini" @click="handleView(scope.row)">详情</el-button>
            <el-button
              v-if="Number(scope.row.status) === 0"
              type="text"
              size="mini"
              @click="handleReview(scope.row)"
            >审核</el-button>
            <el-button type="text" size="mini" @click="handleDelete(scope.row)">删除</el-button>
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

    <el-dialog title="提现详情" :visible.sync="detailVisible" width="720px" append-to-body>
      <el-form :model="detailForm" label-width="110px" size="small">
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="订单号">
              <el-input v-model="detailForm.orderNo" readonly />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="用户名">
              <el-input v-model="detailForm.userName" readonly />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="币种">
              <el-input :value="getCurrencyLabel(detailForm.currencyType)" readonly />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="方式">
              <el-input :value="getMethodLabel(detailForm.withdrawMethod)" readonly />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="金额">
              <el-input :value="formatAmount(detailForm.amount)" readonly />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态">
              <el-input :value="getStatusLabel(detailForm.status)" readonly />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="提交时间">
              <el-input :value="formatDate(detailForm.submitTime)" readonly />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="审核时间">
              <el-input :value="formatDate(detailForm.reviewTime)" readonly />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="审核人">
              <el-input v-model="detailForm.reviewUserName" readonly />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="钱包ID">
              <el-input :value="detailForm.walletId || '-'" readonly />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="12" v-if="detailForm.currencyType === 'USD'">
          <el-col :span="24">
            <el-form-item label="钱包地址">
              <el-input v-model="detailForm.walletAddress" type="textarea" :rows="3" readonly />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="12" v-else>
          <el-col :span="12">
            <el-form-item label="开户行">
              <el-input v-model="detailForm.bankName" readonly />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="账号">
              <el-input v-model="detailForm.accountNo" readonly />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="姓名">
              <el-input v-model="detailForm.accountName" readonly />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="拒绝原因">
          <el-input v-model="detailForm.rejectReason" type="textarea" :rows="3" readonly />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="detailForm.remark" type="textarea" :rows="3" readonly />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="detailVisible = false">关闭</el-button>
      </div>
    </el-dialog>

    <el-dialog title="提现审核" :visible.sync="auditVisible" width="560px" append-to-body>
      <el-form :model="auditForm" label-width="110px" size="small">
        <el-form-item label="订单号">
          <el-input v-model="auditForm.orderNo" readonly />
        </el-form-item>
        <el-form-item label="用户名">
          <el-input v-model="auditForm.userName" readonly />
        </el-form-item>
        <el-form-item label="金额">
          <el-input :value="formatAmount(auditForm.amount)" readonly />
        </el-form-item>
        <el-form-item label="审核结果">
          <el-radio-group v-model="auditForm.status">
            <el-radio :label="1">通过</el-radio>
            <el-radio :label="2">拒绝</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item v-if="Number(auditForm.status) === 2" label="拒绝原因">
          <el-input v-model="auditForm.rejectReason" type="textarea" :rows="3" placeholder="请输入拒绝原因" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="auditVisible = false">取消</el-button>
        <el-button type="primary" @click="submitAudit">提交审核</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { deleteWithdraw, getWithdraw, listWithdraw, reviewWithdraw } from '@/api/operation/withdraw'

export default {
  name: 'WithdrawManagement',
  data() {
    return {
      loading: false,
      showSearch: true,
      withdrawList: [],
      total: 0,
      detailVisible: false,
      auditVisible: false,
      detailForm: {},
      auditForm: {
        withdrawId: null,
        orderNo: '',
        userName: '',
        amount: 0,
        status: 1,
        rejectReason: ''
      },
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        orderNo: undefined,
        userName: undefined,
        currencyType: undefined,
        withdrawMethod: undefined,
        status: undefined
      },
      currencyOptions: [
        { label: '人民币', value: 'CNY' },
        { label: 'USD', value: 'USD' }
      ],
      methodOptions: [
        { label: '银行卡提现', value: 'BANK' },
        { label: 'USDT提现', value: 'USDT' }
      ],
      statusOptions: [
        { label: '待审核', value: 0 },
        { label: '已通过', value: 1 },
        { label: '已拒绝', value: 2 }
      ]
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listWithdraw(this.queryParams)
        .then((res) => {
          this.withdrawList = res.rows || []
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
      this.resetForm('queryForm')
      this.handleQuery()
    },
    formatAmount(value) {
      const amount = Number(value || 0)
      return Number.isNaN(amount) ? '0.00' : amount.toFixed(2)
    },
    formatDate(value) {
      return this.parseTime(value, '{y}-{m}-{d} {h}:{i}:{s}') || '-'
    },
    getCurrencyLabel(value) {
      return String(value).toUpperCase() === 'USD' ? 'USD' : '人民币'
    },
    getMethodLabel(value) {
      return String(value).toUpperCase() === 'USDT' ? 'USDT提现' : '银行卡提现'
    },
    getStatusLabel(value) {
      switch (Number(value)) {
        case 1:
          return '已通过'
        case 2:
          return '已拒绝'
        default:
          return '待审核'
      }
    },
    getStatusType(value) {
      switch (Number(value)) {
        case 1:
          return 'success'
        case 2:
          return 'danger'
        default:
          return 'warning'
      }
    },
    handleView(row) {
      getWithdraw(row.withdrawId)
        .then((res) => {
          this.detailForm = res.data || row
          this.detailVisible = true
        })
        .catch(() => {
          this.detailForm = row
          this.detailVisible = true
        })
    },
    handleReview(row) {
      this.auditForm = {
        withdrawId: row.withdrawId,
        orderNo: row.orderNo,
        userName: row.userName,
        amount: row.amount,
        status: 1,
        rejectReason: ''
      }
      this.auditVisible = true
    },
    submitAudit() {
      if (Number(this.auditForm.status) === 2 && !this.auditForm.rejectReason) {
        this.$modal.msgError('请输入拒绝原因')
        return
      }
      reviewWithdraw(this.auditForm).then(() => {
        this.$modal.msgSuccess('审核成功')
        this.auditVisible = false
        this.getList()
      })
    },
    handleDelete(row) {
      this.$modal.confirm(`确认删除提现订单“${row.orderNo}”吗？`).then(() => {
        return deleteWithdraw(row.withdrawId)
      }).then(() => {
        this.$modal.msgSuccess('删除成功')
        this.getList()
      }).catch(() => {})
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

.header-actions {
  display: flex;
  gap: 8px;
}
</style>
