<template>
  <div class="app-container">
    <el-alert
      title="说明：类型为“首页Banner”用于首页顶部轮播；“首页广告”用于首页公告与广告位。摘要可填写跳转链接 URL。"
      type="info"
      :closable="false"
      show-icon
      style="margin-bottom: 12px"
    />

    <el-form ref="queryForm" :model="queryParams" size="small" :inline="true" label-width="80px">
      <el-form-item label="类型" prop="adType">
        <el-select v-model="queryParams.adType" placeholder="请选择类型" style="width: 160px" @change="handleQuery">
          <el-option label="首页Banner" value="APP_HOME_BANNER" />
          <el-option label="首页广告" value="APP_HOME_AD" />
        </el-select>
      </el-form-item>
      <el-form-item label="标题" prop="articleTitle">
        <el-input
          v-model="queryParams.articleTitle"
          placeholder="请输入标题"
          clearable
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="状态" clearable style="width: 120px">
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
    </el-row>

    <el-table v-loading="loading" :data="adList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="articleId" width="90" />
      <el-table-column label="类型" align="center" width="110">
        <template slot-scope="scope">
          <el-tag size="mini" :type="scope.row.categoryCode === 'APP_HOME_BANNER' ? 'primary' : 'success'">
            {{ scope.row.categoryCode === 'APP_HOME_BANNER' ? '首页Banner' : '首页广告' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="图片" align="center" width="110">
        <template slot-scope="scope">
          <el-image
            v-if="scope.row.coverImage"
            :src="getImageUrl(scope.row.coverImage)"
            fit="cover"
            style="width: 72px; height: 40px; border-radius: 6px"
          />
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="标题" align="center" prop="articleTitle" :show-overflow-tooltip="true" />
      <el-table-column label="链接URL(摘要)" align="center" prop="summary" :show-overflow-tooltip="true" />
      <el-table-column label="排序" align="center" prop="sortOrder" width="90" />
      <el-table-column label="状态" align="center" prop="status" width="100">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.sys_normal_disable" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="180" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
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

    <el-dialog :title="title" :visible.sync="open" width="760px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="110px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="广告类型" prop="categoryCode">
              <el-select v-model="form.categoryCode" placeholder="请选择类型" style="width: 100%">
                <el-option label="首页Banner" value="APP_HOME_BANNER" />
                <el-option label="首页广告" value="APP_HOME_AD" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="标题" prop="articleTitle">
              <el-input v-model="form.articleTitle" placeholder="请输入标题" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="图片" prop="coverImage">
              <image-upload v-model="form.coverImage" :limit="1" :is-show-tip="false" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="排序" prop="sortOrder">
              <el-input-number v-model="form.sortOrder" :min="0" :controls="false" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-radio-group v-model="form.status">
                <el-radio v-for="dict in dict.type.sys_normal_disable" :key="dict.value" :label="dict.value">{{ dict.label }}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="置顶" prop="topFlag">
              <el-radio-group v-model="form.topFlag">
                <el-radio label="0">否</el-radio>
                <el-radio label="1">是</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="跳转链接URL">
              <el-input v-model="form.summary" placeholder="可选，填写 http(s) 链接" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="广告内容">
              <editor v-model="form.articleContent" :min-height="220" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注">
              <el-input v-model="form.remark" type="textarea" :rows="2" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { addAppAd, delAppAd, getAppAd, listAppAd, updateAppAd } from '@/api/system/appAd'

export default {
  name: 'AppAd',
  dicts: ['sys_normal_disable'],
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      total: 0,
      adList: [],
      open: false,
      title: '',
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        adType: 'APP_HOME_BANNER',
        articleTitle: undefined,
        status: undefined
      },
      form: {},
      rules: {
        categoryCode: [{ required: true, message: '请选择广告类型', trigger: 'change' }],
        articleTitle: [{ required: true, message: '请输入标题', trigger: 'blur' }],
        coverImage: [{ required: true, message: '请上传图片', trigger: 'change' }],
        status: [{ required: true, message: '请选择状态', trigger: 'change' }]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      const params = {
        pageNum: this.queryParams.pageNum,
        pageSize: this.queryParams.pageSize,
        articleTitle: this.queryParams.articleTitle,
        status: this.queryParams.status,
        categoryCode: this.queryParams.adType
      }
      listAppAd(params).then((response) => {
        this.adList = response.rows || []
        this.total = response.total || 0
        this.loading = false
      })
    },
    reset() {
      this.form = {
        articleId: undefined,
        categoryCode: this.queryParams.adType || 'APP_HOME_BANNER',
        articleTitle: undefined,
        summary: undefined,
        coverImage: undefined,
        articleContent: undefined,
        sortOrder: 0,
        topFlag: '0',
        status: '0',
        remark: undefined
      }
      this.resetForm('form')
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.resetForm('queryForm')
      this.queryParams.adType = 'APP_HOME_BANNER'
      this.handleQuery()
    },
    handleSelectionChange(selection) {
      this.ids = selection.map((item) => item.articleId)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '新增APP广告'
    },
    handleUpdate(row) {
      this.reset()
      const articleId = row && row.articleId ? row.articleId : this.ids[0]
      getAppAd(articleId).then((response) => {
        this.form = {
          ...response.data,
          categoryCode: response.data.categoryCode || this.queryParams.adType || 'APP_HOME_BANNER'
        }
        this.open = true
        this.title = '修改APP广告'
      })
    },
    cancel() {
      this.open = false
      this.reset()
    },
    submitForm() {
      this.$refs.form.validate((valid) => {
        if (!valid) return
        const payload = {
          articleId: this.form.articleId,
          categoryId: this.form.categoryId,
          categoryCode: this.form.categoryCode,
          articleTitle: this.form.articleTitle,
          summary: this.form.summary || '',
          coverImage: this.normalizeImageValue(this.form.coverImage),
          articleContent: this.form.articleContent || '',
          sortOrder: Number(this.form.sortOrder || 0),
          topFlag: this.form.topFlag || '0',
          status: this.form.status || '0',
          remark: this.form.remark || ''
        }
        const action = payload.articleId ? updateAppAd : addAppAd
        action(payload).then(() => {
          this.$modal.msgSuccess('操作成功')
          this.open = false
          this.getList()
        })
      })
    },
    handleDelete(row) {
      const articleIds = row && row.articleId ? [row.articleId] : this.ids
      this.$modal.confirm('是否确认删除所选APP广告？').then(() => delAppAd(articleIds.join(','))).then(() => {
        this.$modal.msgSuccess('删除成功')
        this.getList()
      }).catch(() => {})
    },
    getImageUrl(url) {
      if (!url) {
        return ''
      }
      if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('data:')) {
        return url
      }
      return process.env.VUE_APP_BASE_API + url
    },
    normalizeImageValue(value) {
      if (Array.isArray(value)) {
        return value.find((item) => typeof item === 'string' && item) || ''
      }
      if (value && typeof value === 'object') {
        if (typeof value.url === 'string' && value.url) {
          return value.url
        }
        if (typeof value.name === 'string' && value.name) {
          return value.name
        }
      }
      return typeof value === 'string' ? value : ''
    }
  }
}
</script>
