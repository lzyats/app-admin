<template>
  <div class="app-container">
    <el-card>
      <template slot="header">
        <div class="page-header">
          <span>积分账变管理</span>
          <el-button icon="el-icon-refresh" size="mini" @click="getList">刷新</el-button>
        </div>
      </template>

      <el-form :model="queryParams" :inline="true" v-show="showSearch" size="small" label-width="80px">
        <el-form-item label="用户名" prop="userName">
          <el-input v-model="queryParams.userName" placeholder="请输入用户名" clearable style="width: 180px" @keyup.enter.native="handleQuery" />
        </el-form-item>
        <el-form-item label="变动类型" prop="changeType">
          <el-select v-model="queryParams.changeType" placeholder="全部" clearable style="width: 140px">
            <el-option label="获得" value="earn" />
            <el-option label="消耗" value="spend" />
            <el-option label="调整" value="adjust" />
            <el-option label="冻结" value="freeze" />
            <el-option label="解冻" value="unfreeze" />
          </el-select>
        </el-form-item>
        <el-form-item label="来源类型" prop="sourceType">
          <el-select v-model="queryParams.sourceType" placeholder="全部" clearable style="width: 140px">
            <el-option label="投资" value="invest" />
            <el-option label="活动" value="activity" />
            <el-option label="兑换" value="redeem" />
            <el-option label="抽奖" value="lottery" />
            <el-option label="手工" value="manual" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" size="small" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" size="small" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="logList" border>
        <el-table-column label="账变ID" prop="logId" width="100" />
        <el-table-column label="用户名" prop="userName" width="120" />
        <el-table-column label="用户ID" prop="userId" width="100" />
        <el-table-column label="变动积分" prop="points" width="110" />
        <el-table-column label="变动前" prop="pointsBefore" width="110" />
        <el-table-column label="变动后" prop="pointsAfter" width="110" />
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
import { listPointLog } from '@/api/system/point'

export default {
  name: 'PointLogManagement',
  data() {
    return {
      loading: false,
      showSearch: true,
      logList: [],
      total: 0,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userName: undefined,
        changeType: undefined,
        sourceType: undefined
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listPointLog(this.queryParams)
        .then((res) => {
          this.logList = res.rows || []
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
