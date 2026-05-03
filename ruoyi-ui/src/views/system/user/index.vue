<template>
  <div class="app-container tree-sidebar-manage-wrap">
    <tree-panel
      title="组织机构"
      :tree-data="deptOptions"
      search-placeholder="请输入部门名称"
      storage-key="dept-sidebar-width"
      :defaultExpandAll="true"
      @node-click="handleNodeClick"
      @refresh="getDeptTree"
      ref="deptTreeRef"
    />
    <div class="tree-sidebar-content">
      <div class="content-inner">
        <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
          <el-form-item label="用户名" prop="userName">
            <el-input v-model="queryParams.userName" placeholder="请输入用户名" clearable style="width: 240px" @keyup.enter.native="handleQuery" />
          </el-form-item>
          <el-form-item label="手机号码" prop="phonenumber">
            <el-input v-model="queryParams.phonenumber" placeholder="请输入手机号码" clearable style="width: 240px" @keyup.enter.native="handleQuery" />
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-select v-model="queryParams.status" placeholder="用户状态" clearable style="width: 240px">
              <el-option v-for="dict in dict.type.sys_normal_disable" :key="dict.value" :label="dict.label" :value="dict.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="实名状态" prop="realNameStatus">
            <el-select v-model="queryParams.realNameStatus" placeholder="实名状态" clearable style="width: 240px">
              <el-option v-for="item in realNameStatusOptions" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="创建时间">
            <el-date-picker
              v-model="dateRange"
              style="width: 240px"
              value-format="yyyy-MM-dd"
              type="daterange"
              range-separator="-"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
            <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
          </el-form-item>
        </el-form>

        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd" v-hasPermi="['system:user:add']">新增</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button type="success" plain icon="el-icon-edit" size="mini" :disabled="single" @click="handleUpdate" v-hasPermi="['system:user:edit']">修改</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple" @click="handleDelete" v-hasPermi="['system:user:remove']">删除</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button type="info" plain icon="el-icon-upload2" size="mini" @click="handleImport" v-hasPermi="['system:user:import']">导入</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button type="warning" plain icon="el-icon-download" size="mini" @click="handleExport" v-hasPermi="['system:user:export']">导出</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button type="info" plain icon="el-icon-s-data" size="mini" @click="handleGrowthList">成长值管理</el-button>
          </el-col>
          <right-toolbar :showSearch.sync="showSearch" @queryTable="getList" :columns="columns" />
        </el-row>

        <el-table v-loading="loading" :data="userList" @selection-change="handleSelectionChange">
          <el-table-column type="selection" width="50" align="center" />
          <el-table-column label="用户编号" align="center" key="userId" prop="userId" v-if="columns.userId.visible" />
          <el-table-column label="用户名" align="center" key="userName" v-if="columns.userName.visible" :show-overflow-tooltip="true">
            <template slot-scope="scope">
              <a class="link-type" style="cursor:pointer" @click="handleViewData(scope.row)">{{ scope.row.userName }}</a>
            </template>
          </el-table-column>
          <el-table-column label="用户昵称" align="center" key="nickName" prop="nickName" v-if="columns.nickName.visible" :show-overflow-tooltip="true" />
          <el-table-column label="部门" align="center" key="deptName" prop="dept.deptName" v-if="columns.deptName.visible" :show-overflow-tooltip="true" />
          <el-table-column label="手机号码" align="center" key="phonenumber" prop="phonenumber" v-if="columns.phonenumber.visible" width="120" />
          <el-table-column label="邀请码" align="center" key="inviteCode" prop="inviteCode" v-if="columns.inviteCode.visible" width="120" :show-overflow-tooltip="true" />
          <el-table-column label="成长值" align="center" key="growthValue" prop="growthValue" v-if="columns.growthValue.visible" width="100" />
          <el-table-column label="实名状态" align="center" key="realNameStatus" v-if="columns.realNameStatus.visible" width="100">
            <template slot-scope="scope">
              <el-tag :type="getRealNameStatusType(scope.row.realNameStatus)" size="mini">
                {{ getRealNameStatusLabel(scope.row.realNameStatus) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="上级用户" align="center" key="parentUserName" v-if="columns.parentUserName.visible" width="120" :show-overflow-tooltip="true">
            <template slot-scope="scope">
              <span>{{ scope.row.parentUserName || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="状态" align="center" key="status" v-if="columns.status.visible" width="90">
            <template slot-scope="scope">
              <el-switch v-model="scope.row.status" active-value="0" inactive-value="1" @change="handleStatusChange(scope.row)" />
            </template>
          </el-table-column>
          <el-table-column label="创建时间" align="center" prop="createTime" v-if="columns.createTime.visible" width="160">
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.createTime) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" align="center" width="200" class-name="small-padding fixed-width">
            <template slot-scope="scope" v-if="scope.row.userId !== 1">
              <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)">修改</el-button>
              <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
              <el-dropdown size="mini" @command="(command) => handleCommand(command, scope.row)">
                <el-button size="mini" type="text" icon="el-icon-d-arrow-right">更多</el-button>
                <el-dropdown-menu slot="dropdown">
                  <el-dropdown-item command="handleResetPwd" icon="el-icon-key">重置密码</el-dropdown-item>
                  <el-dropdown-item command="handleAuthRole" icon="el-icon-circle-check">分配角色</el-dropdown-item>
                  <el-dropdown-item command="handleViewLevel" icon="el-icon-s-order">层级关系</el-dropdown-item>
                  <el-dropdown-item command="handleViewBankCard" icon="el-icon-credit-card">银行卡</el-dropdown-item>
                  <el-dropdown-item command="handleViewWallet" icon="el-icon-money">钱包信息</el-dropdown-item>
                  <el-dropdown-item command="handleGrowthValue" icon="el-icon-s-data">成长值管理</el-dropdown-item>
                </el-dropdown-menu>
              </el-dropdown>
            </template>
          </el-table-column>
        </el-table>
        <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />
      </div>
    </div>

    <el-dialog :title="title" :visible.sync="open" width="700px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="90px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="用户昵称" prop="nickName">
              <el-input v-model="form.nickName" placeholder="请输入用户昵称" maxlength="30" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="归属部门" prop="deptId">
              <treeselect v-model="form.deptId" :options="enabledDeptOptions" :show-count="true" placeholder="请选择归属部门" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="手机号码" prop="phonenumber">
              <el-input v-model="form.phonenumber" placeholder="请输入手机号码" maxlength="11" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="form.email" placeholder="请输入邮箱" maxlength="50" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item v-if="form.userId == undefined" label="用户名" prop="userName">
              <el-input v-model="form.userName" placeholder="请输入用户名" maxlength="30" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item v-if="form.userId == undefined" label="用户密码" prop="password" :rules="pwdValidator">
              <el-input v-model="form.password" placeholder="请输入用户密码" type="password" maxlength="20" show-password />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="用户性别">
              <el-select v-model="form.sex" placeholder="请选择性别">
                <el-option v-for="dict in dict.type.sys_user_sex" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态">
              <el-radio-group v-model="form.status">
                <el-radio v-for="dict in dict.type.sys_normal_disable" :key="dict.value" :label="dict.value">{{ dict.label }}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="实名状态" prop="realNameStatus">
              <el-select v-model="form.realNameStatus" placeholder="请选择实名状态">
                <el-option v-for="item in realNameStatusOptions" :key="item.value" :label="item.label" :value="item.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="用户层级" prop="userLevel">
              <el-input-number v-model="form.userLevel" :min="0" :max="999" placeholder="请输入用户层级" controls-position="right" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="岗位">
              <el-select v-model="form.postIds" multiple placeholder="请选择岗位">
                <el-option v-for="item in postOptions" :key="item.postId" :label="item.postName" :value="item.postId" :disabled="item.status == 1" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="角色">
              <el-select v-model="form.roleIds" multiple placeholder="请选择角色">
                <el-option v-for="item in roleOptions" :key="item.roleId" :label="item.roleName" :value="item.roleId" :disabled="item.status == 1" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="24">
            <el-form-item label="备注">
              <el-input v-model="form.remark" type="textarea" placeholder="请输入内容" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <user-view-drawer ref="userViewRef" />
    <excel-import-dialog
      ref="importUserRef"
      title="用户导入"
      action="/system/user/importData"
      template-action="/system/user/importTemplate"
      template-file-name="user_template"
      update-support-label="是否更新已经存在的用户数据"
      @success="getList"
    />
  </div>
</template>

<script>
import { listUser, getUser, delUser, addUser, updateUser, resetUserPwd, changeUserStatus, deptTreeSelect } from "@/api/system/user"
import { getConfigKey } from "@/api/system/config"
import Treeselect from "@riophae/vue-treeselect"
import "@riophae/vue-treeselect/dist/vue-treeselect.css"
import TreePanel from "@/components/TreePanel"
import ExcelImportDialog from "@/components/ExcelImportDialog"
import UserViewDrawer from "./view"
import passwordRule from "@/utils/passwordRule"

export default {
  name: "User",
  mixins: [passwordRule],
  dicts: ['sys_normal_disable', 'sys_user_sex'],
  components: { Treeselect, TreePanel, ExcelImportDialog, UserViewDrawer },
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      userList: [],
      title: "",
      deptOptions: [],
      enabledDeptOptions: [],
      open: false,
      initPassword: undefined,
      dateRange: [],
      postOptions: [],
      roleOptions: [],
      realNameStatusOptions: [
        { label: '未实名', value: 0 },
        { label: '待审核', value: 1 },
        { label: '已驳回', value: 2 },
        { label: '已实名', value: 3 }
      ],
      form: {},
      addFundsForm: {
        amount: null,
        remark: ''
      },
      deductFundsForm: {
        amount: null,
        remark: ''
      },
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userName: undefined,
        phonenumber: undefined,
        status: undefined,
        realNameStatus: undefined,
        deptId: undefined
      },
      columns: {
        userId: { label: '用户编号', visible: true },
        userName: { label: '用户名', visible: true },
        nickName: { label: '用户昵称', visible: true },
        deptName: { label: '部门', visible: true },
        phonenumber: { label: '手机号码', visible: true },
        inviteCode: { label: '邀请码', visible: true },
        growthValue: { label: '成长值', visible: true },
        realNameStatus: { label: '实名状态', visible: true },
        parentUserName: { label: '上级用户', visible: true },
        status: { label: '状态', visible: true },
        createTime: { label: '创建时间', visible: true }
      },
      rules: {
        userName: [
          { required: true, message: '用户名不能为空', trigger: 'blur' },
          { min: 2, max: 20, message: '用户名长度必须在 2 到 20 之间', trigger: 'blur' }
        ],
        nickName: [
          { required: true, message: '用户昵称不能为空', trigger: 'blur' }
        ],
        email: [
          {
            type: 'email',
            message: '请输入正确的邮箱地址',
            trigger: ['blur', 'change']
          }
        ],
        phonenumber: [
          {
            pattern: /^1[3|4|5|6|7|8|9][0-9]\d{8}$/,
            message: '请输入正确的手机号码',
            trigger: 'blur'
          }
        ]
      }
    }
  },
  created() {
    this.getList()
    this.getDeptTree()
    this.getConfigKey('sys.user.initPassword').then(response => {
      this.initPassword = response.msg
    })
  },
  methods: {
    getList() {
      this.loading = true
      listUser(this.addDateRange(this.queryParams, this.dateRange)).then(response => {
        this.userList = response.rows || []
        this.total = response.total || 0
        this.loading = false
      }).catch(() => {
        this.loading = false
      })
    },
    getDeptTree() {
      deptTreeSelect().then(response => {
        const deptData = response.data || []
        this.deptOptions = deptData
        this.enabledDeptOptions = this.filterDisabledDept(JSON.parse(JSON.stringify(deptData)))
      })
    },
    filterDisabledDept(deptList) {
      if (!Array.isArray(deptList)) {
        return []
      }
      return deptList.filter(dept => {
        if (dept.disabled) {
          return false
        }
        if (dept.children && dept.children.length) {
          dept.children = this.filterDisabledDept(dept.children)
        }
        return true
      })
    },
    handleNodeClick(data) {
      this.queryParams.deptId = data.id
      this.handleQuery()
    },
    handleStatusChange(row) {
      const text = row.status === '0' ? '启用' : '停用'
      this.$modal.confirm(`确认要将用户"${row.userName}"的状态设置为${text}吗？`).then(() => {
        return changeUserStatus(row.userId, row.status)
      }).then(() => {
        this.$modal.msgSuccess(`${text}成功`)
      }).catch(() => {
        row.status = row.status === '0' ? '1' : '0'
      })
    },
    cancel() {
      this.open = false
      this.reset()
    },
    reset() {
      this.form = {
        userId: undefined,
        deptId: undefined,
        userName: undefined,
        nickName: undefined,
        password: undefined,
        phonenumber: undefined,
        email: undefined,
        sex: undefined,
        status: '0',
        realNameStatus: 0,
        remark: undefined,
        postIds: [],
        roleIds: []
      }
      this.resetForm('form')
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.dateRange = []
      this.resetForm('queryForm')
      this.queryParams.deptId = undefined
      this.queryParams.realNameStatus = undefined
      if (this.$refs.deptTreeRef) {
        this.$refs.deptTreeRef.setCurrentKey(null)
      }
      this.handleQuery()
    },
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.userId)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    handleCommand(command, row) {
      switch (command) {
        case 'handleResetPwd':
          this.handleResetPwd(row)
          break
        case 'handleAuthRole':
          this.handleAuthRole(row)
          break
        case 'handleViewLevel':
          this.handleViewLevel(row)
          break
        case 'handleViewBankCard':
          this.handleViewBankCard(row)
          break
        case 'handleViewWallet':
          this.handleViewWallet(row)
          break
        case 'handleAddFunds':
          this.handleAddFunds(row)
          break
        case 'handleDeductFunds':
          this.handleDeductFunds(row)
          break
        case 'handleGrowthValue':
          this.handleGrowthValue(row)
          break
        default:
          break
      }
    },
    handleGrowthValue(row) {
      this.$router.push({
        path: '/system/growth/index',
        query: {
          userId: row.userId,
          userName: row.userName
        }
      })
    },
    handleGrowthList() {
      this.$router.push({
        path: '/system/growth/index'
      })
    },
    handleAdd() {
      this.reset()
      getUser().then(response => {
        this.postOptions = response.posts || []
        this.roleOptions = response.roles || []
        this.open = true
        this.title = '添加用户'
        this.form.password = this.initPassword
      })
    },
    handleUpdate(row) {
      this.reset()
      const userId = row.userId || this.ids
      getUser(userId).then(response => {
        this.form = response.data || {}
        this.postOptions = response.posts || []
        this.roleOptions = response.roles || []
        this.$set(this.form, 'postIds', response.postIds || [])
        this.$set(this.form, 'roleIds', response.roleIds || [])
        if (this.form.realNameStatus === null || this.form.realNameStatus === undefined) {
          this.$set(this.form, 'realNameStatus', 0)
        }
        this.open = true
        this.title = '修改用户'
        this.form.password = ''
      })
    },
    handleResetPwd(row) {
      this.$prompt(`请输入用户【${row.userName}】的新密码`, '重置密码', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        closeOnClickModal: false,
        inputValidator: this.pwdPromptValidator
      }).then(({ value }) => {
        resetUserPwd(row.userId, value).then(() => {
          this.$modal.msgSuccess(`修改成功，新密码是：${value}`)
        })
      }).catch(() => {})
    },
    handleAuthRole(row) {
      this.$router.push('/system/user-auth/role/' + row.userId)
    },
    submitForm() {
      this.$refs['form'].validate(valid => {
        if (!valid) {
          return
        }
        if (this.form.userId !== undefined) {
          updateUser(this.form).then(() => {
            this.$modal.msgSuccess('修改成功')
            this.open = false
            this.getList()
          })
        } else {
          addUser(this.form).then(() => {
            this.$modal.msgSuccess('新增成功')
            this.open = false
            this.getList()
          })
        }
      })
    },
    handleDelete(row) {
      const userIds = row.userId || this.ids
      this.$modal.confirm(`是否确认删除用户编号为"${userIds}"的数据项？`).then(() => {
        return delUser(userIds)
      }).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      }).catch(() => {})
    },
    handleExport() {
      this.download('system/user/export', {
        ...this.queryParams
      }, `user_${new Date().getTime()}.xlsx`)
    },
    handleViewData(row) {
      this.$refs.userViewRef.open(row.userId)
    },
    handleImport() {
      this.$refs.importUserRef.open()
    },
    formatRealNameStatus(status) {
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
    getRealNameStatusLabel(status) {
      return this.formatRealNameStatus(status)
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
    },
    handleViewLevel(row) {
      this.$modal.alert(`
用户名：${row.userName}
用户编号：${row.userId}
用户层级：${row.userLevel || 0}
邀请码：${row.inviteCode || '-'}
上级用户：${row.parentUserName || '-'}
层级详情：${row.levelDetail || '0'}
      `)
    },
    handleViewWallet(row) {
      this.$router.push({
        path: '/system/wallet/index',
        query: { userId: row.userId, userName: row.userName }
      })
    },
    handleViewBankCard(row) {
      this.$router.push({
        path: '/operation/bankCard/index',
        query: { userId: row.userId, userName: row.userName }
      })
    },
    handleAddFunds(row) {
      this.$prompt('请输入要添加的金额', '添加资金', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        closeOnClickModal: false,
        inputPattern: /^\d+(\.\d{1,2})?$/,
        inputErrorMessage: '请输入正确的金额'
      }).then(({ value }) => {
        const amount = parseFloat(value)
        if (!(amount > 0)) {
          this.$modal.msgError('请输入有效的金额')
          return
        }
        this.$prompt('请输入备注（可选）', '添加资金备注', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          closeOnClickModal: false,
          inputValue: '后台手动添加资金'
        }).then(({ value: remark }) => {
          this.$http.get(`/system/wallet/user/${row.userId}`).then(walletResponse => {
            const wallet = walletResponse.data
            if (!wallet || !wallet.wallet_id) {
              this.$modal.msgError('该用户不存在钱包信息')
              return
            }
            this.$http.post('/system/wallet/adjust', {
              userId: row.userId,
              userName: row.userName,
              currencyType: wallet.currency_type || wallet.currencyType || 'CNY',
              amount,
              direction: 'add',
              type: 'recharge',
              remark: remark || '后台手动添加资金'
            }).then(() => {
              this.$modal.msgSuccess('添加资金成功')
            })
          })
        }).catch(() => {})
      }).catch(() => {})
    },
    handleDeductFunds(row) {
      this.$prompt('请输入要扣除的金额', '扣除资金', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        closeOnClickModal: false,
        inputPattern: /^\d+(\.\d{1,2})?$/,
        inputErrorMessage: '请输入正确的金额'
      }).then(({ value }) => {
        const amount = parseFloat(value)
        if (!(amount > 0)) {
          this.$modal.msgError('请输入有效的金额')
          return
        }
        this.$prompt('请输入备注（可选）', '扣除资金备注', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          closeOnClickModal: false,
          inputValue: '后台手动扣除资金'
        }).then(({ value: remark }) => {
          this.$http.get(`/system/wallet/user/${row.userId}`).then(walletResponse => {
            const wallet = walletResponse.data
            if (!wallet || !wallet.wallet_id) {
              this.$modal.msgError('该用户不存在钱包信息')
              return
            }
            if (amount > (wallet.available_balance || 0)) {
              this.$modal.msgError('扣除金额不能大于可用余额')
              return
            }
            this.$http.post('/system/wallet/adjust', {
              userId: row.userId,
              userName: row.userName,
              currencyType: wallet.currency_type || wallet.currencyType || 'CNY',
              amount,
              direction: 'deduct',
              type: 'withdraw',
              remark: remark || '后台手动扣除资金'
            }).then(() => {
              this.$modal.msgSuccess('扣除资金成功')
            })
          })
        }).catch(() => {})
      }).catch(() => {})
    }
  }
}
</script>
