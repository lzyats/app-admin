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
        <el-select v-model="queryParams.currency" placeholder="全部币种" clearable style="width: 130px">
          <el-option v-for="item in currencyOptions" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
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
      <el-table-column label="投资方式" prop="investMode" width="110">
        <template slot-scope="scope">
          <span>{{ scope.row.investMode === 'AMOUNT' ? '按金额' : '按份额' }}</span>
        </template>
      </el-table-column>
      <el-table-column label="单购利率(%)" prop="singleRate" width="120" />
      <el-table-column label="拼团利率(%)" prop="groupRate" width="120" />
      <el-table-column label="周期(天)" prop="cycleDays" width="100" />
      <el-table-column label="起投金额" prop="minInvestAmount" width="110" />
      <el-table-column label="最高可投" prop="maxInvestAmount" width="110" />
      <el-table-column label="总金额" prop="totalAmount" width="110" />
      <el-table-column label="已售金额" prop="soldAmount" width="110" />
      <el-table-column label="限购等级" prop="limitLevel" width="100" />
      <el-table-column label="限投次数" prop="limitTimes" width="100" />
      <el-table-column label="有效期" min-width="220">
        <template slot-scope="scope">
          <span>{{ formatPeriod(scope.row.startTime, scope.row.endTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" prop="status" width="100">
        <template slot-scope="scope"><dict-tag :options="dict.type.sys_normal_disable" :value="scope.row.status" /></template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="240">
        <template slot-scope="scope">
          <el-button type="text" size="mini" icon="el-icon-edit" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button type="text" size="mini" icon="el-icon-document-copy" @click="handleCopy(scope.row)">复制</el-button>
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
          <el-col :span="8">
            <el-form-item label="投资币种" prop="currency">
              <el-select v-model="form.currency" placeholder="请选择币种" @change="handleCurrencyChange">
                <el-option v-for="item in currencyOptions" :key="item.value" :label="item.label" :value="item.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="8"><el-form-item label="卡片主题"><el-input v-model="form.cardTheme" disabled /></el-form-item></el-col>
          <el-col :span="8">
            <el-form-item label="风险标签">
              <el-select v-model="form.riskTag" clearable filterable placeholder="请选择风险标签">
                <el-option v-for="t in riskTagOptions" :key="t.tagId" :label="t.tagName" :value="t.tagName" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="8">
            <el-form-item label="投资方式" prop="investMode">
              <el-select v-model="form.investMode" @change="handleInvestModeChange">
                <el-option label="按份额" value="SHARE" />
                <el-option label="按金额" value="AMOUNT" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="8"><el-form-item label="单购利率(%)" prop="singleRate"><el-input-number v-model="form.singleRate" :precision="4" :step="0.1" :min="0" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="拼团利率(%)" prop="groupRate"><el-input-number v-model="form.groupRate" :precision="4" :step="0.1" :min="0" /></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="8"><el-form-item label="总周期(天)" prop="cycleDays"><el-input-number v-model="form.cycleDays" :min="1" /></el-form-item></el-col>
          <el-col :span="8">
            <el-form-item label="开始时间" prop="startTime">
              <el-date-picker
                v-model="form.startTime"
                type="datetime"
                value-format="yyyy-MM-dd HH:mm:ss"
                placeholder="选择开始时间"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="结束时间" prop="endTime">
              <el-date-picker
                v-model="form.endTime"
                type="datetime"
                value-format="yyyy-MM-dd HH:mm:ss"
                placeholder="选择结束时间"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="8"><el-form-item label="返息方式"><el-select v-model="form.interestMode"><el-option label="每日返息" value="DAILY" /><el-option label="分段返息" value="STAGED" /><el-option label="到期返息" value="MATURITY" /></el-select></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="返本方式"><el-select v-model="form.principalMode"><el-option label="分段返本" value="STAGED" /><el-option label="到期返本" value="MATURITY" /></el-select></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="产品标签"><el-select v-model="form.tagIds" multiple clearable><el-option v-for="t in productTagOptions" :key="t.tagId" :label="t.tagName" :value="t.tagId" /></el-select></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="封面图">
              <image-upload v-model="form.coverImage" :limit="1" :is-show-tip="false" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="产品组图">
              <image-upload v-model="form.galleryImages" :limit="6" :is-show-tip="false" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="8"><el-form-item label="起投金额" prop="minInvestAmount"><el-input-number v-model="form.minInvestAmount" :precision="2" :step="100" :min="0" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="最高可投" prop="maxInvestAmount"><el-input-number v-model="form.maxInvestAmount" :precision="2" :step="100" :min="0" /></el-form-item></el-col>
          <el-col v-if="form.investMode === 'SHARE'" :span="8"><el-form-item label="总份数" prop="totalShares"><el-input-number v-model="form.totalShares" :min="0" /></el-form-item></el-col>
          <el-col v-else :span="8"><el-form-item label="总金额" prop="totalAmount"><el-input-number v-model="form.totalAmount" :precision="2" :step="100" :min="0" /></el-form-item></el-col>
        </el-row>
        <el-row>
          <el-col :span="8"><el-form-item label="已投份数"><el-input-number v-model="form.soldShares" :min="0" /></el-form-item></el-col>
          <el-col :span="8"><el-form-item label="已投金额"><el-input-number v-model="form.soldAmount" :precision="2" :step="100" :min="0" /></el-form-item></el-col>
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
        <el-form-item label="产品介绍">
          <editor v-model="form.productContent" :min-height="260" />
        </el-form-item>
        <el-form-item label="交易规则内容">
          <el-input
            v-model="form.tradeRuleContent"
            type="textarea"
            :rows="4"
            placeholder="按行填写，APP 端将按一行一个规则展示"
          />
        </el-form-item>
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
import { listInvestProduct, getInvestProduct, addInvestProduct, updateInvestProduct, delInvestProduct, copyInvestProduct, listInvestTag } from '@/api/operation/investProduct'

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
      productTagOptions: [],
      riskTagOptions: [],
      currencyOptions: [
        { label: '人民币(CNY)', value: 'CNY' },
        { label: 'USD', value: 'USD' }
      ],
      themeByCurrency: {
        CNY: 'blue',
        USD: 'purple'
      },
      open: false,
      title: '',
      queryParams: { pageNum: 1, pageSize: 10, productName: undefined, productCode: undefined, currency: undefined, status: undefined },
      form: {},
      rules: {
        productCode: [{ required: true, message: '请输入产品编码', trigger: 'blur' }],
        productName: [{ required: true, message: '请输入产品名称', trigger: 'blur' }],
        currency: [{ required: true, message: '请选择币种', trigger: 'change' }],
        investMode: [{ required: true, message: '请选择投资方式', trigger: 'change' }]
      }
    }
  },
  created() {
    this.getList()
    this.loadTagOptions()
  },
  methods: {
    loadTagOptions() {
      Promise.all([
        listInvestTag({ status: '0', tagType: 'PRODUCT', pageNum: 1, pageSize: 1000 }),
        listInvestTag({ status: '0', tagType: 'RISK', pageNum: 1, pageSize: 1000 })
      ]).then(([productRes, riskRes]) => {
        this.productTagOptions = productRes.rows || []
        this.riskTagOptions = riskRes.rows || []
      })
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
        productId: undefined, productCode: undefined, productName: undefined, currency: 'CNY', cardTheme: 'blue', riskTag: undefined,
        coverImage: undefined, galleryImages: undefined, productContent: undefined, tradeRuleContent: undefined,
        investMode: 'SHARE',
        singleRate: 0, groupRate: 0, cycleDays: 1, interestMode: 'DAILY', principalMode: 'MATURITY', interestStageCount: 0, principalStageCount: 0,
        stageConfigJson: undefined, minInvestAmount: 0, maxInvestAmount: 0, totalShares: 0, soldShares: 0, totalAmount: 0, soldAmount: 0, pointPerUnit: 0, growthPerUnit: 0, redPacketPerUnit: 0,
        couponEnabled: '1', groupEnabled: '0', groupSize: 2, autoGroup: '1', limitLevel: 0, limitTimes: 0, startTime: undefined, endTime: undefined, status: '0', tagIds: [], remark: undefined
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
        this.form.investMode = this.form.investMode || 'SHARE'
        this.form.tagIds = this.form.tagIds || []
        this.form.coverImage = this.form.coverImage || undefined
        this.form.galleryImages = this.form.galleryImages || undefined
        this.form.productContent = this.form.productContent || undefined
        this.syncCardThemeByCurrency(false)
        this.open = true
        this.title = '修改投资产品'
      })
    },
    handleCurrencyChange() {
      this.syncCardThemeByCurrency(true)
    },
    handleInvestModeChange() {
      if (this.form.investMode === 'AMOUNT') {
        this.form.totalShares = 0
        this.form.soldShares = 0
      } else {
        this.form.totalAmount = 0
        this.form.soldAmount = 0
      }
    },
    syncCardThemeByCurrency(force) {
      const theme = this.themeByCurrency[this.form.currency] || 'blue'
      if (force || !this.form.cardTheme) {
        this.form.cardTheme = theme
      }
    },
    handleDelete(row) {
      const ids = row.productId ? [row.productId] : this.ids
      this.$modal.confirm('确认删除产品编号为“' + ids.join(',') + '”的数据项吗？').then(() => delInvestProduct(ids.join(','))).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      })
    },
    handleCopy(row) {
      const productId = row.productId
      this.$modal.confirm('确认复制当前产品吗？复制后已投份数、已售金额与进度将重置为0。').then(() => {
        return copyInvestProduct(productId)
      }).then(() => {
        this.$modal.msgSuccess('复制成功')
        this.getList()
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
    formatPeriod(startTime, endTime) {
      const start = (startTime || '').toString().trim()
      const end = (endTime || '').toString().trim()
      if (!start && !end) return '长期有效'
      if (start && end) return `${start} ~ ${end}`
      if (start) return `${start} 起`
      return `截至 ${end}`
    },
    handleQuery() { this.queryParams.pageNum = 1; this.getList() },
    resetQuery() { this.resetForm('queryForm'); this.handleQuery() },
    cancel() { this.open = false; this.reset() }
  }
}
</script>
