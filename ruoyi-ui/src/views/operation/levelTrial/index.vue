<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="90px">
      <el-form-item label="名称"><el-input v-model="queryParams.trialName" clearable @keyup.enter.native="handleQuery" /></el-form-item>
      <el-form-item label="体验等级"><el-input-number v-model="queryParams.trialLevel" :min="0" :controls="false" /></el-form-item>
      <el-form-item label="状态"><el-select v-model="queryParams.status" clearable style="width: 130px"><el-option label="正常" value="0" /><el-option label="停用" value="1" /></el-select></el-form-item>
      <el-form-item><el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button><el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button></el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5"><el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd">新增</el-button></el-col>
      <el-col :span="1.5"><el-button type="success" plain icon="el-icon-edit" size="mini" :disabled="single" @click="handleUpdate">修改</el-button></el-col>
      <el-col :span="1.5"><el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple" @click="handleDelete">删除</el-button></el-col>
      <el-col :span="1.5"><el-button type="warning" plain icon="el-icon-present" size="mini" :disabled="single" @click="handleGrant">发放</el-button></el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="trialList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" />
      <el-table-column label="ID" prop="trialId" width="80" />
      <el-table-column label="名称" prop="trialName" min-width="150" />
      <el-table-column label="体验等级" prop="trialLevel" width="100" />
      <el-table-column label="加成(%)" prop="bonusRate" width="100" />
      <el-table-column label="有效天数" prop="validDays" width="100" />
      <el-table-column label="总发放量" prop="totalCount" width="100" />
      <el-table-column label="已发放" prop="receivedCount" width="100" />
      <el-table-column label="状态" prop="status" width="100"><template slot-scope="scope"><dict-tag :options="dict.type.sys_normal_disable" :value="scope.row.status" /></template></el-table-column>
      <el-table-column label="操作" width="150"><template slot-scope="scope"><el-button type="text" size="mini" @click="handleUpdate(scope.row)">修改</el-button><el-button type="text" size="mini" @click="handleGrant(scope.row)">发放</el-button></template></el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" :visible.sync="open" width="620px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="名称" prop="trialName"><el-input v-model="form.trialName" /></el-form-item>
        <el-form-item label="体验等级" prop="trialLevel"><el-input-number v-model="form.trialLevel" :min="0" /></el-form-item>
        <el-form-item label="加成(%)"><el-input-number v-model="form.bonusRate" :precision="4" :step="0.1" :min="0" /></el-form-item>
        <el-form-item label="有效天数"><el-input-number v-model="form.validDays" :min="1" /></el-form-item>
        <el-form-item label="总发放量"><el-input-number v-model="form.totalCount" :min="0" /></el-form-item>
        <el-form-item label="状态"><el-radio-group v-model="form.status"><el-radio label="0">正常</el-radio><el-radio label="1">停用</el-radio></el-radio-group></el-form-item>
        <el-form-item label="备注"><el-input v-model="form.remark" type="textarea" :rows="2" /></el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer"><el-button type="primary" @click="submitForm">确定</el-button><el-button @click="cancel">取消</el-button></div>
    </el-dialog>

    <el-dialog title="发放等级体验券" :visible.sync="grantOpen" width="520px" append-to-body>
      <el-form :model="grantForm" label-width="110px">
        <el-form-item label="模板ID"><el-input v-model="grantForm.trialId" disabled /></el-form-item>
        <el-form-item label="用户ID列表"><el-input v-model="grantForm.userIdsText" placeholder="例如：1,2,3" /></el-form-item>
        <el-form-item label="发放类型"><el-input v-model="grantForm.grantType" placeholder="MANUAL/ACTIVITY" /></el-form-item>
        <el-form-item label="备注"><el-input v-model="grantForm.remark" type="textarea" :rows="2" /></el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer"><el-button type="primary" @click="submitGrant">确定</el-button><el-button @click="grantOpen = false">取消</el-button></div>
    </el-dialog>
  </div>
</template>

<script>
import { listLevelTrial, getLevelTrial, addLevelTrial, updateLevelTrial, delLevelTrial, grantLevelTrial } from '@/api/operation/levelTrial'

export default {
  name: 'LevelTrial',
  dicts: ['sys_normal_disable'],
  data() {
    return {
      loading: true, ids: [], single: true, multiple: true, showSearch: true, total: 0, trialList: [],
      queryParams: { pageNum: 1, pageSize: 10, trialName: undefined, trialLevel: undefined, status: undefined },
      open: false, title: '', form: {}, rules: { trialName: [{ required: true, message: '请输入名称', trigger: 'blur' }], trialLevel: [{ required: true, message: '请输入体验等级', trigger: 'blur' }] },
      grantOpen: false, grantForm: { trialId: undefined, userIdsText: '', grantType: 'MANUAL', remark: undefined }
    }
  },
  created() { this.getList() },
  methods: {
    getList() { this.loading = true; listLevelTrial(this.queryParams).then(res => { this.trialList = res.rows; this.total = res.total; this.loading = false }) },
    reset() { this.form = { trialId: undefined, trialName: undefined, trialLevel: 0, bonusRate: 0, validDays: 7, totalCount: 0, receivedCount: 0, status: '0', remark: undefined }; this.resetForm('form') },
    handleSelectionChange(selection) { this.ids = selection.map(item => item.trialId); this.single = selection.length !== 1; this.multiple = !selection.length },
    handleAdd() { this.reset(); this.open = true; this.title = '新增等级体验券模板' },
    handleUpdate(row) { this.reset(); const id = row.trialId || this.ids[0]; getLevelTrial(id).then(res => { this.form = res.data; this.open = true; this.title = '修改等级体验券模板' }) },
    handleDelete(row) { const ids = row.trialId ? [row.trialId] : this.ids; this.$modal.confirm('确认删除模板“' + ids.join(',') + '”吗？').then(() => delLevelTrial(ids.join(','))).then(() => { this.getList(); this.$modal.msgSuccess('删除成功') }) },
    handleGrant(row) { const id = row.trialId || this.ids[0]; this.grantForm = { trialId: id, userIdsText: '', grantType: 'MANUAL', remark: undefined }; this.grantOpen = true },
    submitGrant() {
      const ids = (this.grantForm.userIdsText || '').split(',').map(v => v.trim()).filter(v => v).map(v => Number(v))
      grantLevelTrial({ trialId: this.grantForm.trialId, userIds: ids, grantType: this.grantForm.grantType, remark: this.grantForm.remark }).then(res => { this.$modal.msgSuccess(res.msg || '发放成功'); this.grantOpen = false })
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        const fn = this.form.trialId ? updateLevelTrial : addLevelTrial
        fn(this.form).then(() => { this.$modal.msgSuccess(this.form.trialId ? '修改成功' : '新增成功'); this.open = false; this.getList() })
      })
    },
    handleQuery() { this.queryParams.pageNum = 1; this.getList() },
    resetQuery() { this.resetForm('queryForm'); this.handleQuery() },
    cancel() { this.open = false; this.reset() }
  }
}
</script>
