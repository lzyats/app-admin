<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="90px">
      <el-form-item label="券名称" prop="couponName">
        <el-input v-model="queryParams.couponName" clearable placeholder="请输入券名称" @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="券类型" prop="couponType">
        <el-select v-model="queryParams.couponType" clearable style="width: 180px" placeholder="全部类型">
          <el-option label="体验金券" value="EXPERIENCE" />
          <el-option label="现金券" value="CASH" />
          <el-option label="满减券" value="FULL_REDUCTION" />
          <el-option label="加息券" value="RATE_BOOST" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" clearable style="width: 130px" placeholder="全部状态">
          <el-option label="正常" value="0" />
          <el-option label="停用" value="1" />
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
      <el-col :span="1.5">
        <el-button type="warning" plain icon="el-icon-present" size="mini" :disabled="single" @click="handleGrant">发放</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList" />
    </el-row>

    <el-table v-loading="loading" :data="couponList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" />
      <el-table-column label="ID" prop="couponId" width="80" />
      <el-table-column label="券名称" prop="couponName" min-width="140" />
      <el-table-column label="券类型" prop="couponType" width="130" />
      <el-table-column label="适用范围" prop="scopeType" width="110" />
      <el-table-column label="有效天数" prop="validDays" width="100" />
      <el-table-column label="总数量" prop="totalCount" width="100" />
      <el-table-column label="已发放" prop="receivedCount" width="100" />
      <el-table-column label="状态" prop="status" width="100">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.sys_normal_disable" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="180" align="center">
        <template slot-scope="scope">
          <el-button type="text" size="mini" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button type="text" size="mini" @click="handleGrant(scope.row)">发放</el-button>
          <el-button type="text" size="mini" @click="handleDelete(scope.row)">删除</el-button>
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

    <el-dialog :title="title" :visible.sync="open" width="920px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="120px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="券名称" prop="couponName">
              <el-input v-model="form.couponName" placeholder="请输入券名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="券类型" prop="couponType">
              <el-select v-model="form.couponType" placeholder="请选择券类型" style="width: 100%" @change="handleCouponTypeChange">
                <el-option label="体验金券" value="EXPERIENCE" />
                <el-option label="现金券" value="CASH" />
                <el-option label="满减券" value="FULL_REDUCTION" />
                <el-option label="加息券" value="RATE_BOOST" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row>
          <el-col :span="12">
            <el-form-item label="适用范围">
              <el-select v-model="form.scopeType" placeholder="请选择范围" style="width: 100%" @change="handleScopeTypeChange">
                <el-option label="通用" value="GLOBAL" />
                <el-option label="指定产品" value="PRODUCT" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="showProductIds">
            <el-form-item label="指定产品ID">
              <el-input v-model="form.productIdsJson" placeholder="[1,2,3]" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-card shadow="never" class="mb8" v-if="showCashSection || showRateSection || showExperienceSection">
          <div slot="header" class="clearfix">
            <span>{{ typeSectionTitle }}</span>
          </div>

          <el-row v-if="showCashSection">
            <el-col :span="12">
              <el-form-item label="满额门槛">
                <el-input-number v-model="form.minAmount" :precision="2" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="减免金额">
                <el-input-number v-model="form.discountAmount" :precision="2" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
          </el-row>

          <el-row v-else-if="showRateSection">
            <el-col :span="12">
              <el-form-item label="满额门槛">
                <el-input-number v-model="form.minAmount" :precision="2" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="加息值(%)">
                <el-input-number v-model="form.bonusRate" :precision="4" :step="0.1" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
          </el-row>

          <el-row v-else-if="showExperienceSection">
            <el-col :span="12">
              <el-form-item label="体验金本金">
                <el-input-number v-model="form.experiencePrincipal" :precision="2" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="最小体验份数">
                <el-input-number v-model="form.minExperienceUnits" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="最大体验份数">
                <el-input-number v-model="form.maxExperienceUnits" :min="0" style="width: 100%" />
              </el-form-item>
            </el-col>
          </el-row>
        </el-card>

        <el-row>
          <el-col :span="8">
            <el-form-item label="有效天数">
              <el-input-number v-model="form.validDays" :min="1" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="总发放量">
              <el-input-number v-model="form.totalCount" :min="0" style="width: 100%" />
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

        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <delivery-target-dialog
      :visible.sync="grantOpen"
      :title="grantTitle"
      :business-id="grantCouponId"
      business-id-label="模板ID"
      :audience-fetcher="fetchCouponAudience"
      :confirm-loading="grantSubmitting"
      @confirm="submitGrant"
    />
  </div>
</template>

<script>
import {
  listCouponTemplate,
  getCouponTemplate,
  addCouponTemplate,
  updateCouponTemplate,
  delCouponTemplate,
  listCouponAudience,
  grantCoupon
} from '@/api/operation/couponTemplate'
import DeliveryTargetDialog from '@/components/DeliveryTargetDialog'

const defaultForm = () => ({
  couponId: undefined,
  couponName: undefined,
  couponType: 'CASH',
  scopeType: 'GLOBAL',
  productIdsJson: undefined,
  minAmount: 0,
  discountAmount: 0,
  bonusPrincipal: 0,
  bonusRate: 0,
  experiencePrincipal: 0,
  minExperienceUnits: 0,
  maxExperienceUnits: 0,
  validDays: 7,
  totalCount: 0,
  receivedCount: 0,
  status: '0',
  remark: undefined
})

export default {
  name: 'CouponTemplate',
  components: {
    DeliveryTargetDialog
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
      couponList: [],
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        couponName: undefined,
        couponType: undefined,
        status: undefined
      },
      open: false,
      title: '',
      form: defaultForm(),
      rules: {
        couponName: [{ required: true, message: '请输入券名称', trigger: 'blur' }],
        couponType: [{ required: true, message: '请选择券类型', trigger: 'change' }]
      },
      grantOpen: false,
      grantTitle: '',
      grantCouponId: undefined,
      grantSubmitting: false
    }
  },
  computed: {
    showProductIds() {
      return this.form.scopeType === 'PRODUCT'
    },
    showCashSection() {
      return this.form.couponType === 'CASH' || this.form.couponType === 'FULL_REDUCTION'
    },
    showRateSection() {
      return this.form.couponType === 'RATE_BOOST'
    },
    showExperienceSection() {
      return this.form.couponType === 'EXPERIENCE'
    },
    typeSectionTitle() {
      if (this.showRateSection) {
        return '加息券配置'
      }
      if (this.showExperienceSection) {
        return '体验金券配置'
      }
      return '优惠券配置'
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listCouponTemplate(this.queryParams).then(res => {
        this.couponList = res.rows
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
      this.ids = selection.map(item => item.couponId)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '新增优惠券模板'
    },
    handleUpdate(row) {
      this.reset()
      const id = row && row.couponId ? row.couponId : this.ids[0]
      getCouponTemplate(id).then(res => {
        this.form = Object.assign(defaultForm(), res.data || {})
        this.open = true
        this.title = '修改优惠券模板'
      })
    },
    handleDelete(row) {
      const ids = row && row.couponId ? [row.couponId] : this.ids
      this.$modal.confirm('确认删除优惠券模板编号为 "' + ids.join(',') + '" 的数据项？').then(() => {
        return delCouponTemplate(ids.join(','))
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      })
    },
    handleCouponTypeChange(type) {
      const keepCommon = {
        couponId: this.form.couponId,
        couponName: this.form.couponName,
        couponType: type,
        scopeType: this.form.scopeType,
        productIdsJson: this.form.productIdsJson,
        validDays: this.form.validDays,
        totalCount: this.form.totalCount,
        receivedCount: this.form.receivedCount,
        status: this.form.status,
        remark: this.form.remark
      }
      this.form = Object.assign(defaultForm(), keepCommon)
    },
    handleScopeTypeChange(type) {
      if (type !== 'PRODUCT') {
        this.form.productIdsJson = undefined
      }
    },
    handleGrant(row) {
      const id = row && row.couponId ? row.couponId : this.ids[0]
      this.grantCouponId = id
      this.grantTitle = '发放优惠券'
      this.grantOpen = true
    },
    fetchCouponAudience(query) {
      return listCouponAudience(query)
    },
    submitGrant(payload) {
      const requestData = Object.assign({ couponId: this.grantCouponId }, payload)
      this.grantSubmitting = true
      grantCoupon(requestData).then(res => {
        this.$modal.msgSuccess(res.msg || '发放成功')
        this.grantOpen = false
        this.grantCouponId = undefined
        this.getList()
      }).finally(() => {
        this.grantSubmitting = false
      })
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) {
          return
        }
        const fn = this.form.couponId ? updateCouponTemplate : addCouponTemplate
        fn(this.form).then(() => {
          this.$modal.msgSuccess(this.form.couponId ? '修改成功' : '新增成功')
          this.open = false
          this.getList()
        })
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
    cancel() {
      this.open = false
      this.reset()
    }
  }
}
</script>