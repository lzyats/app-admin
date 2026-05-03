<template>
  <div class="app-container">
    <el-card>
      <template slot="header">
        <div class="card-header">
          <span>收益流水</span>
        </div>
      </template>

      <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch">
        <el-form-item label="流水号" prop="incomeNo">
          <el-input v-model="queryParams.incomeNo" placeholder="请输入流水号" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="订单号" prop="orderNo">
          <el-input v-model="queryParams.orderNo" placeholder="请输入订单号" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="用户ID" prop="userId">
          <el-input v-model="queryParams.userId" placeholder="请输入用户ID" clearable style="width: 160px" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 120px">
            <el-option label="成功" value="0" />
            <el-option label="失败" value="1" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" size="small" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" size="small" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="incomeList" border style="width: 100%">
        <el-table-column label="流水ID" prop="incomeId" width="90" />
        <el-table-column label="流水号" prop="incomeNo" min-width="180" />
        <el-table-column label="订单号" prop="orderNo" min-width="180" />
        <el-table-column label="用户ID" prop="userId" width="90" />
        <el-table-column label="用户名" prop="userName" min-width="120" />
        <el-table-column label="结算天数" prop="settleDays" width="90" />
        <el-table-column label="收益金额" prop="incomeAmount" width="120">
          <template slot-scope="scope">{{ formatAmount(scope.row.incomeAmount) }}</template>
        </el-table-column>
        <el-table-column label="结算时间" prop="settleTime" width="170" />
        <el-table-column label="状态" prop="status" width="90">
          <template slot-scope="scope">
            <el-tag size="small" :type="scope.row.status === '0' ? 'success' : 'danger'">
              {{ scope.row.status === '0' ? '成功' : '失败' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="备注" prop="remark" min-width="150" />
      </el-table>

      <pagination
        v-show="total > 0"
        :total="total"
        :page.sync="queryParams.pageNum"
        :limit.sync="queryParams.pageSize"
        @pagination="getList"
      />
    </el-card>
  </div>
</template>

<script>
import { listYebaoIncome } from '@/api/system/yebao/income'

export default {
  name: 'YebaoIncome',
  data() {
    return {
      loading: false,
      showSearch: true,
      incomeList: [],
      total: 0,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        incomeNo: null,
        orderNo: null,
        userId: null,
        status: null
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
    getList() {
      this.loading = true
      listYebaoIncome(this.queryParams)
        .then((res) => {
          this.incomeList = res.rows || []
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
