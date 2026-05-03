<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="矿机名称" prop="minerName">
        <el-input v-model="queryParams.minerName" placeholder="请输入矿机名称" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="矿机等级" prop="minerLevel">
        <el-input-number v-model="queryParams.minerLevel" :min="0" :controls="false" placeholder="等级" />
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

    <el-table v-loading="loading" :data="minerList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="minerId" width="90" />
      <el-table-column label="封面" align="center" width="90">
        <template slot-scope="scope">
          <el-image v-if="scope.row.coverImage" :src="getCoverImageUrl(scope.row.coverImage)" fit="cover" style="width: 56px; height: 40px; border-radius: 6px" />
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="矿机名称" align="center" prop="minerName" min-width="160" />
      <el-table-column label="等级" align="center" prop="minerLevel" width="90" />
      <el-table-column label="功率" align="center" prop="power" width="90" />
      <el-table-column label="日产出WAG" align="center" prop="wagPerDay" width="120" />
      <el-table-column label="可领取等级" align="center" min-width="140">
        <template slot-scope="scope">
          {{ scope.row.minUserLevel }} - {{ scope.row.maxUserLevel }}
        </template>
      </el-table-column>

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
        <el-form-item label="矿机名称" prop="minerName">
          <el-input v-model="form.minerName" placeholder="请输入矿机名称" />
        </el-form-item>
        <el-form-item label="矿机等级" prop="minerLevel">
          <el-input-number v-model="form.minerLevel" :min="0" :controls="false" />
        </el-form-item>
        <el-form-item label="功率" prop="power">
          <el-input-number v-model="form.power" :min="0" :controls="false" />
        </el-form-item>
        <el-form-item label="日收益WAG" prop="wagPerDay">
          <el-input v-model="form.wagPerDay" placeholder="例如 100" />
        </el-form-item>
        <el-form-item label="最小可领等级" prop="minUserLevel">
          <el-select v-model="form.minUserLevel" placeholder="请选择最小等级" clearable style="width: 100%">
            <el-option v-for="item in userLevelOptions" :key="item.levelId || item.level" :label="userLevelLabel(item)" :value="item.level" />
          </el-select>
        </el-form-item>
        <el-form-item label="最大可领等级" prop="maxUserLevel">
          <el-select v-model="form.maxUserLevel" placeholder="请选择最大等级" clearable style="width: 100%">
            <el-option v-for="item in userLevelOptions" :key="(item.levelId || item.level) + '_max'" :label="userLevelLabel(item)" :value="item.level" />
          </el-select>
        </el-form-item>
        <el-form-item label="封面图" prop="coverImage">
          <image-upload v-model="form.coverImage" :limit="1" :is-show-tip="false" />
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
import { listMiner, getMiner, addMiner, updateMiner, delMiner } from '@/api/operation/miner'
import { listUserLevelOptions } from '@/api/operation/userLevel'

export default {
  name: 'Miner',
  dicts: ['sys_normal_disable'],
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      minerList: [],
      userLevelOptions: [],
      title: '',
      open: false,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        minerName: undefined,
        minerLevel: undefined,
        status: undefined
      },
      form: {},
      rules: {
        minerName: [{ required: true, message: '请输入矿机名称', trigger: 'blur' }],
        wagPerDay: [{ required: true, message: '请输入日收益WAG', trigger: 'blur' }],
        status: [{ required: true, message: '请选择状态', trigger: 'change' }]
      }
    }
  },
  created() {
    this.getList()
    this.getUserLevelOptions()
  },
  methods: {
    getUserLevelOptions() {
      listUserLevelOptions().then(res => {
        this.userLevelOptions = Array.isArray(res.data) ? res.data : []
      }).catch(() => {
        this.userLevelOptions = []
      })
    },
    userLevelLabel(row) {
      if (!row) return ''
      const level = row.level
      const name = row.levelName
      if (name && (level === 0 || level)) return `${name}（${level}）`
      if (name) return name
      if (level === 0 || level) return String(level)
      return ''
    },
    getList() {
      this.loading = true
      listMiner(this.queryParams).then(response => {
        this.minerList = response.rows
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
        minerId: undefined,
        minerName: undefined,
        minerLevel: 0,
        power: 0,
        wagPerDay: undefined,
        minUserLevel: 0,
        maxUserLevel: 999,
        coverImage: undefined,
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
      this.ids = selection.map(item => item.minerId)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '新增矿机'
    },
    handleUpdate(row) {
      this.reset()
      const minerId = row.minerId || this.ids[0]
      getMiner(minerId).then(response => {
        this.form = response.data
        this.open = true
        this.title = '修改矿机'
      })
    },
    getCoverImageUrl(url) {
      if (!url) {
        return ''
      }
      if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('data:')) {
        return url
      }
      return process.env.VUE_APP_BASE_API + url
    },
    submitForm() {
      this.$refs['form'].validate(valid => {
        if (!valid) return
        const minLevel = Number(this.form.minUserLevel)
        const maxLevel = Number(this.form.maxUserLevel)
        if (!Number.isNaN(minLevel) && !Number.isNaN(maxLevel) && minLevel > maxLevel) {
          this.$modal.msgError('最小可领等级不能大于最大可领等级')
          return
        }
        const payload = {
          ...this.form,
          coverImage: this.normalizeImageValue(this.form.coverImage)
        }
        if (payload.minerId) {
          updateMiner(payload).then(() => {
            this.$modal.msgSuccess('修改成功')
            this.open = false
            this.getList()
          })
        } else {
          addMiner(payload).then(() => {
            this.$modal.msgSuccess('新增成功')
            this.open = false
            this.getList()
          })
        }
      })
    },
    normalizeImageValue(value) {
      if (Array.isArray(value)) {
        const first = value.find(item => typeof item === 'string' && item)
        return first || ''
      }
      if (value && typeof value === 'object') {
        if (typeof value.url === 'string' && value.url) {
          return value.url
        }
        if (typeof value.name === 'string' && value.name) {
          return value.name
        }
      }
      return typeof value === 'string' ? value : ''
    },
    handleDelete(row) {
      const minerIds = row.minerId ? [row.minerId] : this.ids
      this.$modal.confirm('是否确认删除矿机编号为"' + minerIds.join(',') + '"的数据项？').then(() => {
        return delMiner(minerIds.join(','))
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      }).catch(() => {})
    }
  }
}
</script>
