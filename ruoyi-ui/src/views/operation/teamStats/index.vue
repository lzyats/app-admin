<template>
  <div class="app-container">
    <el-card class="box-card" shadow="never">
      <div slot="header" class="clearfix">
        <span>我的团队统计（夜间快照）</span>
        <div style="float: right;">
          <el-tag type="info" size="mini">统计层级: {{ calcDepth }}</el-tag>
          <el-tag type="success" size="mini" style="margin-left: 8px;">最近统计: {{ lastCalcDate || '-' }}</el-tag>
          <el-button
            v-hasPermi="['system:teamStats:rebuild']"
            type="primary"
            size="mini"
            icon="el-icon-refresh"
            style="margin-left: 12px;"
            @click="handleRebuild"
          >
            手动重算
          </el-button>
        </div>
      </div>

      <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" label-width="88px">
        <el-form-item label="用户ID" prop="userId">
          <el-input v-model="queryParams.userId" placeholder="请输入用户ID" clearable style="width: 160px" />
        </el-form-item>
        <el-form-item label="用户名" prop="userName">
          <el-input v-model="queryParams.userName" placeholder="请输入用户名" clearable style="width: 180px" />
        </el-form-item>
        <el-form-item label="团队等级" prop="teamLevel">
          <el-input-number v-model="queryParams.teamLevel" :min="0" :controls="false" style="width: 140px" />
        </el-form-item>
        <el-form-item label="统计日期">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            value-format="yyyy-MM-dd"
            range-separator="-"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            style="width: 240px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="statList" border>
        <el-table-column label="用户ID" prop="userId" width="100" />
        <el-table-column label="用户名" prop="userName" width="120" />
        <el-table-column label="昵称" prop="nickName" width="120" />
        <el-table-column label="团队级别" prop="teamLevel" width="90" />
        <el-table-column label="直推人数" prop="directUserCount" width="90" />
        <el-table-column label="直推有效" prop="directValidUserCount" width="90" />
        <el-table-column label="团队人数" prop="teamUserCount" width="90" />
        <el-table-column label="团队有效" prop="teamValidUserCount" width="90" />
        <el-table-column label="团队总资产" prop="teamTotalAsset" min-width="120" />
        <el-table-column label="团队总投资" prop="teamTotalInvest" min-width="120" />
        <el-table-column label="统计日期" prop="calcDate" width="110" />
      </el-table>

      <pagination
        v-show="total > 0"
        :total="total"
        :page.sync="queryParams.pageNum"
        :limit.sync="queryParams.pageSize"
        @pagination="getList"
      />
    </el-card>

    <el-card class="box-card" shadow="never" style="margin-top: 12px;">
      <div slot="header" class="clearfix">
        <span>事件流水（注册/充值/投资）</span>
      </div>
      <el-form :model="eventQuery" ref="eventQueryForm" size="small" :inline="true" label-width="88px">
        <el-form-item label="上级ID" prop="ownerUserId">
          <el-input v-model="eventQuery.ownerUserId" placeholder="ownerUserId" clearable style="width: 160px" />
        </el-form-item>
        <el-form-item label="下级ID" prop="memberUserId">
          <el-input v-model="eventQuery.memberUserId" placeholder="memberUserId" clearable style="width: 160px" />
        </el-form-item>
        <el-form-item label="类型" prop="eventType">
          <el-select v-model="eventQuery.eventType" clearable placeholder="全部" style="width: 140px">
            <el-option label="REGISTER" value="REGISTER" />
            <el-option label="RECHARGE" value="RECHARGE" />
            <el-option label="INVEST" value="INVEST" />
          </el-select>
        </el-form-item>
        <el-form-item label="统计日" prop="statDate">
          <el-date-picker v-model="eventQuery.statDate" type="date" value-format="yyyy-MM-dd" placeholder="选择日期" style="width: 160px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" size="mini" @click="handleEventQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" size="mini" @click="resetEventQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="eventLoading" :data="eventList" border>
        <el-table-column label="事件ID" prop="eventId" width="90" />
        <el-table-column label="统计日" prop="statDate" width="110" />
        <el-table-column label="上级ID" prop="ownerUserId" width="90" />
        <el-table-column label="下级ID" prop="memberUserId" width="90" />
        <el-table-column label="层级" prop="relationDepth" width="70" />
        <el-table-column label="类型" prop="eventType" width="100" />
        <el-table-column label="金额" prop="eventAmount" width="110" />
        <el-table-column label="有效用户" prop="isValidUser" width="90" />
        <el-table-column label="业务键" prop="bizKey" min-width="130" />
        <el-table-column label="事件时间" prop="eventTime" width="170" />
      </el-table>

      <pagination
        v-show="eventTotal > 0"
        :total="eventTotal"
        :page.sync="eventQuery.pageNum"
        :limit.sync="eventQuery.pageSize"
        @pagination="getEventList"
      />
    </el-card>
  </div>
</template>

<script>
import { listTeamStats, listTeamStatEvents, getTeamStatsConfig, rebuildTeamStats } from '@/api/operation/teamStats'

export default {
  name: 'TeamStats',
  data() {
    return {
      loading: false,
      total: 0,
      statList: [],
      dateRange: [],
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userId: undefined,
        userName: undefined,
        teamLevel: undefined
      },
      eventLoading: false,
      eventTotal: 0,
      eventList: [],
      eventQuery: {
        pageNum: 1,
        pageSize: 10,
        ownerUserId: undefined,
        memberUserId: undefined,
        eventType: undefined,
        statDate: undefined
      },
      calcDepth: 3,
      lastCalcDate: ''
    }
  },
  created() {
    this.getConfig()
    this.getList()
    this.getEventList()
  },
  methods: {
    getConfig() {
      getTeamStatsConfig().then(res => {
        this.calcDepth = res.data ? res.data.calcDepth : 3
        this.lastCalcDate = res.data ? res.data.lastCalcDate : ''
      })
    },
    getList() {
      this.loading = true
      listTeamStats(this.addDateRange(this.queryParams, this.dateRange)).then(res => {
        this.statList = res.rows || []
        this.total = res.total || 0
      }).finally(() => {
        this.loading = false
      })
    },
    getEventList() {
      this.eventLoading = true
      listTeamStatEvents(this.eventQuery).then(res => {
        this.eventList = res.rows || []
        this.eventTotal = res.total || 0
      }).finally(() => {
        this.eventLoading = false
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
      this.getList()
    },
    handleEventQuery() {
      this.eventQuery.pageNum = 1
      this.getEventList()
    },
    resetEventQuery() {
      this.resetForm('eventQueryForm')
      this.eventQuery.pageNum = 1
      this.eventQuery.pageSize = 10
      this.getEventList()
    },
    handleRebuild() {
      this.$prompt('请输入统计日期（yyyy-MM-dd），留空则重算昨天', '手动重算', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        inputPattern: /^$|^\d{4}-\d{2}-\d{2}$/,
        inputErrorMessage: '日期格式错误'
      }).then(({ value }) => {
        return rebuildTeamStats(value || '')
      }).then(() => {
        this.$modal.msgSuccess('重算已完成')
        this.getConfig()
        this.getList()
        this.getEventList()
      }).catch(() => {})
    }
  }
}
</script>
