<template>
  <div class="app-container">
    <el-card>
      <template slot="header">
        <div class="card-header">
          <span>{{ walletModeLabel }}钱包管理</span>
          <div>
            <el-button type="primary" size="small" @click="handleAddFunds()">
              <i class="el-icon-plus"></i> 充值
            </el-button>
            <el-button type="danger" size="small" @click="handleDeductFunds()">
              <i class="el-icon-minus"></i> 扣除
            </el-button>
          </div>
        </div>
      </template>

      <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch">
        <el-form-item label="用户ID" prop="userId">
          <el-input v-model="queryParams.userId" placeholder="请输入用户ID" clearable style="width: 180px" />
        </el-form-item>
        <el-form-item label="用户名" prop="userName">
          <el-input v-model="queryParams.userName" placeholder="请输入用户名" clearable style="width: 180px" />
        </el-form-item>
        <el-form-item label="币种" prop="currencyType">
          <el-select v-model="queryParams.currencyType" placeholder="全部" clearable style="width: 120px">
            <el-option v-for="item in currencyOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" size="small" @click="handleQuery">搜索</el-button>
          <el-button icon="el-icon-refresh" size="small" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table v-loading="loading" :data="walletList" border style="width: 100%">
        <el-table-column label="钱包ID" prop="walletId" width="90" />
        <el-table-column label="用户ID" prop="userId" width="90" />
        <el-table-column label="用户名" prop="userName" min-width="120" />
        <el-table-column label="币种" prop="currencyType" width="90">
          <template slot-scope="scope">
            {{ getCurrencyLabel(scope.row.currencyType) }}
          </template>
        </el-table-column>
        <el-table-column label="总投资" prop="totalInvest" width="110">
          <template slot-scope="scope">{{ formatAmount(scope.row.totalInvest) }}</template>
        </el-table-column>
        <el-table-column label="可用余额" prop="availableBalance" width="110">
          <template slot-scope="scope">{{ formatAmount(scope.row.availableBalance) }}</template>
        </el-table-column>
        <el-table-column label="冻结金额" prop="frozenAmount" width="110">
          <template slot-scope="scope">{{ formatAmount(scope.row.frozenAmount) }}</template>
        </el-table-column>
        <el-table-column label="收益金额" prop="profitAmount" width="110">
          <template slot-scope="scope">{{ formatAmount(scope.row.profitAmount) }}</template>
        </el-table-column>
        <el-table-column label="待收金额" prop="pendingAmount" width="110">
          <template slot-scope="scope">{{ formatAmount(scope.row.pendingAmount) }}</template>
        </el-table-column>
        <el-table-column label="累计充值" prop="totalRecharge" width="110">
          <template slot-scope="scope">{{ formatAmount(scope.row.totalRecharge) }}</template>
        </el-table-column>
        <el-table-column label="累计提现" prop="totalWithdraw" width="110">
          <template slot-scope="scope">{{ formatAmount(scope.row.totalWithdraw) }}</template>
        </el-table-column>
        <el-table-column label="创建时间" prop="createTime" width="170" />
        <el-table-column label="操作" width="240" fixed="right">
          <template slot-scope="scope">
            <el-button type="text" size="mini" @click="handleViewWallet(scope.row)">详情</el-button>
            <el-button type="text" size="mini" @click="handleViewLogs(scope.row)">流水</el-button>
            <el-button type="text" size="mini" @click="handleAddFunds(scope.row)">充值</el-button>
            <el-button type="text" size="mini" @click="handleDeductFunds(scope.row)">扣除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />
    </el-card>

    <el-dialog :title="addDialogTitle" :visible.sync="addDialogVisible" width="560px" append-to-body>
      <el-form :model="addForm" :rules="addRules" ref="addForm" label-width="100px">
        <el-form-item label="用户ID">
          <el-input v-model="addForm.userId" readonly />
        </el-form-item>
        <el-form-item label="用户名">
          <el-input v-model="addForm.userName" readonly />
        </el-form-item>
        <el-form-item label="币种" prop="currencyType">
          <el-select v-model="addForm.currencyType" :disabled="currencyOptions.length === 1" placeholder="请选择币种" style="width: 100%">
            <el-option v-for="item in currencyOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item :label="currentBalanceLabel(addForm.currencyType)">
          <el-input :value="formatAmount(addForm.currentBalance)" readonly />
        </el-form-item>
        <el-form-item label="充值金额" prop="amount">
          <el-input-number v-model="addForm.amount" :min="0.01" :precision="2" :step="0.01" controls-position="right" style="width: 100%" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-select v-model="addForm.type" placeholder="请选择类型" style="width: 100%">
            <el-option label="充值" value="recharge" />
            <el-option label="收益" value="profit" />
            <el-option label="其他" value="other" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="addForm.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="addDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitAddFunds">确定</el-button>
      </div>
    </el-dialog>

    <el-dialog :title="deductDialogTitle" :visible.sync="deductDialogVisible" width="560px" append-to-body>
      <el-form :model="deductForm" :rules="deductRules" ref="deductForm" label-width="100px">
        <el-form-item label="用户ID">
          <el-input v-model="deductForm.userId" readonly />
        </el-form-item>
        <el-form-item label="用户名">
          <el-input v-model="deductForm.userName" readonly />
        </el-form-item>
        <el-form-item label="币种" prop="currencyType">
          <el-select v-model="deductForm.currencyType" :disabled="currencyOptions.length === 1" placeholder="请选择币种" style="width: 100%">
            <el-option v-for="item in currencyOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item :label="currentBalanceLabel(deductForm.currencyType)">
          <el-input :value="formatAmount(deductForm.currentBalance)" readonly />
        </el-form-item>
        <el-form-item label="扣除金额" prop="amount">
          <el-input-number v-model="deductForm.amount" :min="0.01" :precision="2" :step="0.01" controls-position="right" style="width: 100%" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-select v-model="deductForm.type" placeholder="请选择类型" style="width: 100%">
            <el-option label="提现" value="withdraw" />
            <el-option label="投资" value="invest" />
            <el-option label="其他" value="other" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="deductForm.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="deductDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitDeductFunds">确定</el-button>
      </div>
    </el-dialog>

    <el-dialog :title="logsDialogTitle" :visible.sync="logsDialogVisible" width="900px" append-to-body>
      <el-table v-loading="logsLoading" :data="walletLogs" border style="width: 100%">
        <el-table-column label="流水ID" prop="logId" width="90" />
        <el-table-column label="时间" prop="createTime" width="170" />
        <el-table-column label="操作人" prop="operatorName" width="120">
          <template slot-scope="scope">
            {{ scope.row.operatorName || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="币种" prop="currencyType" width="90">
          <template slot-scope="scope">
            {{ getCurrencyLabel(scope.row.currencyType) }}
          </template>
        </el-table-column>
        <el-table-column label="类型" prop="type" width="110">
          <template slot-scope="scope">
            <span>{{ getLogTypeLabel(scope.row.type) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="金额" prop="amount" width="110">
          <template slot-scope="scope">{{ formatAmount(scope.row.amount) }}</template>
        </el-table-column>
        <el-table-column label="变动前" prop="balanceBefore" width="110">
          <template slot-scope="scope">{{ formatAmount(scope.row.balanceBefore) }}</template>
        </el-table-column>
        <el-table-column label="变动后" prop="balanceAfter" width="110">
          <template slot-scope="scope">{{ formatAmount(scope.row.balanceAfter) }}</template>
        </el-table-column>
        <el-table-column label="状态" prop="status" width="100">
          <template slot-scope="scope">
            <el-tag size="small" :type="scope.row.status === 'success' ? 'success' : scope.row.status === 'pending' ? 'warning' : 'danger'">
              {{ getStatusLabel(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="备注" prop="remark" min-width="160" />
      </el-table>
      <div slot="footer" class="dialog-footer">
        <el-button @click="logsDialogVisible = false">关闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listWallet, listWalletLog, getWalletByUserId, adjustWallet } from '@/api/system/wallet'
import { getConfigKey } from '@/api/system/config'

export default {
  name: 'WalletManagement',
  data() {
    return {
      loading: false,
      logsLoading: false,
      walletList: [],
      walletLogs: [],
      total: 0,
      showSearch: true,
      investMode: '1',
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userId: null,
        userName: null,
        currencyType: null
      },
      addDialogVisible: false,
      deductDialogVisible: false,
      logsDialogVisible: false,
      selectedWallet: null,
      addForm: {
        userId: null,
        userName: '',
        walletId: null,
        currencyType: 'CNY',
        currentBalance: 0,
        amount: undefined,
        type: 'recharge',
        remark: ''
      },
      deductForm: {
        userId: null,
        userName: '',
        walletId: null,
        currencyType: 'CNY',
        currentBalance: 0,
        amount: undefined,
        type: 'withdraw',
        remark: ''
      },
      addRules: {
        currencyType: [{ required: true, message: '请选择币种', trigger: 'change' }],
        amount: [{ required: true, message: '请输入充值金额', trigger: 'blur' }]
      },
      deductRules: {
        currencyType: [{ required: true, message: '请选择币种', trigger: 'change' }],
        amount: [{ required: true, message: '请输入扣除金额', trigger: 'blur' }]
      }
    }
  },
  computed: {
    walletModeLabel() {
      return String(this.investMode) === '2' ? '双币' : '单币'
    },
    currencyOptions() {
      if (String(this.investMode) === '2') {
        return [
          { label: '人民币钱包', value: 'CNY' },
          { label: 'USD钱包', value: 'USD' }
        ]
      }
      return [{ label: '人民币钱包', value: 'CNY' }]
    },
    addDialogTitle() {
      return `充值${this.addForm.userName ? ' - ' + this.addForm.userName : ''}`
    },
    deductDialogTitle() {
      return `扣除${this.deductForm.userName ? ' - ' + this.deductForm.userName : ''}`
    },
    logsDialogTitle() {
      return `流水${this.selectedWallet ? ' - ' + this.selectedWallet.userName + ' / ' + this.getCurrencyLabel(this.selectedWallet.currencyType) : ''}`
    }
  },
  created() {
    this.initPage()
  },
  watch: {
    investMode() {
      this.syncRouteTitle()
    }
  },
  methods: {
    async initPage() {
      const userId = this.$route.query.userId
      const userName = this.$route.query.userName
      if (userId) {
        this.queryParams.userId = userId
        this.queryParams.userName = userName
      }
      const routeCurrencyType = this.$route.query.currencyType
      await this.loadConfig()
      if (routeCurrencyType) {
        this.queryParams.currencyType = routeCurrencyType
      } else if (String(this.investMode) === '1') {
        this.queryParams.currencyType = 'CNY'
      }
      this.syncRouteTitle()
      this.getList()
    },
    loadConfig() {
      return getConfigKey('app.currency.investMode').then(res => {
        this.investMode = String(res.msg || '1')
      }).catch(() => {
        this.investMode = '1'
      })
    },
    syncRouteTitle() {
      const title = `${this.walletModeLabel}钱包管理`
      if (this.$route && this.$route.meta) {
        this.$set(this.$route.meta, 'title', title)
      }
      this.$store.dispatch('tagsView/updateVisitedView', {
        path: this.$route.path,
        fullPath: this.$route.fullPath,
        name: this.$route.name,
        title,
        meta: {
          ...(this.$route.meta || {}),
          title
        }
      })
      document.title = title
    },
    getCurrencyLabel(currencyType) {
      return currencyType === 'USD' ? 'USD' : '人民币'
    },
    currentBalanceLabel(currencyType) {
      return `当前余额（${this.getCurrencyLabel(currencyType)}）`
    },
    getLogTypeLabel(type) {
      const map = {
        recharge: '充值',
        withdraw: '提现',
        invest: '投资',
        profit: '收益',
        frozen: '冻结',
        unfrozen: '解冻',
        other: '其他'
      }
      return map[type] || type || '-'
    },
    getStatusLabel(status) {
      const map = {
        success: '成功',
        pending: '处理中',
        failed: '失败'
      }
      return map[status] || status || '-'
    },
    formatAmount(value) {
      const amount = Number(value || 0)
      return Number.isNaN(amount) ? '0.00' : amount.toFixed(2)
    },
    getList() {
      this.loading = true
      listWallet(this.queryParams).then(res => {
        this.walletList = res.rows || []
        this.total = res.total || 0
      }).finally(() => {
        this.loading = false
      })
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.$refs.queryForm.resetFields()
      this.queryParams.pageNum = 1
      this.queryParams.pageSize = 10
      this.queryParams.currencyType = String(this.investMode) === '1' ? 'CNY' : null
      this.handleQuery()
    },
    fillWalletForm(form, row) {
      form.userId = row.userId
      form.userName = row.userName
      form.walletId = row.walletId
      form.currencyType = row.currencyType || 'CNY'
      form.currentBalance = Number(row.availableBalance || 0)
      form.amount = undefined
      form.remark = ''
    },
    handleAddFunds(row) {
      if (row) {
        this.fillWalletForm(this.addForm, row)
      } else {
        if (!this.queryParams.userId) {
          this.$modal.msgError('请先通过用户或钱包进入指定账户')
          return
        }
        const firstCurrency = this.currencyOptions[0] ? this.currencyOptions[0].value : 'CNY'
        this.addForm.userId = this.queryParams.userId || null
        this.addForm.userName = this.queryParams.userName || ''
        this.addForm.walletId = null
        this.addForm.currencyType = firstCurrency
        this.addForm.currentBalance = 0
        this.addForm.amount = undefined
        this.addForm.remark = ''
      }
      this.addDialogVisible = true
    },
    handleDeductFunds(row) {
      if (row) {
        this.fillWalletForm(this.deductForm, row)
      } else {
        if (!this.queryParams.userId) {
          this.$modal.msgError('请先通过用户或钱包进入指定账户')
          return
        }
        const firstCurrency = this.currencyOptions[0] ? this.currencyOptions[0].value : 'CNY'
        this.deductForm.userId = this.queryParams.userId || null
        this.deductForm.userName = this.queryParams.userName || ''
        this.deductForm.walletId = null
        this.deductForm.currencyType = firstCurrency
        this.deductForm.currentBalance = 0
        this.deductForm.amount = undefined
        this.deductForm.remark = ''
      }
      this.deductDialogVisible = true
    },
    submitAddFunds() {
      this.$refs.addForm.validate(valid => {
        if (!valid) return
        const amount = Number(this.addForm.amount || 0)
        if (amount <= 0) {
          this.$modal.msgError('请输入有效金额')
          return
        }
        adjustWallet({
          userId: this.addForm.userId,
          userName: this.addForm.userName,
          currencyType: this.addForm.currencyType,
          amount,
          direction: 'add',
          type: this.addForm.type,
          remark: this.addForm.remark
        }).then(() => {
          this.$modal.msgSuccess('充值成功')
          this.addDialogVisible = false
          this.getList()
        }).catch(() => {})
      })
    },
    submitDeductFunds() {
      this.$refs.deductForm.validate(valid => {
        if (!valid) return
        const amount = Number(this.deductForm.amount || 0)
        if (amount <= 0) {
          this.$modal.msgError('请输入有效金额')
          return
        }
        const target = this.deductForm.walletId
          ? Promise.resolve({ data: this.deductForm })
          : getWalletByUserId(this.deductForm.userId, this.deductForm.currencyType)
        target.then(res => {
          const wallet = res.data || this.deductForm
          const currentBalance = Number(wallet.availableBalance || wallet.available_balance || wallet.currentBalance || 0)
          if (amount > currentBalance) {
            this.$modal.msgError('扣除金额不能大于可用余额')
            return Promise.reject(new Error('insufficient'))
          }
          return adjustWallet({
            userId: this.deductForm.userId,
            userName: this.deductForm.userName,
            currencyType: this.deductForm.currencyType,
            amount,
            direction: 'deduct',
            type: this.deductForm.type,
            remark: this.deductForm.remark
          })
        }).then(() => {
          this.$modal.msgSuccess('扣除成功')
          this.deductDialogVisible = false
          this.getList()
        }).catch(() => {})
      })
    },
    handleViewWallet(row) {
      this.$modal.alert(`
        <div style="padding: 10px;">
          <p><strong>用户：</strong>${row.userName}</p>
          <p><strong>钱包ID：</strong>${row.walletId}</p>
          <p><strong>币种：</strong>${this.getCurrencyLabel(row.currencyType)}</p>
          <p><strong>总投资：</strong>${this.formatAmount(row.totalInvest)}</p>
          <p><strong>可用余额：</strong>${this.formatAmount(row.availableBalance)}</p>
          <p><strong>冻结金额：</strong>${this.formatAmount(row.frozenAmount)}</p>
          <p><strong>收益金额：</strong>${this.formatAmount(row.profitAmount)}</p>
          <p><strong>待收金额：</strong>${this.formatAmount(row.pendingAmount)}</p>
          <p><strong>累计充值：</strong>${this.formatAmount(row.totalRecharge)}</p>
          <p><strong>累计提现：</strong>${this.formatAmount(row.totalWithdraw)}</p>
        </div>
      `)
    },
    handleViewLogs(row) {
      this.selectedWallet = row
      this.logsLoading = true
      listWalletLog({ walletId: row.walletId }).then(res => {
        this.walletLogs = res.rows || []
        this.logsDialogVisible = true
      }).finally(() => {
        this.logsLoading = false
      })
    }
  }
}
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
