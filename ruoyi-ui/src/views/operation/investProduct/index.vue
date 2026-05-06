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
        <el-select v-model="queryParams.status" placeholder="全部状态" clearable style="width: 130px">
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
        <template slot-scope="scope">
          <dict-tag :options="dict.type.sys_normal_disable" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="240">
        <template slot-scope="scope">
          <el-button type="text" size="mini" icon="el-icon-edit" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button type="text" size="mini" icon="el-icon-document-copy" @click="handleCopy(scope.row)">复制</el-button>
          <el-button type="text" size="mini" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
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

    <el-dialog :title="title" :visible.sync="open" width="980px" append-to-body>
      <el-form ref="form" :model="form" :rules="formRules" label-width="120px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="产品编码" prop="productCode">
              <el-input v-model="form.productCode" placeholder="请输入产品编码" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="产品名称" prop="productName">
              <el-input v-model="form.productName" placeholder="请输入产品名称" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row>
          <el-col :span="8">
            <el-form-item label="投资币种" prop="currency">
              <el-select v-model="form.currency" placeholder="请选择币种" style="width: 100%" @change="handleCurrencyChange">
                <el-option v-for="item in currencyOptions" :key="item.value" :label="item.label" :value="item.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="卡片主题">
              <el-input v-model="form.cardTheme" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="风险标签">
              <el-select v-model="form.riskTag" clearable filterable placeholder="请选择风险标签" style="width: 100%">
                <el-option v-for="tag in riskTagOptions" :key="tag.tagId" :label="tag.tagName" :value="tag.tagName" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row>
          <el-col :span="8">
            <el-form-item label="投资方式" prop="investMode">
              <el-select v-model="form.investMode" placeholder="请选择投资方式" style="width: 100%" @change="handleInvestModeChange">
                <el-option label="按份额" value="SHARE" />
                <el-option label="按金额" value="AMOUNT" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="周期(天)" prop="cycleDays">
              <el-input-number v-model="form.cycleDays" :min="1" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="返息方式">
              <el-select v-model="form.interestMode" placeholder="请选择返息方式" style="width: 100%" @change="handleInterestModeChange">
                <el-option label="每日返息" value="DAILY" />
                <el-option label="分段返息" value="STAGED" />
                <el-option label="到期返息" value="MATURITY" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row>
          <el-col :span="8">
            <el-form-item label="返本方式">
              <el-select v-model="form.principalMode" placeholder="请选择返本方式" style="width: 100%" @change="handlePrincipalModeChange">
                <el-option label="分段返本" value="STAGED" />
                <el-option label="到期返本" value="MATURITY" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="单购利率(%)">
              <el-input-number v-model="form.singleRate" :precision="4" :step="0.1" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="拼团利率(%)">
              <el-input-number v-model="form.groupRate" :precision="4" :step="0.1" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-card v-if="showStageSection" shadow="never" class="mb8">
          <div slot="header" class="clearfix">
            <span>分段配置</span>
          </div>
          <el-row>
            <el-col :span="12" v-if="showInterestStageCount">
              <el-form-item label="返息阶段数" prop="interestStageCount">
                <el-input-number v-model="form.interestStageCount" :min="1" style="width: 100%" @change="syncStageConfigPreview" />
              </el-form-item>
            </el-col>
            <el-col :span="12" v-if="showPrincipalStageCount">
              <el-form-item label="返本阶段数" prop="principalStageCount">
                <el-input-number v-model="form.principalStageCount" :min="1" style="width: 100%" @change="syncStageConfigPreview" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-form-item label="分段配置" prop="stageConfigJson">
            <el-input :value="formatStageConfigSummary()" disabled placeholder="点击右侧按钮编辑分段配置">
              <template slot="append">
                <el-button type="primary" @click="openStageConfigEditor">编辑配置</el-button>
              </template>
            </el-input>
          </el-form-item>
          <el-alert
            v-if="form.stageConfigJson"
            :title="formatStageConfigSummary()"
            type="success"
            :closable="false"
            show-icon
          />
          <el-alert
            :title="formatYieldCalcSummary()"
            type="info"
            :closable="false"
            show-icon
            class="mt8"
          />
        </el-card>

        <el-card shadow="never" class="mb8">
          <div slot="header" class="clearfix">
            <span>投放与额度</span>
          </div>
          <el-row>
            <el-col :span="8">
              <el-form-item label="起投金额" prop="minInvestAmount">
                <el-input-number v-model="form.minInvestAmount" :precision="2" :step="100" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item label="最高可投" prop="maxInvestAmount">
                <el-input-number v-model="form.maxInvestAmount" :precision="2" :step="100" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="8" v-if="showShareMode">
              <el-form-item label="总份额" prop="totalShares">
                <el-input-number v-model="form.totalShares" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="8" v-else>
              <el-form-item label="总金额" prop="totalAmount">
                <el-input-number v-model="form.totalAmount" :precision="2" :step="100" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row>
            <el-col :span="8" v-if="showShareMode">
              <el-form-item label="已售份额">
                <el-input-number v-model="form.soldShares" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="8" v-else>
              <el-form-item label="已售金额">
                <el-input-number v-model="form.soldAmount" :precision="2" :step="100" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item label="每份积分">
                <el-input-number v-model="form.pointPerUnit" :precision="4" :step="0.1" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item label="每份成长值">
                <el-input-number v-model="form.growthPerUnit" :precision="4" :step="0.1" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row>
            <el-col :span="8">
              <el-form-item label="每份红包">
                <el-input-number v-model="form.redPacketPerUnit" :precision="4" :step="0.1" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
          </el-row>
        </el-card>

        <el-card shadow="never" class="mb8">
          <div slot="header" class="clearfix">
            <span>拼团配置</span>
          </div>
          <el-row>
            <el-col :span="6">
              <el-form-item label="启用拼团" prop="groupEnabled">
                <el-radio-group v-model="form.groupEnabled" @change="handleGroupEnabledChange">
                  <el-radio label="0">否</el-radio>
                  <el-radio label="1">是</el-radio>
                </el-radio-group>
              </el-form-item>
            </el-col>
            <el-col :span="6" v-if="showGroupSection">
              <el-form-item label="自动拼团">
                <el-radio-group v-model="form.autoGroup">
                  <el-radio label="0">否</el-radio>
                  <el-radio label="1">是</el-radio>
                </el-radio-group>
              </el-form-item>
            </el-col>
            <el-col :span="6" v-if="showGroupSection">
              <el-form-item label="成团人数" prop="groupSize">
                <el-input-number v-model="form.groupSize" :min="2" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="6">
              <el-form-item label="可用优惠券">
                <el-radio-group v-model="form.couponEnabled">
                  <el-radio label="0">否</el-radio>
                  <el-radio label="1">是</el-radio>
                </el-radio-group>
              </el-form-item>
            </el-col>
          </el-row>
        </el-card>

        <el-row>
          <el-col :span="8">
            <el-form-item label="限购等级">
              <el-input-number v-model="form.limitLevel" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="限投次数">
              <el-input-number v-model="form.limitTimes" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="状态">
              <el-radio-group v-model="form.status">
                <el-radio label="0">正常</el-radio>
                <el-radio label="1">停用</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row>
          <el-col :span="12">
            <el-form-item label="封面图">
              <image-upload v-model="form.coverImage" :limit="1" :is-show-tip="false" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="轮播图">
              <image-upload v-model="form.galleryImages" :limit="6" :is-show-tip="false" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row>
          <el-col :span="12">
            <el-form-item label="产品标签">
              <el-select v-model="form.tagIds" multiple clearable filterable placeholder="请选择产品标签" style="width: 100%">
                <el-option v-for="tag in productTagOptions" :key="tag.tagId" :label="tag.tagName" :value="tag.tagId" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="风险标签">
              <el-select v-model="form.riskTag" clearable filterable placeholder="请选择风险标签" style="width: 100%">
                <el-option v-for="tag in riskTagOptions" :key="tag.tagId" :label="tag.tagName" :value="tag.tagName" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="产品介绍">
          <editor v-model="form.productContent" :min-height="260" />
        </el-form-item>

        <el-form-item label="交易规则">
          <el-input v-model="form.tradeRuleContent" type="textarea" :rows="4" placeholder="按行填写，APP 端将按行展示规则" />
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

    <stage-config-editor
      :visible.sync="stageConfigVisible"
      :value="form.stageConfigJson"
      :cycle-days="form.cycleDays"
      :interest-count="form.interestStageCount"
      :principal-count="form.principalStageCount"
      @confirm="handleStageConfigConfirm"
    />
  </div>
</template>

<script>
import { listInvestProduct, getInvestProduct, addInvestProduct, updateInvestProduct, delInvestProduct, copyInvestProduct, listInvestTag } from '@/api/operation/investProduct'
import StageConfigEditor from '@/components/StageConfigEditor'

const defaultForm = () => ({
  productId: undefined,
  productCode: undefined,
  productName: undefined,
  currency: 'CNY',
  cardTheme: 'blue',
  riskTag: undefined,
  coverImage: undefined,
  galleryImages: undefined,
  productContent: undefined,
  tradeRuleContent: undefined,
  singleRate: 0,
  groupRate: 0,
  cycleDays: 1,
  interestMode: 'DAILY',
  principalMode: 'MATURITY',
  interestStageCount: 0,
  principalStageCount: 0,
  stageConfigJson: undefined,
  investMode: 'SHARE',
  minInvestAmount: 0,
  maxInvestAmount: 0,
  totalShares: 0,
  soldShares: 0,
  totalAmount: 0,
  soldAmount: 0,
  pointPerUnit: 0,
  growthPerUnit: 0,
  redPacketPerUnit: 0,
  couponEnabled: '1',
  groupEnabled: '0',
  groupSize: 2,
  autoGroup: '1',
  limitLevel: 0,
  limitTimes: 0,
  status: '0',
  tagIds: [],
  remark: undefined
})

export default {
  name: 'InvestProduct',
  components: {
    StageConfigEditor
  },
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
        { label: '美元(USD)', value: 'USD' }
      ],
      themeByCurrency: {
        CNY: 'blue',
        USD: 'purple'
      },
      open: false,
      title: '',
      stageConfigVisible: false,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        productName: undefined,
        productCode: undefined,
        currency: undefined,
        status: undefined
      },
      form: defaultForm()
    }
  },
  computed: {
    showShareMode() {
      return this.form.investMode === 'SHARE'
    },
    showStageSection() {
      return this.form.interestMode === 'STAGED' || this.form.principalMode === 'STAGED'
    },
    showInterestStageCount() {
      return this.form.interestMode === 'STAGED'
    },
    showPrincipalStageCount() {
      return this.form.principalMode === 'STAGED'
    },
    showGroupSection() {
      return this.form.groupEnabled === '1'
    },
    formRules() {
      return {
        productCode: [{ required: true, message: '请输入产品编码', trigger: 'blur' }],
        productName: [{ required: true, message: '请输入产品名称', trigger: 'blur' }],
        currency: [{ required: true, message: '请选择币种', trigger: 'change' }],
        investMode: [{ required: true, message: '请选择投资方式', trigger: 'change' }],
        cycleDays: [{ required: true, message: '请输入周期天数', trigger: 'blur' }],
        minInvestAmount: [{ validator: this.validateMinInvestAmount, trigger: 'change' }],
        maxInvestAmount: [{ validator: this.validateMaxInvestAmount, trigger: 'change' }],
        totalShares: [{ validator: this.validateModeTotal, trigger: 'change' }],
        totalAmount: [{ validator: this.validateModeTotal, trigger: 'change' }],
        interestStageCount: [{ validator: this.validateInterestStageCount, trigger: 'change' }],
        principalStageCount: [{ validator: this.validatePrincipalStageCount, trigger: 'change' }],
        stageConfigJson: [{ validator: this.validateStageConfigJson, trigger: 'blur' }],
        groupSize: [{ validator: this.validateGroupSize, trigger: 'change' }]
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
      }).catch(() => {
        this.loading = false
      })
    },
    reset() {
      this.form = defaultForm()
      this.resetForm('form')
    },
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.productId)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    handleAdd() {
      this.reset()
      this.stageConfigVisible = false
      this.open = true
      this.title = '新增投资产品'
    },
    handleUpdate(row) {
      this.reset()
      const productId = row && row.productId ? row.productId : this.ids[0]
      getInvestProduct(productId).then(res => {
        this.form = Object.assign(defaultForm(), res.data || {})
        if (!Array.isArray(this.form.tagIds)) {
          this.form.tagIds = []
        }
        this.syncCardThemeByCurrency(false)
        this.syncModeDefaults()
        this.stageConfigVisible = false
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
      this.syncModeDefaults()
    },
    handleInterestModeChange() {
      if (this.form.interestMode !== 'STAGED') {
        this.form.interestStageCount = 0
      }
      this.syncStageConfig()
      this.syncModeDefaults()
    },
    handlePrincipalModeChange() {
      if (this.form.principalMode !== 'STAGED') {
        this.form.principalStageCount = 0
      }
      this.syncStageConfig()
      this.syncModeDefaults()
    },
    handleGroupEnabledChange(val) {
      if (val !== '1') {
        this.form.groupSize = 2
        this.form.autoGroup = '1'
      } else if (!this.form.groupSize || this.form.groupSize < 2) {
        this.form.groupSize = 2
      }
    },
    openStageConfigEditor() {
      if (this.form.interestMode !== 'STAGED' && this.form.principalMode !== 'STAGED') {
        this.$modal.msgWarning('请先开启分段返息或分段返本')
        return
      }
      if (this.form.interestMode === 'STAGED' && (!this.form.interestStageCount || this.form.interestStageCount < 1)) {
        this.$modal.msgWarning('请先填写返息阶段数')
        return
      }
      if (this.form.principalMode === 'STAGED' && (!this.form.principalStageCount || this.form.principalStageCount < 1)) {
        this.$modal.msgWarning('请先填写返本阶段数')
        return
      }
      this.stageConfigVisible = true
    },
    handleStageConfigConfirm(payload) {
      this.form.stageConfigJson = JSON.stringify(payload)
    },
    syncStageConfigPreview() {
      this.syncStageConfig()
    },
    syncModeDefaults() {
      if (this.form.investMode === 'SHARE') {
        if (!this.form.totalShares || this.form.totalShares < 1) {
          this.form.totalShares = 1
        }
        if (this.form.totalAmount === undefined || this.form.totalAmount === null) {
          this.form.totalAmount = 0
        }
      } else {
        if (!this.form.totalAmount || this.form.totalAmount <= 0) {
          this.form.totalAmount = 1000
        }
        if (this.form.totalShares === undefined || this.form.totalShares === null) {
          this.form.totalShares = 0
        }
      }
      if (this.form.minInvestAmount === undefined || this.form.minInvestAmount === null || this.form.minInvestAmount <= 0) {
        this.form.minInvestAmount = this.form.investMode === 'SHARE' ? 100 : 100
      }
      if (this.form.groupEnabled === '1' && (!this.form.groupSize || this.form.groupSize < 2)) {
        this.form.groupSize = 2
      }
      if (this.form.interestMode === 'STAGED' && (!this.form.interestStageCount || this.form.interestStageCount < 1)) {
        this.form.interestStageCount = 1
      }
      if (this.form.principalMode === 'STAGED' && (!this.form.principalStageCount || this.form.principalStageCount < 1)) {
        this.form.principalStageCount = 1
      }
    },
    syncStageConfig() {
      if (this.form.interestMode !== 'STAGED' && this.form.principalMode !== 'STAGED') {
        this.form.stageConfigJson = undefined
      }
    },
    formatStageConfigSummary() {
      if (!this.form.stageConfigJson) {
        return '当前未配置分段规则'
      }
      try {
        const parsed = JSON.parse(this.form.stageConfigJson)
        const interestCount = Array.isArray(parsed.interestStages) ? parsed.interestStages.length : 0
        const principalCount = Array.isArray(parsed.principalStages) ? parsed.principalStages.length : 0
        const parts = []
        if (interestCount > 0) {
          parts.push(this.describeInterestMode(interestCount))
        }
        if (principalCount > 0) {
          parts.push(this.describePrincipalMode(principalCount))
        }
        return parts.length > 0 ? parts.join('，') : '分段配置已保存'
      } catch (e) {
        return '分段配置内容无法解析，请重新编辑'
      }
    },
    formatYieldCalcSummary() {
      const parts = []
      if (this.form.interestMode === 'DAILY') {
        parts.push('返息按每日返息计算')
      } else if (this.form.interestMode === 'STAGED') {
        const count = Number(this.form.interestStageCount || 0)
        parts.push(`返息按分段返息计算（${count > 0 ? `${count} 段` : '未配置阶段数'}）`)
      } else if (this.form.interestMode === 'MATURITY') {
        parts.push('返息按到期返息计算')
      }

      if (this.form.principalMode === 'STAGED') {
        const count = Number(this.form.principalStageCount || 0)
        parts.push(`返本按分段返本计算（${count > 0 ? `${count} 段` : '未配置阶段数'}）`)
      } else if (this.form.principalMode === 'MATURITY') {
        parts.push('返本按到期返本计算')
      }

      if (parts.length === 0) {
        return '收益计算：请先选择返息方式和返本方式'
      }

      return `收益计算：${parts.join('；')}`
    },
    describeInterestMode(count) {
      if (this.form.interestMode === 'DAILY') {
        return `返息：每日返息`
      }
      if (this.form.interestMode === 'MATURITY') {
        return `返息：到期返息`
      }
      return `返息：分段返息（${count} 段）`
    },
    describePrincipalMode(count) {
      if (this.form.principalMode === 'MATURITY') {
        return `返本：到期返本`
      }
      return `返本：分段返本（${count} 段）`
    },
    syncCardThemeByCurrency(force) {
      const theme = this.themeByCurrency[this.form.currency] || 'blue'
      if (force || !this.form.cardTheme) {
        this.form.cardTheme = theme
      }
    },
    validateMinInvestAmount(rule, value, callback) {
      if (value === undefined || value === null || value === '' || Number(value) <= 0) {
        callback(new Error('请输入起投金额'))
        return
      }
      callback()
    },
    validateMaxInvestAmount(rule, value, callback) {
      if (value !== undefined && value !== null && value !== '' && Number(value) > 0) {
        const min = Number(this.form.minInvestAmount || 0)
        if (min > 0 && Number(value) < min) {
          callback(new Error('最高可投不能小于起投金额'))
          return
        }
      }
      callback()
    },
    validateModeTotal(rule, value, callback) {
      if (rule.field === 'totalShares' && this.form.investMode === 'SHARE') {
        if (!value || Number(value) < 1) {
          callback(new Error('按份额模式下总份额必须大于 0'))
          return
        }
      }
      if (rule.field === 'totalAmount' && this.form.investMode === 'AMOUNT') {
        if (!value || Number(value) <= 0) {
          callback(new Error('按金额模式下总金额必须大于 0'))
          return
        }
      }
      callback()
    },
    validateInterestStageCount(rule, value, callback) {
      if (this.form.interestMode === 'STAGED' && (!value || Number(value) < 1)) {
        callback(new Error('分段返息时返息阶段数必须大于 0'))
        return
      }
      callback()
    },
    validatePrincipalStageCount(rule, value, callback) {
      if (this.form.principalMode === 'STAGED' && (!value || Number(value) < 1)) {
        callback(new Error('分段返本时返本阶段数必须大于 0'))
        return
      }
      callback()
    },
    validateStageConfigJson(rule, value, callback) {
      if ((this.form.interestMode === 'STAGED' || this.form.principalMode === 'STAGED') && (!value || !String(value).trim())) {
        callback(new Error('分段模式下请填写分段配置 JSON'))
        return
      }
      if (value && String(value).trim()) {
        try {
          JSON.parse(value)
        } catch (e) {
          callback(new Error('分段配置不是合法的 JSON'))
          return
        }
      }
      callback()
    },
    validateGroupSize(rule, value, callback) {
      if (this.form.groupEnabled === '1' && (!value || Number(value) < 2)) {
        callback(new Error('启用拼团时成团人数至少为 2'))
        return
      }
      callback()
    },
    handleDelete(row) {
      const ids = row && row.productId ? [row.productId] : this.ids
      this.$modal.confirm('确认删除产品编号为 "' + ids.join(',') + '" 的数据项？').then(() => {
        return delInvestProduct(ids.join(','))
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      })
    },
    handleCopy(row) {
      const productId = row.productId
      this.$modal.confirm('确认复制当前产品吗？复制后已投份额、已售金额与进度将重置为 0。').then(() => {
        return copyInvestProduct(productId)
      }).then(() => {
        this.$modal.msgSuccess('复制成功')
        this.getList()
      })
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) {
          return
        }
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
      if (!start && !end) {
        return '长期有效'
      }
      if (start && end) {
        return `${start} ~ ${end}`
      }
      if (start) {
        return `${start} 起`
      }
      return `截至 ${end}`
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.resetForm('queryForm')
      this.handleQuery()
    },
    cancel() {
      this.open = false
      this.stageConfigVisible = false
      this.reset()
    }
  }
}
</script>
