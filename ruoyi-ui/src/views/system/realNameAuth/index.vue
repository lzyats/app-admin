<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="80px">
      <el-form-item label="用户账号" prop="userName">
        <el-input
          v-model="queryParams.userName"
          placeholder="请输入用户账号"
          clearable
          style="width: 180px"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="真实姓名" prop="realName">
        <el-input
          v-model="queryParams.realName"
          placeholder="请输入真实姓名"
          clearable
          style="width: 180px"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="审核状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable style="width: 150px">
          <el-option label="待审核" :value="0" />
          <el-option label="已通过" :value="1" />
          <el-option label="已拒绝" :value="2" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" size="mini" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList" :columns="columns" />
    </el-row>

    <el-table v-loading="loading" :data="authList">
      <el-table-column label="认证ID" align="center" key="authId" prop="authId" width="80" />
      <el-table-column label="用户账号" align="center" key="userName" prop="userName" :show-overflow-tooltip="true" />
      <el-table-column label="真实姓名" align="center" key="realName" prop="realName" width="120" />
      <el-table-column label="身份证号" align="center" key="idCardNumber" prop="idCardNumber" width="180" />
      <el-table-column label="身份证正面" align="center" key="idCardFront" prop="idCardFront" width="120">
        <template slot-scope="scope">
          <el-image
            v-if="scope.row.idCardFront"
            :src="scope.row.idCardFront"
            :preview-src-list="[scope.row.idCardFront]"
            style="width: 40px; height: 40px"
            fit="cover"
          />
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="身份证反面" align="center" key="idCardBack" prop="idCardBack" width="120">
        <template slot-scope="scope">
          <el-image
            v-if="scope.row.idCardBack"
            :src="scope.row.idCardBack"
            :preview-src-list="[scope.row.idCardBack]"
            style="width: 40px; height: 40px"
            fit="cover"
          />
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="手持照片" align="center" key="handheldPhoto" prop="handheldPhoto" width="120">
        <template slot-scope="scope">
          <el-image
            v-if="scope.row.handheldPhoto"
            :src="scope.row.handheldPhoto"
            :preview-src-list="[scope.row.handheldPhoto]"
            style="width: 40px; height: 40px"
            fit="cover"
          />
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="审核状态" align="center" key="status" width="100">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.status === 0" type="warning">待审核</el-tag>
          <el-tag v-else-if="scope.row.status === 1" type="success">已通过</el-tag>
          <el-tag v-else-if="scope.row.status === 2" type="danger">已拒绝</el-tag>
          <el-tag v-else type="info">未知</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="提交时间" align="center" key="submitTime" prop="submitTime" width="180">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.submitTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="拒绝原因" align="center" key="rejectReason" prop="rejectReason" :show-overflow-tooltip="true" />
      <el-table-column label="操作" align="center" width="180" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-view" @click="handleView(scope.row)">查看</el-button>
          <el-button
            v-if="scope.row.status === 0"
            size="mini"
            type="text"
            icon="el-icon-check"
            style="color: #67C23A"
            @click="handleApprove(scope.row)"
          >
            通过
          </el-button>
          <el-button
            v-if="scope.row.status === 0"
            size="mini"
            type="text"
            icon="el-icon-close"
            style="color: #F56C6C"
            @click="handleReject(scope.row)"
          >
            拒绝
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <el-dialog title="实名认证详情" :visible.sync="detailDialogVisible" width="700px" append-to-body>
      <div v-if="currentAuth">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="用户账号">{{ currentAuth.userName }}</el-descriptions-item>
          <el-descriptions-item label="真实姓名">{{ currentAuth.realName }}</el-descriptions-item>
          <el-descriptions-item label="身份证号" :span="2">{{ currentAuth.idCardNumber }}</el-descriptions-item>
          <el-descriptions-item label="提交时间">{{ parseTime(currentAuth.submitTime) }}</el-descriptions-item>
          <el-descriptions-item label="审核状态">
            <el-tag v-if="currentAuth.status === 0" type="warning">待审核</el-tag>
            <el-tag v-else-if="currentAuth.status === 1" type="success">已通过</el-tag>
            <el-tag v-else-if="currentAuth.status === 2" type="danger">已拒绝</el-tag>
            <el-tag v-else type="info">未知</el-tag>
          </el-descriptions-item>
          <el-descriptions-item v-if="currentAuth.rejectReason" label="拒绝原因" :span="2">
            {{ currentAuth.rejectReason }}
          </el-descriptions-item>
        </el-descriptions>

        <div style="margin-top: 20px;">
          <p style="font-weight: bold; margin-bottom: 10px;">证件照片</p>
          <el-row :gutter="20">
            <el-col :span="8">
              <p style="text-align: center; margin-bottom: 5px;">身份证正面</p>
              <el-image
                v-if="currentAuth.idCardFront"
                :src="currentAuth.idCardFront"
                :preview-src-list="[currentAuth.idCardFront]"
                style="width: 100%; height: 150px"
                fit="cover"
              />
              <div v-else style="width: 100%; height: 150px; background: #f5f7fa; display: flex; align-items: center; justify-content: center;">无</div>
            </el-col>
            <el-col :span="8">
              <p style="text-align: center; margin-bottom: 5px;">身份证反面</p>
              <el-image
                v-if="currentAuth.idCardBack"
                :src="currentAuth.idCardBack"
                :preview-src-list="[currentAuth.idCardBack]"
                style="width: 100%; height: 150px"
                fit="cover"
              />
              <div v-else style="width: 100%; height: 150px; background: #f5f7fa; display: flex; align-items: center; justify-content: center;">无</div>
            </el-col>
            <el-col :span="8">
              <p style="text-align: center; margin-bottom: 5px;">手持身份证</p>
              <el-image
                v-if="currentAuth.handheldPhoto"
                :src="currentAuth.handheldPhoto"
                :preview-src-list="[currentAuth.handheldPhoto]"
                style="width: 100%; height: 150px"
                fit="cover"
              />
              <div v-else style="width: 100%; height: 150px; background: #f5f7fa; display: flex; align-items: center; justify-content: center;">无</div>
            </el-col>
          </el-row>
        </div>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </div>
    </el-dialog>

    <el-dialog title="拒绝原因" :visible.sync="rejectDialogVisible" width="500px" append-to-body>
      <el-form ref="rejectForm" :model="rejectForm" :rules="rejectRules" label-width="80px">
        <el-form-item label="拒绝原因" prop="rejectReason">
          <el-input v-model="rejectForm.rejectReason" type="textarea" :rows="4" placeholder="请输入拒绝原因" />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="rejectDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitReject">确定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { parseTime } from '@/utils/ruoyi'
import { listRealNameAuth, updateRealNameAuth } from '@/api/system/realNameAuth'

export default {
  name: 'RealNameAuth',
  data() {
    return {
      loading: false,
      showSearch: true,
      total: 0,
      authList: [],
      detailDialogVisible: false,
      rejectDialogVisible: false,
      currentAuth: null,
      rejectForm: {
        authId: undefined,
        rejectReason: ''
      },
      rejectRules: {
        rejectReason: [{ required: true, message: '拒绝原因不能为空', trigger: 'blur' }]
      },
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        userName: undefined,
        realName: undefined,
        status: undefined
      },
      columns: [
        { key: 'authId', label: '认证ID', visible: true },
        { key: 'userName', label: '用户账号', visible: true },
        { key: 'realName', label: '真实姓名', visible: true },
        { key: 'idCardNumber', label: '身份证号', visible: true },
        { key: 'idCardFront', label: '身份证正面', visible: true },
        { key: 'idCardBack', label: '身份证反面', visible: true },
        { key: 'handheldPhoto', label: '手持照片', visible: true },
        { key: 'status', label: '审核状态', visible: true },
        { key: 'submitTime', label: '提交时间', visible: true },
        { key: 'rejectReason', label: '拒绝原因', visible: true }
      ]
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listRealNameAuth(this.queryParams)
        .then(response => {
          this.authList = response.rows || []
          this.total = response.total || 0
        })
        .finally(() => {
          this.loading = false
        })
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.queryParams = {
        pageNum: 1,
        pageSize: 10,
        userName: undefined,
        realName: undefined,
        status: undefined
      }
      this.handleQuery()
    },
    handleView(row) {
      this.currentAuth = { ...row }
      this.detailDialogVisible = true
    },
    handleApprove(row) {
      this.$confirm('确认通过该用户的实名认证申请？', '审核确认', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        return updateRealNameAuth({
          authId: row.authId,
          status: 1
        })
      }).then(() => {
        this.$modal.msgSuccess('审核通过成功')
        this.getList()
      }).catch(() => {})
    },
    handleReject(row) {
      this.rejectForm.authId = row.authId
      this.rejectForm.rejectReason = ''
      this.rejectDialogVisible = true
    },
    submitReject() {
      this.$refs.rejectForm.validate(valid => {
        if (!valid) {
          return
        }
        updateRealNameAuth({
          authId: this.rejectForm.authId,
          status: 2,
          rejectReason: this.rejectForm.rejectReason
        }).then(() => {
          this.$modal.msgSuccess('已拒绝')
          this.rejectDialogVisible = false
          this.getList()
        })
      })
    },
    parseTime(time) {
      return parseTime(time, '{y}-{m}-{d} {h}:{i}:{s}') || ''
    }
  }
}
</script>
