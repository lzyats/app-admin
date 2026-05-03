<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="团队等级" prop="teamLevel">
        <el-input-number v-model="queryParams.teamLevel" :min="0" :controls="false" placeholder="等级" />
      </el-form-item>
      <el-form-item label="等级名称" prop="teamLevelName">
        <el-input v-model="queryParams.teamLevelName" placeholder="请输入等级名称" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="状态" clearable style="width: 140px">
          <el-option v-for="dict in dict.type.sys_normal_disable" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5"><el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd">新增</el-button></el-col>
      <el-col :span="1.5"><el-button type="success" plain icon="el-icon-edit" size="mini" :disabled="single" @click="handleUpdate">修改</el-button></el-col>
      <el-col :span="1.5"><el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple" @click="handleDelete">删除</el-button></el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="teamLevelList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="teamLevelId" width="90" />
      <el-table-column label="团队等级" align="center" prop="teamLevel" width="90" />
      <el-table-column label="等级名称" align="center" prop="teamLevelName" min-width="120" />
      <el-table-column label="自身等级" align="center" prop="requiredUserLevel" width="100" />
      <el-table-column label="直推有效用户" align="center" prop="requiredDirectUsers" width="120" />
      <el-table-column label="团队有效用户" align="center" prop="requiredTeamUsers" width="120" />
      <el-table-column label="团队总投资(元)" align="center" prop="requiredTeamInvest" width="130" />
      <el-table-column label="奖励(元)" align="center" prop="rewardAmount" width="100" />
      <el-table-column label="团队长加成(‰)" align="center" prop="teamBonusRate" width="120" />
      <el-table-column label="状态" align="center" prop="status" width="100">
        <template slot-scope="scope"><dict-tag :options="dict.type.sys_normal_disable" :value="scope.row.status" /></template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="180">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" :visible.sync="open" width="680px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="130px">
        <el-row>
          <el-col :span="12"><el-form-item label="团队等级" prop="teamLevel"><el-input-number v-model="form.teamLevel" :min="0" :controls="false" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="等级名称" prop="teamLevelName"><el-input v-model="form.teamLevelName" placeholder="例如 一星团队长" /></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="12"><el-form-item label="自身等级" prop="requiredUserLevel"><el-input-number v-model="form.requiredUserLevel" :min="0" :controls="false" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="直推有效用户" prop="requiredDirectUsers"><el-input-number v-model="form.requiredDirectUsers" :min="0" :controls="false" /></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="12"><el-form-item label="团队有效用户" prop="requiredTeamUsers"><el-input-number v-model="form.requiredTeamUsers" :min="0" :controls="false" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="团队总投资(元)" prop="requiredTeamInvest"><el-input-number v-model="form.requiredTeamInvest" :precision="2" :min="0" :controls="false" /></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="12"><el-form-item label="奖励(元)" prop="rewardAmount"><el-input-number v-model="form.rewardAmount" :precision="2" :min="0" :controls="false" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="团队长加成(‰)" prop="teamBonusRate"><el-input-number v-model="form.teamBonusRate" :precision="4" :min="0" :controls="false" /></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="24"><el-form-item label="状态" prop="status"><el-radio-group v-model="form.status"><el-radio v-for="dict in dict.type.sys_normal_disable" :key="dict.value" :label="dict.value">{{ dict.label }}</el-radio></el-radio-group></el-form-item></el-col>
        </el-row>
        <el-form-item label="说明" prop="remark"><el-input v-model="form.remark" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确定</el-button>
        <el-button @click="cancel">取消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listTeamLevel, getTeamLevel, addTeamLevel, updateTeamLevel, delTeamLevel } from '@/api/operation/teamLevel'

export default {
  name: 'TeamLevel',
  dicts: ['sys_normal_disable'],
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      teamLevelList: [],
      title: '',
      open: false,
      queryParams: { pageNum: 1, pageSize: 10, teamLevel: undefined, teamLevelName: undefined, status: undefined },
      form: {},
      rules: {
        teamLevel: [{ required: true, message: '请输入团队等级', trigger: 'blur' }],
        teamLevelName: [{ required: true, message: '请输入等级名称', trigger: 'blur' }],
        requiredUserLevel: [{ required: true, message: '请输入自身等级', trigger: 'blur' }],
        requiredDirectUsers: [{ required: true, message: '请输入直推有效用户数', trigger: 'blur' }],
        requiredTeamUsers: [{ required: true, message: '请输入团队有效用户数', trigger: 'blur' }],
        requiredTeamInvest: [{ required: true, message: '请输入团队总投资', trigger: 'blur' }],
        rewardAmount: [{ required: true, message: '请输入奖励金额', trigger: 'blur' }],
        teamBonusRate: [{ required: true, message: '请输入团队长加成', trigger: 'blur' }],
        status: [{ required: true, message: '请选择状态', trigger: 'change' }]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listTeamLevel(this.queryParams).then(response => {
        this.teamLevelList = response.rows
        this.total = response.total
        this.loading = false
      })
    },
    cancel() {
      this.open = false
      this.reset()
    },
    reset() {
      this.form = {
        teamLevelId: undefined,
        teamLevel: 0,
        teamLevelName: undefined,
        requiredUserLevel: 0,
        requiredDirectUsers: 0,
        requiredTeamUsers: 0,
        requiredTeamInvest: 0,
        rewardAmount: 0,
        teamBonusRate: 0,
        status: '0',
        remark: undefined
      }
      this.resetForm('form')
    },
    handleQuery() { this.queryParams.pageNum = 1; this.getList() },
    resetQuery() { this.resetForm('queryForm'); this.handleQuery() },
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.teamLevelId)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '新增团队等级'
    },
    handleUpdate(row) {
      this.reset()
      const teamLevelId = row.teamLevelId || this.ids[0]
      getTeamLevel(teamLevelId).then(response => {
        this.form = response.data
        this.open = true
        this.title = '修改团队等级'
      })
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        const payload = { ...this.form }
        if (payload.teamLevelId) {
          updateTeamLevel(payload).then(() => {
            this.$modal.msgSuccess('修改成功')
            this.open = false
            this.getList()
          })
        } else {
          addTeamLevel(payload).then(() => {
            this.$modal.msgSuccess('新增成功')
            this.open = false
            this.getList()
          })
        }
      })
    },
    handleDelete(row) {
      const ids = row.teamLevelId ? [row.teamLevelId] : this.ids
      this.$modal.confirm('是否确认删除团队等级编号为"' + ids.join(',') + '"的数据项？').then(() => {
        return delTeamLevel(ids.join(','))
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      }).catch(() => {})
    }
  }
}
</script>
