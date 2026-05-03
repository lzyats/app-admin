<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="90px">
      <el-form-item label="产品名称" prop="productName">
        <el-input v-model="queryParams.productName" placeholder="请输入产品名称" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="产品编码" prop="productCode">
        <el-input v-model="queryParams.productCode" placeholder="请输入产品编码" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="币种" prop="currency">
        <el-input v-model="queryParams.currency" placeholder="USDT/CNY" clearable />
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

    <el-table v-loading="loading" :data="productList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="产品ID" prop="productId" width="90" />
      <el-table-column label="产品名称" prop="productName" min-width="140" />
      <el-table-column label="币种" prop="currency" width="90" />
      <el-table-column label="单购利率(%)" prop="singleRate" width="120" />
      <el-table-column label="拼团利率(%)" prop="groupRate" width="120" />
      <el-table-column label="周期(天)" prop="cycleDays" width="100" />
      <el-table-column label="起投金额" prop="minInvestAmount" width="110" />
      <el-table-column label="最高可投" prop="maxInvestAmount" width="110" />
      <el-table-column label="限购等级" prop="limitLevel" width="100" />
      <el-table-column label="限投次数" prop="limitTimes" width="100" />
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

    <el-dialog :title="title" :visible.sync="open" width="980px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="120px">
        <el-row>
          <el-col :span="12"><el-form-item label="产品编码" prop="productCode"><el-input v-model="form.productCode" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="产品名称" prop="productName"><el-input v-model="form.productName" /></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="8"><el-form-item label="投资币种" prop="currency"><el-input v-model="form.currency" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="卡片主题"><el-input v-model="form.cardTheme" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="风险标签"><el-input v-model="form.riskTag" /></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="8"><el-form-item label="单购利率(%)" prop="singleRate"><el-input-number v-model="form.singleRate" :precision="4" :step="0.1" :min="0" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="拼团利率(%)" prop="groupRate"><el-input-number v-model="form.groupRate" :precision="4" :step="0.1" :min="0" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="总周期(天)" prop="cycleDays"><el-input-number v-model="form.cycleDays" :min="1" /></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="8"><el-form-item label="返息方式"><el-select v-model="form.interestMode"><el-option label="每日返息" value="DAILY" /><el-option label="分段返息" value="STAGED" /><el-option label="到期返息" value="MATURITY" /></el-select></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="返本方式"><el-select v-model="form.principalMode"><el-option label="分段返本" value="STAGED" /><el-option label="到期返本" value="MATURITY" /></el-select></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="标签"><el-select v-model="form.tagIds" multiple clearable><el-option v-for="t in tagOptions" :key="t.tagId" :label="t.tagName" :value="t.tagId" /></el-select></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="8"><el-form-item label="起投金额" prop="minInvestAmount"><el-input-number v-model="form.minInvestAmount" :precision="2" :step="100" :min="0" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="最高可投" prop="maxInvestAmount"><el-input-number v-model="form.maxInvestAmount" :precision="2" :step="100" :min="0" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="总份数" prop="totalShares"><el-input-number v-model="form.totalShares" :min="0" /></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="8"><el-form-item label="每份积分"><el-input-number v-model="form.pointPerUnit" :precision="4" :step="0.1" :min="0" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="每份成长值"><el-input-number v-model="form.growthPerUnit" :precision="4" :step="0.1" :min="0" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="每份红包"><el-input-number v-model="form.redPacketPerUnit" :precision="4" :step="0.1" :min="0" /></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="6"><el-form-item label="拼团"><el-radio-group v-model="form.groupEnabled"><el-radio label="0">否</el-radio><el-radio label="1">是</el-radio></el-radio-group></el-form-item></el-col>
          <el-col :span="6"><el-form-item label="自动拼团"><el-radio-group v-model="form.autoGroup"><el-radio label="0">否</el-radio><el-radio label="1">是</el-radio></el-radio-group></el-form-item></el-col>
          <el-col :span="6"><el-form-item label="成团人数"><el-input-number v-model="form.groupSize" :min="2" /></el-form-item></el-col>
          <el-col :span="6"><el-form-item label="可用优惠券"><el-radio-group v-model="form.couponEnabled"><el-radio label="0">否</el-radio><el-radio label="1">是</el-radio></el-radio-group></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="8"><el-form-item label="限购等级"><el-input-number v-model="form.limitLevel" :min="0" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="限投次数"><el-input-number v-model="form.limitTimes" :min="0" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="状态"><el-radio-group v-model="form.status"><el-radio label="0">正常</el-radio><el-radio label="1">停用</el-radio></el-radio-group></el-form-item></el-col>
        </el-row>
        <el-form-item label="分段配置JSON"><el-input v-model="form.stageConfigJson" type="textarea" :rows="3" placeholder="仅分段模式需要，建议数组JSON" /></el-form-item>
        <el-form-item label="备注"><el-input v-model="form.remark" type="textarea" :rows="2" /></el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确定</el-button>
        <el-button @click="cancel">取消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listInvestProduct, getInvestProduct, addInvestProduct, updateInvestProduct, delInvestProduct, listInvestTag } from '@/api/operation/investProduct'

export default {
  name: 'InvestProduct',
  dicts: ['sys_normal_disable'],
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      productList: [],
      tagOptions: [],
      open: false,
      title: '',
      queryParams: { pageNum: 1, pageSize: 10, productName: undefined, productCode: undefined, currency: undefined, status: undefined },
      form: {},
      rules: {
        productCode: [{ required: true, message: '请输入产品编码', trigger: 'blur' }],
        productName: [{ required: true, message: '请输入产品名称', trigger: 'blur' }],
        currency: [{ required: true, message: '请输入币种', trigger: 'blur' }]
      }
    }
  },
  created() {
    this.getList()
    this.loadTags()
  },
  methods: {
    loadTags() {
      listInvestTag({ status: '0', pageNum: 1, pageSize: 1000 }).then(res => { this.tagOptions = res.rows || [] })
    },
    getList() {
      this.loading = true
      listInvestProduct(this.queryParams).then(res => {
        this.productList = res.rows
        this.total = res.total
        this.loading = false
      })
    },
    reset() {
      this.form = {
        productId: undefined, productCode: undefined, productName: undefined, currency: 'USDT', cardTheme: 'blue', riskTag: undefined,
        singleRate: 0, groupRate: 0, cycleDays: 1, interestMode: 'DAILY', principalMode: 'MATURITY', interestStageCount: 0, principalStageCount: 0,
        stageConfigJson: undefined, minInvestAmount: 0, maxInvestAmount: 0, totalShares: 0, soldShares: 0, pointPerUnit: 0, growthPerUnit: 0, redPacketPerUnit: 0,
        couponEnabled: '1', groupEnabled: '0', groupSize: 2, autoGroup: '1', limitLevel: 0, limitTimes: 0, status: '0', tagIds: [], remark: undefined
      }
      this.resetForm('form')
    },
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.productId)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    handleAdd() { this.reset(); this.open = true; this.title = '新增投资产品' },
    handleUpdate(row) {
      this.reset()
      const productId = row.productId || this.ids[0]
      getInvestProduct(productId).then(res => {
        this.form = res.data
        this.form.tagIds = this.form.tagIds || []
        this.open = true
        this.title = '修改投资产品'
      })
    },
    handleDelete(row) {
      const ids = row.productId ? [row.productId] : this.ids
      this.$modal.confirm('确认删除产品编号为“' + ids.join(',') + '”的数据项吗？').then(() => delInvestProduct(ids.join(','))).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      })
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        const fn = this.form.productId ? updateInvestProduct : addInvestProduct
        fn(this.form).then(() => {
          this.$modal.msgSuccess(this.form.productId ? '修改成功' : '新增成功')
          this.open = false
          this.getList()
        })
      })
    },
    handleQuery() { this.queryParams.pageNum = 1; this.getList() },
    resetQuery() { this.resetForm('queryForm'); this.handleQuery() },
    cancel() { this.open = false; this.reset() }
  }
}
</script>
