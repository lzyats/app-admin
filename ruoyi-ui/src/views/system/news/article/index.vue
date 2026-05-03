<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="88px">
      <el-form-item label="文章标题" prop="articleTitle">
        <el-input v-model="queryParams.articleTitle" placeholder="请输入文章标题" clearable @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="分类" prop="categoryId">
        <el-select v-model="queryParams.categoryId" placeholder="请选择分类" clearable style="width: 180px">
          <el-option v-for="item in categoryOptions" :key="item.categoryId" :label="item.categoryName" :value="item.categoryId" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="文章状态" clearable style="width: 140px">
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

    <el-table v-loading="loading" :data="articleList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="articleId" width="90" />
      <el-table-column label="封面" align="center" width="90">
        <template slot-scope="scope">
          <el-image v-if="scope.row.coverImage" :src="getCoverImageUrl(scope.row.coverImage)" fit="cover" style="width: 56px; height: 40px; border-radius: 6px" />
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="文章标题" align="center" prop="articleTitle" :show-overflow-tooltip="true" />
      <el-table-column label="分类" align="center" prop="categoryName" width="140" />
      <el-table-column label="置顶" align="center" prop="topFlag" width="80">
        <template slot-scope="scope">
          <el-tag :type="scope.row.topFlag === '1' ? 'danger' : 'info'">{{ scope.row.topFlag === '1' ? '是' : '否' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="排序" align="center" prop="sortOrder" width="90" />
      <el-table-column label="状态" align="center" prop="status" width="100">
        <template slot-scope="scope">
          <dict-tag :options="dict.type.sys_normal_disable" :value="scope.row.status" />
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="160">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime, '{y}-{m}-{d} {h}:{i}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="200" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button size="mini" type="text" icon="el-icon-delete" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" :visible.sync="open" width="860px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="90px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="分类" prop="categoryId">
              <el-select v-model="form.categoryId" placeholder="请选择分类" style="width: 100%">
                <el-option v-for="item in categoryOptions" :key="item.categoryId" :label="item.categoryName" :value="item.categoryId" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="文章标题" prop="articleTitle">
              <el-input v-model="form.articleTitle" placeholder="请输入文章标题" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="封面图" prop="coverImage">
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
            <el-form-item label="摘要">
              <el-input v-model="form.summary" type="textarea" :rows="3" maxlength="500" show-word-limit />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="内容">
              <editor v-model="form.articleContent" :min-height="320" />
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
        <el-button type="primary" @click="submitForm">确定</el-button>
        <el-button @click="cancel">取消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listNewsArticle, getNewsArticle, addNewsArticle, updateNewsArticle, delNewsArticle } from '@/api/system/news/article'
import { listNewsCategoryAll } from '@/api/system/news/category'

export default {
  name: 'NewsArticle',
  dicts: ['sys_normal_disable'],
  data() {
    return {
      loading: true,
      ids: [],
      single: true,
      multiple: true,
      showSearch: true,
      total: 0,
      articleList: [],
      categoryOptions: [],
      title: '',
      open: false,
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        articleTitle: undefined,
        categoryId: undefined,
        status: undefined
      },
      form: {},
      rules: {
        categoryId: [{ required: true, message: '请选择分类', trigger: 'change' }],
        articleTitle: [{ required: true, message: '请输入文章标题', trigger: 'blur' }],
        status: [{ required: true, message: '请选择状态', trigger: 'change' }],
        topFlag: [{ required: true, message: '请选择是否置顶', trigger: 'change' }]
      }
    }
  },
  created() {
    this.loadCategories()
    this.getList()
  },
  methods: {
    loadCategories() {
      listNewsCategoryAll().then((response) => {
        this.categoryOptions = response.data || []
      })
    },
    getList() {
      this.loading = true
      listNewsArticle(this.queryParams).then((response) => {
        this.articleList = response.rows
        this.total = response.total
        this.loading = false
      })
    },
    cancel() {
      this.open = false
      this.reset()
    },
    reset() {
      this.form = {
        articleId: undefined,
        categoryId: undefined,
        categoryCode: undefined,
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
      this.title = '新增文章'
    },
    handleUpdate(row) {
      this.reset()
      const articleId = row && row.articleId ? row.articleId : this.ids[0]
      getNewsArticle(articleId).then((response) => {
        this.form = response.data
        this.open = true
        this.title = '修改文章'
      })
    },
    getCoverImageUrl(url) {
      if (!url) {
        return ''
      }
      if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('data:')) {
        return url
      }
      return process.env.VUE_APP_BASE_API + url
    },
    submitForm() {
      this.$refs.form.validate((valid) => {
        if (!valid) return
        const currentCategory = this.categoryOptions.find((item) => item.categoryId === this.form.categoryId)
        const payload = {
          articleId: this.form.articleId,
          categoryId: this.toNumber(this.form.categoryId),
          categoryCode: currentCategory ? currentCategory.categoryCode : this.form.categoryCode,
          articleTitle: String(this.form.articleTitle || '').trim(),
          summary: this.form.summary || '',
          coverImage: this.normalizeImageValue(this.form.coverImage),
          articleContent: String(this.form.articleContent || ''),
          sortOrder: this.toNumber(this.form.sortOrder, 0),
          topFlag: this.form.topFlag,
          status: this.form.status,
          remark: this.form.remark || ''
        }
        const action = this.form.articleId ? updateNewsArticle : addNewsArticle
        action(JSON.parse(JSON.stringify(payload))).then(() => {
          this.$modal.msgSuccess('操作成功')
          this.open = false
          this.getList()
        })
      })
    },
    normalizeImageValue(value) {
      if (Array.isArray(value)) {
        const first = value.find((item) => typeof item === 'string' && item)
        return first || ''
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
    },
    toNumber(value, defaultValue = 0) {
      const num = Number(value)
      return Number.isFinite(num) ? num : defaultValue
    },
    handleDelete(row) {
      const articleIds = row && row.articleId ? [row.articleId] : this.ids
      this.$modal.confirm('是否确认删除选中的文章？').then(() => delNewsArticle(articleIds.join(','))).then(() => {
        this.getList()
        this.$modal.msgSuccess('删除成功')
      }).catch(() => {})
    }
  }
}
</script>


