<template>
  <div class="app-container">
    <el-card>
      <template slot="header">
        <div class="card-header">
          <span>余额宝订单</span>
        </div>
      </template>

      <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch">
        <el-form-item label="订单号" prop="orderNo">
          <el-input v-model="queryParams.orderNo" placeholder="请输入订单号" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="用户ID" prop="userId">
          <el-input v-model="queryParams.userId" placeholder="请输入用户ID" clearable style="width: 160px" />
        </el-form-item>
        <el-form-item label="用户名" prop="userName">
          <el-input v-model="queryParams.userName" placeholder="请输入用户名" clearable style="width: 180px" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 120px">
            <el-option label="持有中" value="0" />
            <el-option label="已赎回" value="1" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" size="small" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" size="small" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="orderList" border style="width: 100%">
        <el-table-column label="订单ID" prop="orderId" width="90" />
        <el-table-column label="订单号" prop="orderNo" min-width="180" />
        <el-table-column label="用户ID" prop="userId" width="90" />
        <el-table-column label="用户名" prop="userName" min-width="120" />
        <el-table-column label="份数" prop="shares" width="90" />
        <el-table-column label="本金" prop="principalAmount" width="110">
          <template slot-scope="scope">{{ formatAmount(scope.row.principalAmount) }}</template>
        </el-table-column>
        <el-table-column label="年化收益率" prop="annualRate" width="110">
          <template slot-scope="scope">{{ formatRate(scope.row.annualRate) }}</template>
        </el-table-column>
        <el-table-column label="已结算收益" prop="settledIncome" width="120">
          <template slot-scope="scope">{{ formatAmount(scope.row.settledIncome) }}</template>
        </el-table-column>
        <el-table-column label="购买时间" prop="investTime" width="170" />
        <el-table-column label="下次结算时间" prop="nextSettleTime" width="170" />
        <el-table-column label="状态" prop="status" width="90">
          <template slot-scope="scope">
            <el-tag size="small" :type="scope.row.status === '0' ? 'success' : 'info'">
              {{ scope.row.status === '0' ? '持有中' : '已赎回' }}
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
import { listYebaoOrder } from '@/api/system/yebao/order'

export default {
  name: 'YebaoOrder',
  data() {
    return {
      loading: false,
      showSearch: true,
      orderList: [],
      total: 0,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        orderNo: null,
        userId: null,
        userName: null,
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
    formatRate(value) {
      return Number(value || 0).toFixed(4) + '%'
    },
    getList() {
      this.loading = true
      listYebaoOrder(this.queryParams)
        .then((res) => {
          this.orderList = res.rows || []
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
