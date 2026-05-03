<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="等级编号" prop="level">
        <el-input-number v-model="queryParams.level" :min="0" :controls="false" placeholder="等级" />
      </el-form-item>
      <el-form-item label="等级名称" prop="levelName">
        <el-input v-model="queryParams.levelName" placeholder="请输入等级名称" clearable @keyup.enter.native="handleQuery" />
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
      <el-col :span="1.5">
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain icon="el-icon-edit" size="mini" :disabled="single" @click="handleUpdate">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple" @click="handleDelete">删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="userLevelList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="levelId" width="90" />
      <el-table-column label="等级" align="center" prop="level" width="90" />
      <el-table-column label="名称" align="center" prop="levelName" min-width="160" />
      <el-table-column label="所需成长值" align="center" prop="requiredGrowthValue" min-width="160" />
      <el-table-column label="投资加成(%)" align="center" prop="investBonus" min-width="140" />

      <el-table-column label="状态" align="center" prop="status" width="100">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.sys_normal_disable" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="说明" align="center" prop="remark" :show-overflow-tooltip="true" />
      <el-table-column label="操作" align="center" width="180" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" :visible.sync="open" width="560px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="等级编号" prop="level">
          <el-input-number v-model="form.level" :min="0" :controls="false" />
        </el-form-item>
        <el-form-item label="等级名称" prop="levelName">
          <el-input v-model="form.levelName" placeholder="例如 VIP.1" />
        </el-form-item>
        <el-form-item label="所需成长值" prop="requiredGrowthValue">
          <el-input-number v-model="form.requiredGrowthValue" :min="0" :controls="false" placeholder="例如 1000" />
        </el-form-item>
        <el-form-item label="投资加成(%)" prop="investBonus">
          <el-input v-model="form.investBonus" placeholder="例如 5 表示加成 5%" />
        </el-form-item>

        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio v-for="dict in dict.type.sys_normal_disable" :key="dict.value" :label="dict.value">{{ dict.label }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="说明" prop="remark">
          <el-input v-model="form.remark" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确定</el-button>
        <el-button @click="cancel">取消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listUserLevel, getUserLevel, addUserLevel, updateUserLevel, delUserLevel } from '@/api/operation/userLevel'

export default {
  name: 'UserLevel',
  dicts: ['sys_normal_disable'],
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      userLevelList: [],
      title: '',
      open: false,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        level: undefined,
        levelName: undefined,
        status: undefined
      },
      form: {},
      rules: {
        level: [{ required: true, message: '请输入等级编号', trigger: 'blur' }],
        levelName: [{ required: true, message: '请输入等级名称', trigger: 'blur' }],
        requiredGrowthValue: [{ required: true, message: '请输入所需成长值', trigger: 'blur' }],
        investBonus: [{ required: true, message: '请输入投资加成', trigger: 'blur' }],
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
      listUserLevel(this.queryParams).then(response => {
        this.userLevelList = response.rows
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
        levelId: undefined,
        level: 0,
        levelName: undefined,
        requiredGrowthValue: 0,
        investBonus: '0',
        status: '0',
        remark: undefined
      }
      this.resetForm('form')
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.resetForm('queryForm')
      this.handleQuery()
    },
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.levelId)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '新增用户等级'
    },
    handleUpdate(row) {
      this.reset()
      const levelId = row.levelId || this.ids[0]
      getUserLevel(levelId).then(response => {
        this.form = response.data
        this.open = true
        this.title = '修改用户等级'
      })
    },
    submitForm() {
      this.$refs['form'].validate(valid => {
        if (!valid) return
        const payload = { ...this.form }
        if (payload.levelId) {
          updateUserLevel(payload).then(() => {
            this.$modal.msgSuccess('修改成功')
            this.open = false
            this.getList()
          })
        } else {
          addUserLevel(payload).then(() => {
            this.$modal.msgSuccess('新增成功')
            this.open = false
            this.getList()
          })
        }
      })
    },
    handleDelete(row) {
      const levelIds = row.levelId ? [row.levelId] : this.ids
      this.$modal.confirm('是否确认删除用户等级编号为"' + levelIds.join(',') + '"的数据项？').then(() => {
        return delUserLevel(levelIds.join(','))
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      }).catch(() => {})
    }
  }
}
</script>
