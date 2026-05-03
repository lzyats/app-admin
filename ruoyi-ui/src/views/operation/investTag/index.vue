<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="90px">
      <el-form-item label="标签名称" prop="tagName">
        <el-input v-model="queryParams.tagName" placeholder="请输入标签名称" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="标签编码" prop="tagCode">
        <el-input v-model="queryParams.tagCode" placeholder="请输入标签编码" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="状态" clearable style="width: 130px">
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

    <el-table v-loading="loading" :data="tagList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="标签ID" prop="tagId" width="90" />
      <el-table-column label="标签名称" prop="tagName" min-width="120" />
      <el-table-column label="标签编码" prop="tagCode" min-width="120" />
      <el-table-column label="颜色值" prop="tagColor" width="160">
        <template slot-scope="scope">
          <span class="color-dot" :style="{ backgroundColor: scope.row.tagColor || '#409EFF' }"></span>
          <span>{{ scope.row.tagColor || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="排序" prop="sortOrder" width="90" />
      <el-table-column label="状态" prop="status" width="100">
        <template slot-scope="scope"><dict-tag :options="dict.type.sys_normal_disable" :value="scope.row.status" /></template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="180">
        <template slot-scope="scope">
          <el-button type="text" size="mini" icon="el-icon-edit" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button type="text" size="mini" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" :visible.sync="open" width="620px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="标签名称" prop="tagName">
          <el-input v-model="form.tagName" placeholder="请输入标签名称" />
        </el-form-item>
        <el-form-item label="标签编码" prop="tagCode">
          <el-input v-model="form.tagCode" placeholder="例如 NEWBIE/HOT/GROUP" />
        </el-form-item>
        <el-form-item label="标签颜色" prop="tagColor">
          <el-input v-model="form.tagColor" placeholder="例如 #67C23A" />
        </el-form-item>
        <el-form-item label="排序值" prop="sortOrder">
          <el-input-number v-model="form.sortOrder" :min="0" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio label="0">正常</el-radio>
            <el-radio label="1">停用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="2" />
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
import { listInvestTag, getInvestTag, addInvestTag, updateInvestTag, delInvestTag } from '@/api/operation/investTag'

export default {
  name: 'InvestTag',
  dicts: ['sys_normal_disable'],
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      tagList: [],
      open: false,
      title: '',
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        tagName: undefined,
        tagCode: undefined,
        status: undefined
      },
      form: {},
      rules: {
        tagName: [{ required: true, message: '请输入标签名称', trigger: 'blur' }],
        tagCode: [{ required: true, message: '请输入标签编码', trigger: 'blur' }]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listInvestTag(this.queryParams).then(response => {
        this.tagList = response.rows
        this.total = response.total
        this.loading = false
      })
    },
    reset() {
      this.form = {
        tagId: undefined,
        tagCode: undefined,
        tagName: undefined,
        tagColor: '#409EFF',
        sortOrder: 0,
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
      this.ids = selection.map(item => item.tagId)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '新增标签'
    },
    handleUpdate(row) {
      this.reset()
      const tagId = row.tagId || this.ids[0]
      getInvestTag(tagId).then(response => {
        this.form = response.data
        this.open = true
        this.title = '修改标签'
      })
    },
    handleDelete(row) {
      const tagIds = row.tagId ? [row.tagId] : this.ids
      this.$modal.confirm('确认删除标签编号为“' + tagIds.join(',') + '”的数据项吗？').then(() => {
        return delInvestTag(tagIds.join(','))
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      }).catch(() => {})
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        const request = this.form.tagId ? updateInvestTag : addInvestTag
        request(this.form).then(() => {
          this.$modal.msgSuccess(this.form.tagId ? '修改成功' : '新增成功')
          this.open = false
          this.getList()
        })
      })
    },
    cancel() {
      this.open = false
      this.reset()
    }
  }
}
</script>

<style scoped>
.color-dot {
  display: inline-block;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  margin-right: 8px;
  border: 1px solid #dcdfe6;
  vertical-align: middle;
}
</style>
