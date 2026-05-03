<template>
  <el-drawer
    title="用户信息详情"
    :visible.sync="visible"
    direction="rtl"
    size="68%"
    append-to-body
    :before-close="handleClose"
    custom-class="detail-drawer"
  >
    <div v-loading="loading" class="drawer-content">
      <h4 class="section-header">基本信息</h4>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">用户昵称：</label>
            <span class="info-value plaintext">{{ info.nickName || '-' }}</span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">归属部门：</label>
            <span class="info-value plaintext">{{ (info.dept && info.dept.deptName) || '-' }}</span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">手机号码：</label>
            <span class="info-value plaintext">{{ info.phonenumber || '-' }}</span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">邮箱：</label>
            <span class="info-value plaintext">{{ info.email || '-' }}</span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">登录账号：</label>
            <span class="info-value plaintext">{{ info.userName || '-' }}</span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">状态：</label>
            <span class="info-value plaintext">
              <el-tag size="small" :type="info.status === '0' ? 'success' : 'danger'">
                {{ info.status === '0' ? '正常' : '停用' }}
              </el-tag>
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">实名状态：</label>
            <span class="info-value plaintext">
              <el-tag size="small" :type="getRealNameStatusType(info.realNameStatus)">
                {{ getRealNameStatusLabel(info.realNameStatus) }}
              </el-tag>
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">用户性别：</label>
            <span class="info-value plaintext">{{ sexLabel }}</span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">岗位：</label>
            <span class="info-value plaintext">{{ postNames || '无岗位' }}</span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">角色：</label>
            <span class="info-value plaintext">{{ roleNames || '无角色' }}</span>
          </div>
        </el-col>
      </el-row>

      <h4 class="section-header">邀请信息</h4>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">邀请码：</label>
            <span class="info-value plaintext">{{ info.inviteCode || '-' }}</span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">成长值：</label>
            <span class="info-value plaintext">{{ info.growthValue || 0 }}</span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">上级用户：</label>
            <span class="info-value plaintext">{{ info.parentUserName || '-' }}</span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">层级详情：</label>
            <span class="info-value plaintext">{{ info.levelDetail || '0' }}</span>
          </div>
        </el-col>
      </el-row>

      <h4 class="section-header">其他信息</h4>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">创建者：</label>
            <span class="info-value plaintext">{{ info.createBy || '-' }}</span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">创建时间：</label>
            <span class="info-value plaintext">{{ info.createTime || '-' }}</span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">更新者：</label>
            <span class="info-value plaintext">{{ info.updateBy || '-' }}</span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">更新时间：</label>
            <span class="info-value plaintext">{{ info.updateTime || '-' }}</span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="24">
          <div class="info-item full-width">
            <label class="info-label">备注：</label>
            <span class="info-value plaintext">{{ info.remark || '-' }}</span>
          </div>
        </el-col>
      </el-row>

      <h4 class="section-header">钱包信息</h4>
      <div v-loading="loadingWallet" class="wallet-section">
        <div v-if="!loadingWallet && walletInfo">
          <el-row :gutter="20" class="mb8">
            <el-col :span="12">
              <div class="info-item">
                <label class="info-label">钱包币种：</label>
                <span class="info-value plaintext">{{ walletInfo.currencyType || walletInfo.currency_type || 'CNY' }}</span>
              </div>
            </el-col>
            <el-col :span="12">
              <div class="info-item">
                <label class="info-label">总投资金额：</label>
                <span class="info-value plaintext">{{ walletInfo.totalInvest || 0 }}</span>
              </div>
            </el-col>
          </el-row>
          <el-row :gutter="20" class="mb8">
            <el-col :span="12">
              <div class="info-item">
                <label class="info-label">可用余额：</label>
                <span class="info-value plaintext">{{ walletInfo.availableBalance || 0 }}</span>
              </div>
            </el-col>
            <el-col :span="12">
              <div class="info-item">
                <label class="info-label">冻结金额：</label>
                <span class="info-value plaintext">{{ walletInfo.frozenAmount || 0 }}</span>
              </div>
            </el-col>
          </el-row>
          <el-row :gutter="20" class="mb8">
            <el-col :span="12">
              <div class="info-item">
                <label class="info-label">收益金额：</label>
                <span class="info-value plaintext">{{ walletInfo.profitAmount || 0 }}</span>
              </div>
            </el-col>
            <el-col :span="12">
              <div class="info-item">
                <label class="info-label">待收金额：</label>
                <span class="info-value plaintext">{{ walletInfo.pendingAmount || 0 }}</span>
              </div>
            </el-col>
          </el-row>
          <el-row :gutter="20" class="mb8">
            <el-col :span="12">
              <div class="info-item">
                <label class="info-label">累计充值：</label>
                <span class="info-value plaintext">{{ walletInfo.totalRecharge || 0 }}</span>
              </div>
            </el-col>
            <el-col :span="12">
              <div class="info-item">
                <label class="info-label">累计提现：</label>
                <span class="info-value plaintext">{{ walletInfo.totalWithdraw || 0 }}</span>
              </div>
            </el-col>
          </el-row>
          <h5 class="subsection-header">最近钱包流水</h5>
          <el-table :data="walletLogs.slice(0, 5)" style="width: 100%" border size="small">
            <el-table-column prop="createTime" label="变动时间" width="160" />
            <el-table-column prop="type" label="变动类型" width="100">
              <template slot-scope="scope">
                <span v-if="scope.row.type === 'recharge'">充值</span>
                <span v-else-if="scope.row.type === 'withdraw'">提现</span>
                <span v-else-if="scope.row.type === 'invest'">投资</span>
                <span v-else-if="scope.row.type === 'profit'">收益</span>
                <span v-else>其他</span>
              </template>
            </el-table-column>
            <el-table-column prop="amount" label="变动金额" width="100" />
            <el-table-column prop="balanceAfter" label="余额" width="100" />
            <el-table-column prop="status" label="状态" width="80">
              <template slot-scope="scope">
                <span v-if="scope.row.status === 'success'" style="color: green;">成功</span>
                <span v-else-if="scope.row.status === 'pending'" style="color: orange;">处理中</span>
                <span v-else style="color: red;">失败</span>
              </template>
            </el-table-column>
          </el-table>
          <div v-if="walletLogs.length === 0" style="text-align: center; padding: 10px;">
            暂无流水记录
          </div>
        </div>
        <div v-if="!loadingWallet && !walletInfo" style="text-align: center; padding: 20px;">
          暂无钱包信息
        </div>
      </div>
    </div>
  </el-drawer>
</template>

<script>
import { getUser } from '@/api/system/user'
import { getWalletByUserId, getWalletLogsByUserId } from '@/api/system/wallet'

export default {
  name: 'UserViewDrawer',
  data() {
    return {
      visible: false,
      loading: false,
      loadingWallet: false,
      info: {},
      walletInfo: null,
      walletLogs: [],
      postNames: '',
      roleNames: '',
      sexLabel: '-'
    }
  },
  methods: {
    open(userId) {
      this.visible = true
      this.loading = true
      this.loadingWallet = true
      this.info = {}
      this.walletInfo = null
      this.walletLogs = []
      this.postNames = ''
      this.roleNames = ''
      this.sexLabel = '-'
      getUser(userId).then(response => {
        this.info = response.data || {}
        this.postNames = (response.posts || []).map(item => item.postName).join('，')
        this.roleNames = (response.roles || []).map(item => item.roleName).join('，')
        this.sexLabel = this.getSexLabel(this.info.sex)
        this.loading = false
        this.loadWalletInfo(userId)
      }).catch(() => {
        this.loading = false
        this.loadingWallet = false
      })
    },
    handleClose(done) {
      this.visible = false
      done()
    },
    loadWalletInfo(userId) {
      getWalletByUserId(userId).then(response => {
        this.walletInfo = response.data || null
        return getWalletLogsByUserId(userId)
      }).then(response => {
        this.walletLogs = response.rows || []
      }).catch(() => {
        this.walletInfo = null
        this.walletLogs = []
      }).finally(() => {
        this.loadingWallet = false
      })
    },
    getSexLabel(value) {
      const sex = String(value)
      if (sex === '0') {
        return '男'
      }
      if (sex === '1') {
        return '女'
      }
      return '未知'
    },
    getRealNameStatusLabel(status) {
      const value = Number(status)
      switch (value) {
        case 1:
          return '待审核'
        case 2:
          return '已驳回'
        case 3:
          return '已实名'
        default:
          return '未实名'
      }
    },
    getRealNameStatusType(status) {
      const value = Number(status)
      switch (value) {
        case 1:
          return 'warning'
        case 2:
          return 'danger'
        case 3:
          return 'success'
        default:
          return 'info'
      }
    }
  }
}
</script>
