<template>
  <div class="app-container">
    <el-card>
      <template slot="header">
        <div class="card-header">
          <span>投资订单</span>
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
          <el-option label="已完成" value="1" />
          <el-option label="已赎回/取消" value="2" />
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
        <el-table-column label="产品名称" prop="productName" min-width="140" />
        <el-table-column label="币种" prop="currency" width="90" />
        <el-table-column label="投资金额" prop="investAmount" width="120">
          <template slot-scope="scope">{{ formatAmount(scope.row.investAmount) }}</template>
        </el-table-column>
        <el-table-column label="生效利率(%)" prop="effectiveRate" width="120">
          <template slot-scope="scope">{{ formatRate(scope.row.effectiveRate) }}</template>
        </el-table-column>
        <el-table-column label="预计收益" prop="expectedIncome" width="120">
          <template slot-scope="scope">{{ formatAmount(scope.row.expectedIncome) }}</template>
        </el-table-column>
        <el-table-column label="周期(天)" prop="cycleDays" width="90" />
        <el-table-column label="下单时间" prop="createTime" width="170" />
        <el-table-column label="到期时间" prop="endTime" width="170" />
        <el-table-column label="状态" prop="status" width="90">
          <template slot-scope="scope">
            <el-tag size="small" :type="scope.row.status === '0' ? 'success' : (scope.row.status === '1' ? 'info' : 'warning')">
              {{ scope.row.status === '0' ? '持有中' : (scope.row.status === '1' ? '已完成' : '已赎回') }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="备注" prop="remark" min-width="150" />
        <el-table-column label="操作" align="center" width="220">
          <template slot-scope="scope">
            <el-button
              type="text"
              size="mini"
              @click="handleDetail(scope.row)"
            >
              详情
            </el-button>
            <el-button
              v-if="scope.row.status === '0'"
              type="text"
              size="mini"
              @click="handleRedeem(scope.row)"
            >
              赎回
            </el-button>
            <el-button
              v-if="scope.row.status === '0'"
              type="text"
              size="mini"
              @click="handleSettle(scope.row)"
            >
              结算
            </el-button>
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

    <el-dialog title="订单详情" :visible.sync="detailOpen" width="900px" append-to-body>
      <el-descriptions v-if="detailData.order" :column="3" border size="small">
        <el-descriptions-item label="订单号">{{ detailData.order.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="用户">{{ detailData.order.userName }} ({{ detailData.order.userId }})</el-descriptions-item>
        <el-descriptions-item label="状态">
          {{ detailData.order.status === '0' ? '持有中' : (detailData.order.status === '1' ? '已完成' : '已赎回') }}
        </el-descriptions-item>
        <el-descriptions-item label="产品">{{ detailData.order.productName }}</el-descriptions-item>
        <el-descriptions-item label="币种">{{ detailData.order.currency }}</el-descriptions-item>
        <el-descriptions-item label="投资金额">{{ formatAmount(detailData.order.investAmount) }}</el-descriptions-item>
        <el-descriptions-item label="未结算本金">{{ formatAmount(detailData.pendingPrincipal) }}</el-descriptions-item>
        <el-descriptions-item label="未结算收益">{{ formatAmount(detailData.pendingInterest) }}</el-descriptions-item>
        <el-descriptions-item label="已结算收益">{{ formatAmount(detailData.settledInterest) }}</el-descriptions-item>
      </el-descriptions>

      <el-table :data="detailData.plans || []" border size="mini" style="margin-top: 16px;">
        <el-table-column label="计划ID" prop="planId" width="90" />
        <el-table-column label="类型" prop="planType" width="90">
          <template slot-scope="scope">
            {{ scope.row.planType === 'PRINCIPAL' ? '本金' : '收益' }}
          </template>
        </el-table-column>
        <el-table-column label="阶段" prop="stageNo" width="80" />
        <el-table-column label="计划时间" prop="planTime" min-width="160" />
        <el-table-column label="金额" prop="planAmount" width="120">
          <template slot-scope="scope">{{ formatAmount(scope.row.planAmount) }}</template>
        </el-table-column>
        <el-table-column label="状态" prop="status" width="90">
          <template slot-scope="scope">
            <el-tag size="mini" :type="scope.row.status === '1' ? 'success' : (scope.row.status === '2' ? 'info' : 'warning')">
              {{ scope.row.status === '1' ? '已执行' : (scope.row.status === '2' ? '已取消' : '待执行') }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="执行时间" prop="execTime" min-width="160" />
      </el-table>
    </el-dialog>
  </div>
</template>

<script>
import { listYebaoOrder, redeemInvestOrder, settleInvestOrder, getYebaoOrderDetail } from '@/api/system/yebao/order'

export default {
  name: 'YebaoOrder',
  data() {
    return {
      loading: false,
      showSearch: true,
      orderList: [],
      total: 0,
      detailOpen: false,
      detailData: {
        order: null,
        plans: [],
        pendingPrincipal: 0,
        pendingInterest: 0,
        settledInterest: 0
      },
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
    },
    handleRedeem(row) {
      this.$prompt('请输入“确认赎回”后继续，仅退还本金，不再计算后续利率收益。', '二次确认', {
        confirmButtonText: '确认赎回',
        cancelButtonText: '取消',
        inputPlaceholder: '请输入：确认赎回',
        inputValidator: (value) => value === '确认赎回',
        inputErrorMessage: '输入内容必须是“确认赎回”'
      }).then(({ value }) => {
        return this.$prompt('请输入 Google 验证码后执行赎回', 'Google 验证', {
          confirmButtonText: '确认提交',
          cancelButtonText: '取消',
          inputPattern: /^\d{6}$/,
          inputErrorMessage: '请输入 6 位数字验证码'
        }).then(({ value: googleCode }) => {
          return redeemInvestOrder({ orderId: row.orderId, confirmText: value, googleCode })
        })
      }).then(() => {
        this.$modal.msgSuccess('赎回成功')
        this.getList()
      }).catch(() => {})
    },
    handleSettle(row) {
      this.$prompt('请输入“确认结算”后继续，系统将把该订单未结算本金和收益一次性全部结算。', '二次确认', {
        confirmButtonText: '确认结算',
        cancelButtonText: '取消',
        inputPlaceholder: '请输入：确认结算',
        inputValidator: (value) => value === '确认结算',
        inputErrorMessage: '输入内容必须是“确认结算”'
      }).then(({ value }) => {
        return this.$prompt('请输入 Google 验证码后执行结算', 'Google 验证', {
          confirmButtonText: '确认提交',
          cancelButtonText: '取消',
          inputPattern: /^\d{6}$/,
          inputErrorMessage: '请输入 6 位数字验证码'
        }).then(({ value: googleCode }) => {
          return settleInvestOrder({ orderId: row.orderId, confirmText: value, googleCode })
        })
      }).then(() => {
        this.$modal.msgSuccess('结算成功')
        this.getList()
      }).catch(() => {})
    },
    handleDetail(row) {
      getYebaoOrderDetail(row.orderId).then((res) => {
        this.detailData = res.data || {
          order: null,
          plans: [],
          pendingPrincipal: 0,
          pendingInterest: 0,
          settledInterest: 0
        }
        this.detailOpen = true
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
