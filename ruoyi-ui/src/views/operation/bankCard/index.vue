<template>
  <div class="app-container">
    <el-card>
      <template slot="header">
        <div class="page-header">
          <span>银行卡管理</span>
          <div class="header-actions">
            <el-button icon="el-icon-refresh" size="mini" @click="getList">刷新</el-button>
          </div>
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
        <el-form-item label="用户ID" prop="userId">
          <el-input
            v-model="queryParams.userId"
            placeholder="请输入用户ID"
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
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" size="small" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" size="small" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="bankCardList" border>
        <el-table-column label="卡ID" prop="bankCardId" width="90" />
        <el-table-column label="用户ID" prop="userId" width="100" />
        <el-table-column label="用户名" prop="userName" min-width="120" />
        <el-table-column label="币种" prop="currencyType" width="100">
          <template slot-scope="scope">
            <el-tag size="small" :type="scope.row.currencyType === 'USD' ? 'warning' : 'success'">
              {{ getCurrencyLabel(scope.row.currencyType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="绑定信息" min-width="280">
          <template slot-scope="scope">
            <span v-if="scope.row.currencyType === 'USD'">
              {{ scope.row.walletAddress || '-' }}
            </span>
            <span v-else>
              {{ scope.row.bankName || '-' }} / {{ scope.row.accountNo || '-' }} / {{ scope.row.accountName || '-' }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" prop="createTime" width="170">
          <template slot-scope="scope">
            <span>{{ formatDate(scope.row.createTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="备注" prop="remark" min-width="160">
          <template slot-scope="scope">
            {{ scope.row.remark || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template slot-scope="scope">
            <el-button type="text" size="mini" @click="handleView(scope.row)">详情</el-button>
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

    <el-dialog title="银行卡详情" :visible.sync="detailVisible" width="680px" append-to-body>
      <el-form :model="detailForm" label-width="100px" size="small">
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="卡ID">
              <el-input v-model="detailForm.bankCardId" readonly />
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
            <el-form-item label="用户ID">
              <el-input v-model="detailForm.userId" readonly />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="币种">
              <el-input :value="getCurrencyLabel(detailForm.currencyType)" readonly />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item v-if="detailForm.currencyType === 'USD'" label="钱包地址">
          <el-input v-model="detailForm.walletAddress" type="textarea" :rows="3" readonly />
        </el-form-item>
        <template v-else>
          <el-row :gutter="12">
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
          </el-row>
          <el-form-item label="姓名">
            <el-input v-model="detailForm.accountName" readonly />
          </el-form-item>
        </template>
        <el-form-item label="备注">
          <el-input v-model="detailForm.remark" type="textarea" :rows="3" readonly />
        </el-form-item>
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="创建时间">
              <el-input :value="formatDate(detailForm.createTime)" readonly />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="更新时间">
              <el-input :value="formatDate(detailForm.updateTime)" readonly />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="detailVisible = false">关闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { deleteBankCard, getBankCard, listBankCard } from '@/api/operation/bankCard'

export default {
  name: 'OperationBankCard',
  data() {
    return {
      loading: false,
      showSearch: true,
      bankCardList: [],
      total: 0,
      detailVisible: false,
      detailForm: {},
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userId: undefined,
        userName: undefined,
        currencyType: undefined
      },
      currencyOptions: [
        { label: '人民币', value: 'CNY' },
        { label: 'USD', value: 'USD' }
      ]
    }
  },
  created() {
    this.initPage()
  },
  methods: {
    initPage() {
      const { userId, userName, currencyType } = this.$route.query
      if (userId) {
        this.queryParams.userId = userId
      }
      if (userName) {
        this.queryParams.userName = userName
      }
      if (currencyType) {
        this.queryParams.currencyType = currencyType
      }
      this.getList()
    },
    getList() {
      this.loading = true
      listBankCard(this.queryParams)
        .then((res) => {
          this.bankCardList = res.rows || []
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
    formatDate(value) {
      return this.parseTime(value, '{y}-{m}-{d} {h}:{i}:{s}') || '-'
    },
    getCurrencyLabel(value) {
      return String(value).toUpperCase() === 'USD' ? 'USD' : '人民币'
    },
    handleView(row) {
      getBankCard(row.bankCardId)
        .then((res) => {
          this.detailForm = res.data || row
          this.detailVisible = true
        })
        .catch(() => {
          this.detailForm = row
          this.detailVisible = true
        })
    },
    handleDelete(row) {
      this.$modal.confirm(`确认删除卡ID为“${row.bankCardId}”的银行卡吗？`).then(() => {
        return deleteBankCard(row.bankCardId)
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
