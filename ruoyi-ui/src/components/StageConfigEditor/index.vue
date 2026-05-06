<template>
  <el-dialog :title="title" :visible.sync="dialogVisible" :width="width" append-to-body>
    <div class="stage-config-editor">
      <el-alert
        type="info"
        :closable="false"
        show-icon
        title="分段配置会被保存为 JSON 字符串。你只需要按行填写每一段的天数、比例和备注即可。"
        class="mb8"
      />

      <div class="stage-toolbar">
        <el-button size="mini" type="primary" plain @click="applyDailyInterestTemplate">每日返息</el-button>
        <el-button size="mini" type="primary" plain @click="applyMaturityPrincipalTemplate">到期返本</el-button>
        <el-button size="mini" type="warning" plain @click="applyEqualSplitTemplate">等额分段</el-button>
        <el-button size="mini" type="success" plain @click="regenerateStages">按总期数自动生成</el-button>
        <el-button size="mini" type="info" plain @click="applyCycleDaysTemplate">按产品总天数分配</el-button>
        <el-button size="mini" plain @click="applyDecreasingTemplate">首段递减</el-button>
        <el-button size="mini" plain @click="applyIncreasingTemplate">首段递增</el-button>
        <el-button size="mini" @click="resetStages">清空</el-button>
      </div>

      <el-form inline class="stage-custom-form">
        <el-form-item label="起始比例">
          <el-input-number v-model="customStartRatio" :min="0" :precision="4" :step="1" style="width: 140px" />
        </el-form-item>
        <el-form-item label="变化步长">
          <el-input-number v-model="customStepRatio" :min="0" :precision="4" :step="1" style="width: 140px" />
        </el-form-item>
        <el-form-item label="生成方向">
          <el-radio-group v-model="customRatioDirection" size="mini">
            <el-radio-button label="decrease">递减</el-radio-button>
            <el-radio-button label="increase">递增</el-radio-button>
          </el-radio-group>
        </el-form-item>
        <el-form-item>
          <el-button size="mini" type="success" plain @click="applyCustomRatioTemplate">按起始比例生成</el-button>
        </el-form-item>
      </el-form>

      <el-card shadow="never" class="mb8" v-if="interestStages.length > 0">
        <div slot="header" class="clearfix">
          <span>返息分段</span>
        </div>
        <el-table :data="interestStages" border size="small">
          <el-table-column label="阶段" width="90" align="center">
            <template slot-scope="scope">
              第 {{ scope.row.stageNo }} 段
            </template>
          </el-table-column>
          <el-table-column label="天数(天)" width="140" align="center">
            <template slot-scope="scope">
              <el-input-number v-model="scope.row.days" :min="1" :step="1" style="width: 100%" />
            </template>
          </el-table-column>
          <el-table-column label="比例(%)" width="160" align="center">
            <template slot-scope="scope">
              <el-input-number v-model="scope.row.ratio" :precision="4" :step="0.1" :min="0" style="width: 100%" />
            </template>
          </el-table-column>
          <el-table-column label="备注">
            <template slot-scope="scope">
              <el-input v-model="scope.row.remark" placeholder="例如：首期返息" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="120" align="center">
            <template slot-scope="scope">
              <el-button
                v-if="scope.row.stageNo > 1"
                type="text"
                size="mini"
                @click="copyPreviousStage('interest', scope.$index)"
              >
                复制上一段
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-card>

      <el-card shadow="never" class="mb8" v-if="principalStages.length > 0">
        <div slot="header" class="clearfix">
          <span>返本分段</span>
        </div>
        <el-table :data="principalStages" border size="small">
          <el-table-column label="阶段" width="90" align="center">
            <template slot-scope="scope">
              第 {{ scope.row.stageNo }} 段
            </template>
          </el-table-column>
          <el-table-column label="天数(天)" width="140" align="center">
            <template slot-scope="scope">
              <el-input-number v-model="scope.row.days" :min="1" :step="1" style="width: 100%" />
            </template>
          </el-table-column>
          <el-table-column label="比例(%)" width="160" align="center">
            <template slot-scope="scope">
              <el-input-number v-model="scope.row.ratio" :precision="4" :step="0.1" :min="0" style="width: 100%" />
            </template>
          </el-table-column>
          <el-table-column label="备注">
            <template slot-scope="scope">
              <el-input v-model="scope.row.remark" placeholder="例如：到期返本" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="120" align="center">
            <template slot-scope="scope">
              <el-button
                v-if="scope.row.stageNo > 1"
                type="text"
                size="mini"
                @click="copyPreviousStage('principal', scope.$index)"
              >
                复制上一段
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-card>

      <el-empty v-if="interestStages.length === 0 && principalStages.length === 0" description="当前没有启用分段配置" />
    </div>
    <div slot="footer" class="dialog-footer">
      <el-button type="primary" @click="handleConfirm">确定</el-button>
      <el-button @click="handleCancel">取消</el-button>
    </div>
  </el-dialog>
</template>

<script>
const createInterestStage = stageNo => ({
  stageNo,
  days: 1,
  ratio: 0,
  remark: ''
})

const createPrincipalStage = stageNo => ({
  stageNo,
  days: 1,
  ratio: 0,
  remark: ''
})

export default {
  name: 'StageConfigEditor',
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    value: {
      type: String,
      default: ''
    },
    cycleDays: {
      type: Number,
      default: 0
    },
    interestCount: {
      type: Number,
      default: 0
    },
    principalCount: {
      type: Number,
      default: 0
    },
    title: {
      type: String,
      default: '分段配置'
    },
    width: {
      type: String,
      default: '960px'
    }
  },
  data() {
    return {
      interestStages: [],
      principalStages: [],
      customStartRatio: 20,
      customStepRatio: 5,
      customRatioDirection: 'decrease'
    }
  },
  computed: {
    dialogVisible: {
      get() {
        return this.visible
      },
      set(val) {
        this.$emit('update:visible', val)
      }
    }
  },
  watch: {
    visible(val) {
      if (val) {
        this.initStages()
      }
    },
    interestCount() {
      if (this.visible) {
        this.initStages()
      }
    },
    principalCount() {
      if (this.visible) {
        this.initStages()
      }
    },
    value() {
      if (this.visible) {
        this.initStages()
      }
    }
  },
  methods: {
    initStages() {
      const parsed = this.parseValue(this.value)
      this.interestStages = this.normalizeStages(parsed.interestStages, this.interestCount, createInterestStage)
      this.principalStages = this.normalizeStages(parsed.principalStages, this.principalCount, createPrincipalStage)
    },
    parseValue(value) {
      if (!value || !String(value).trim()) {
        return {
          interestStages: [],
          principalStages: []
        }
      }
      try {
        const parsed = JSON.parse(value)
        if (Array.isArray(parsed)) {
          return {
            interestStages: parsed,
            principalStages: []
          }
        }
        return {
          interestStages: Array.isArray(parsed.interestStages) ? parsed.interestStages : [],
          principalStages: Array.isArray(parsed.principalStages) ? parsed.principalStages : []
        }
      } catch (e) {
        return {
          interestStages: [],
          principalStages: []
        }
      }
    },
    normalizeStages(source, count, factory) {
      const rows = []
      for (let i = 0; i < count; i++) {
        const current = source && source[i] ? source[i] : {}
        rows.push({
          stageNo: i + 1,
          days: this.safeNumber(current.days, 1),
          ratio: this.safeNumber(current.ratio, 0),
          remark: current.remark || ''
        })
      }
      return rows.length > 0 ? rows : []
    },
    safeNumber(value, defaultValue) {
      const num = Number(value)
      return Number.isFinite(num) ? num : defaultValue
    },
    resetStages() {
      this.interestStages = this.normalizeStages([], this.interestCount, createInterestStage)
      this.principalStages = this.normalizeStages([], this.principalCount, createPrincipalStage)
    },
    regenerateStages() {
      this.initStages()
    },
    applyCycleDaysTemplate() {
      if (!this.cycleDays || this.cycleDays < 1) {
        this.$modal.msgWarning('请先填写产品周期天数')
        return
      }
      const interestDays = this.distributeDays(this.interestCount, this.cycleDays)
      const principalDays = this.distributeDays(this.principalCount, this.cycleDays)
      if (!interestDays && !principalDays) {
        this.$modal.msgWarning('请先填写返息阶段数或返本阶段数')
        return
      }
      if (interestDays) {
        this.interestStages = this.interestStages.map((row, index) => ({
          ...row,
          days: interestDays[index] || row.days
        }))
      }
      if (principalDays) {
        this.principalStages = this.principalStages.map((row, index) => ({
          ...row,
          days: principalDays[index] || row.days
        }))
      }
    },
    applyDecreasingTemplate() {
      this.applyRatioTrendTemplate('decrease')
    },
    applyIncreasingTemplate() {
      this.applyRatioTrendTemplate('increase')
    },
    applyCustomRatioTemplate() {
      const hasInterest = this.interestCount && this.interestCount > 0
      const hasPrincipal = this.principalCount && this.principalCount > 0
      if (!hasInterest && !hasPrincipal) {
        this.$modal.msgWarning('请先填写返息阶段数或返本阶段数')
        return
      }
      if (this.customStartRatio <= 0) {
        this.$modal.msgWarning('请先填写起始比例')
        return
      }
      if (this.customStepRatio < 0) {
        this.$modal.msgWarning('变化步长不能小于 0')
        return
      }
      if (hasInterest) {
        const stages = this.buildCustomRatioStages(this.interestCount, this.customStartRatio, this.customStepRatio, this.customRatioDirection, 'interest')
        if (!stages) {
          return
        }
        this.interestStages = stages
      }
      if (hasPrincipal) {
        const stages = this.buildCustomRatioStages(this.principalCount, this.customStartRatio, this.customStepRatio, this.customRatioDirection, 'principal')
        if (!stages) {
          return
        }
        this.principalStages = stages
      }
    },
    applyRatioTrendTemplate(direction) {
      const hasInterest = this.interestCount && this.interestCount > 0
      const hasPrincipal = this.principalCount && this.principalCount > 0
      if (!hasInterest && !hasPrincipal) {
        this.$modal.msgWarning('请先填写返息阶段数或返本阶段数')
        return
      }
      if (hasInterest) {
        this.interestStages = this.buildTrendStages(this.interestCount, direction, 'interest')
      }
      if (hasPrincipal) {
        this.principalStages = this.buildTrendStages(this.principalCount, direction, 'principal')
      }
    },
    buildTrendStages(count, direction, type) {
      const ratios = this.buildTrendRatios(count, direction)
      const remarkPrefix = type === 'interest' ? '返息' : '返本'
      return Array.from({ length: count }, (_, index) => ({
        stageNo: index + 1,
        days: 1,
        ratio: ratios[index] || 0,
        remark:
          direction === 'decrease'
            ? index === 0
              ? `${remarkPrefix}首段递减`
              : ''
            : index === count - 1
              ? `${remarkPrefix}首段递增`
              : ''
      }))
    },
    buildTrendRatios(count, direction) {
      if (!count || count < 1) {
        return []
      }
      if (count === 1) {
        return [100]
      }
      const weights = Array.from({ length: count }, (_, index) => (direction === 'decrease' ? count - index : index + 1))
      const totalWeight = weights.reduce((sum, item) => sum + item, 0)
      const ratios = weights.map(weight => Number(((weight / totalWeight) * 100).toFixed(4)))
      const diff = Number((100 - ratios.reduce((sum, item) => sum + item, 0)).toFixed(4))
      if (diff !== 0) {
        ratios[ratios.length - 1] = Number((ratios[ratios.length - 1] + diff).toFixed(4))
      }
      return ratios
    },
    buildCustomRatioStages(count, startRatio, stepRatio, direction, type) {
      const weights = Array.from({ length: count }, (_, index) => {
        const weight = direction === 'decrease' ? startRatio - index * stepRatio : startRatio + index * stepRatio
        return Number(weight)
      })
      if (weights.some(weight => !Number.isFinite(weight) || weight <= 0)) {
        this.$modal.msgWarning('起始比例和变化步长会导致某一段比例小于 0，请重新设置')
        return null
      }
      const totalWeight = weights.reduce((sum, item) => sum + item, 0)
      const ratios = weights.map(weight => Number(((weight / totalWeight) * 100).toFixed(4)))
      const diff = Number((100 - ratios.reduce((sum, item) => sum + item, 0)).toFixed(4))
      if (diff !== 0) {
        ratios[ratios.length - 1] = Number((ratios[ratios.length - 1] + diff).toFixed(4))
      }
      const remarkPrefix = type === 'interest' ? '返息' : '返本'
      return Array.from({ length: count }, (_, index) => ({
        stageNo: index + 1,
        days: 1,
        ratio: ratios[index] || 0,
        remark:
          index === 0
            ? `${remarkPrefix}自定义${direction === 'decrease' ? '递减' : '递增'}`
            : ''
      }))
    },
    distributeDays(count, totalDays) {
      if (!count || count < 1 || !totalDays || totalDays < 1) {
        return null
      }
      if (totalDays < count) {
        this.$modal.msgWarning('产品总天数不能小于分段数量')
        return null
      }
      const base = Math.floor(totalDays / count)
      const remainder = totalDays % count
      return Array.from({ length: count }, (_, index) => base + (index < remainder ? 1 : 0))
    },
    copyPreviousStage(type, index) {
      const rows = type === 'interest' ? this.interestStages : this.principalStages
      if (!Array.isArray(rows) || index < 1 || index >= rows.length) {
        return
      }
      const prev = rows[index - 1] || {}
      const current = rows[index] || {}
      rows.splice(index, 1, {
        stageNo: current.stageNo,
        days: this.safeNumber(prev.days, 1),
        ratio: this.safeNumber(prev.ratio, 0),
        remark: prev.remark || ''
      })
    },
    applyDailyInterestTemplate() {
      if (!this.interestCount || this.interestCount < 1) {
        this.$modal.msgWarning('请先填写返息阶段数')
        return
      }
      const ratio = Number((100 / this.interestCount).toFixed(4))
      this.interestStages = Array.from({ length: this.interestCount }, (_, index) => ({
        stageNo: index + 1,
        days: 1,
        ratio,
        remark: index === 0 ? '每日返息' : ''
      }))
    },
    applyMaturityPrincipalTemplate() {
      if (!this.principalCount || this.principalCount < 1) {
        this.$modal.msgWarning('请先填写返本阶段数')
        return
      }
      this.principalStages = Array.from({ length: this.principalCount }, (_, index) => ({
        stageNo: index + 1,
        days: 1,
        ratio: index === this.principalCount - 1 ? 100 : 0,
        remark: index === this.principalCount - 1 ? '到期返本' : ''
      }))
    },
    applyEqualSplitTemplate() {
      if (this.interestCount && this.interestCount > 0) {
        const ratio = Number((100 / this.interestCount).toFixed(4))
        this.interestStages = Array.from({ length: this.interestCount }, (_, index) => ({
          stageNo: index + 1,
          days: 1,
          ratio,
          remark: ''
        }))
      }
      if (this.principalCount && this.principalCount > 0) {
        const ratio = Number((100 / this.principalCount).toFixed(4))
        this.principalStages = Array.from({ length: this.principalCount }, (_, index) => ({
          stageNo: index + 1,
          days: 1,
          ratio,
          remark: ''
        }))
      }
      if ((!this.interestCount || this.interestCount < 1) && (!this.principalCount || this.principalCount < 1)) {
        this.$modal.msgWarning('请先填写返息阶段数或返本阶段数')
      }
    },
    handleConfirm() {
      const payload = {
        interestStages: this.interestStages.map(item => ({
          stageNo: item.stageNo,
          days: this.safeNumber(item.days, 1),
          ratio: this.safeNumber(item.ratio, 0),
          remark: item.remark || ''
        })),
        principalStages: this.principalStages.map(item => ({
          stageNo: item.stageNo,
          days: this.safeNumber(item.days, 1),
          ratio: this.safeNumber(item.ratio, 0),
          remark: item.remark || ''
        }))
      }
      this.$emit('input', JSON.stringify(payload))
      this.$emit('confirm', payload)
      this.dialogVisible = false
    },
    handleCancel() {
      this.dialogVisible = false
      this.$emit('cancel')
    }
  }
}
</script>

<style scoped>
.stage-config-editor ::v-deep .el-table .el-input-number {
  width: 100%;
}

.stage-toolbar {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 12px;
}

.stage-custom-form {
  padding: 8px 12px 0;
  border: 1px dashed #dcdfe6;
  border-radius: 6px;
  margin-bottom: 12px;
  background: #fafbfd;
}
</style>
