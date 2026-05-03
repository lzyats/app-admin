import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

import Layout from '@/layout'

export const constantRoutes = [
  {
    path: '/redirect',
    component: Layout,
    hidden: true,
    children: [
      {
        path: '/redirect/:path(.*)',
        component: () => import('@/views/redirect')
      }
    ]
  },
  {
    path: '/login',
    component: () => import('@/views/login'),
    hidden: true
  },
  {
    path: '/register',
    component: () => import('@/views/register'),
    hidden: true
  },
  {
    path: '/404',
    component: () => import('@/views/error/404'),
    hidden: true
  },
  {
    path: '/401',
    component: () => import('@/views/error/401'),
    hidden: true
  },
  {
    path: '',
    component: Layout,
    redirect: 'index',
    children: [
      {
        path: 'index',
        component: () => import('@/views/index'),
        name: 'Index',
        meta: { title: '首页', icon: 'dashboard', affix: true }
      }
    ]
  },
  {
    path: '/lock',
    component: () => import('@/views/lock'),
    hidden: true,
    meta: { title: '锁定屏幕' }
  },
  {
    path: '/user',
    component: Layout,
    hidden: true,
    redirect: 'noredirect',
    children: [
      {
        path: 'profile',
        component: () => import('@/views/system/user/profile/index'),
        name: 'Profile',
        meta: { title: '个人中心', icon: 'user' }
      }
    ]
  },
  {
    path: '/system/wallet',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'index',
        component: () => import('@/views/system/wallet/index'),
        name: 'WalletHidden',
        meta: { title: '钱包管理', activeMenu: '/system/user' }
      }
    ]
  },
  {
    path: '/system/growth',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'index',
        component: () => import('@/views/system/growth/index'),
        name: 'GrowthHidden',
        meta: { title: '成长值管理', activeMenu: '/system/user' }
      }
    ]
  },
  {
    path: '/operation/recharge',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/recharge/index'),
        name: 'RechargeHidden',
        meta: { title: '充值管理', activeMenu: '/operation/recharge/index' }
      }
    ]
  },
  {
    path: '/operation/bankCard',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/bankCard/index'),
        name: 'BankCardHidden',
        meta: { title: '银行卡管理', activeMenu: '/operation/bankCard/index' }
      }
    ]
  },
  {
    path: '/operation/investProduct',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/investProduct/index'),
        name: 'InvestProductHidden',
        meta: { title: '投资产品管理', activeMenu: '/operation/investProduct/index' }
      }
    ]
  },
  {
    path: '/operation/couponTemplate',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/couponTemplate/index'),
        name: 'CouponTemplateHidden',
        meta: { title: '优惠券模板', activeMenu: '/operation/couponTemplate/index' }
      }
    ]
  },
  {
    path: '/operation/levelTrial',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/levelTrial/index'),
        name: 'LevelTrialHidden',
        meta: { title: '等级体验券', activeMenu: '/operation/levelTrial/index' }
      }
    ]
  },
  {
    path: '/operation/investTag',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/investTag/index'),
        name: 'InvestTagHidden',
        meta: { title: '投资标签管理', activeMenu: '/operation/investTag/index' }
      }
    ]
  },
  {
    path: '/operation/teamLevel',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/teamLevel/index'),
        name: 'TeamLevelHidden',
        meta: { title: '团队等级', activeMenu: '/operation/teamLevel/index' }
      }
    ]
  },
  {
    path: '/operation/teamStats',
    component: Layout,
    hidden: true,
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/teamStats/index'),
        name: 'TeamStatsHidden',
        meta: { title: '我的团队统计', activeMenu: '/operation/teamStats/index' }
      }
    ]
  }
]

export const dynamicRoutes = [
  {
    path: '/system/wallet',
    component: Layout,
    hidden: true,
    permissions: ['system:user:list', 'system:user:edit'],
    children: [
      {
        path: 'index',
        component: () => import('@/views/system/wallet/index'),
        name: 'Wallet',
        meta: { title: '钱包管理', activeMenu: '/system/user' }
      }
    ]
  },
  {
    path: '/system/growth',
    component: Layout,
    hidden: true,
    permissions: ['system:user:list', 'system:user:edit'],
    children: [
      {
        path: 'index',
        component: () => import('@/views/system/growth/index'),
        name: 'Growth',
        meta: { title: '成长值管理', activeMenu: '/system/user' }
      }
    ]
  },
  {
    path: '/operation/recharge',
    component: Layout,
    hidden: true,
    permissions: ['operation:recharge:list'],
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/recharge/index'),
        name: 'Recharge',
        meta: { title: '充值管理', activeMenu: '/operation/recharge/index' }
      }
    ]
  },
  {
    path: '/operation/bankCard',
    component: Layout,
    hidden: true,
    permissions: ['operation:bankCard:list'],
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/bankCard/index'),
        name: 'BankCard',
        meta: { title: '银行卡管理', activeMenu: '/operation/bankCard/index' }
      }
    ]
  },
  {
    path: '/operation/investProduct',
    component: Layout,
    hidden: true,
    permissions: ['system:invest:list'],
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/investProduct/index'),
        name: 'InvestProduct',
        meta: { title: '投资产品管理', activeMenu: '/operation/investProduct/index' }
      }
    ]
  },
  {
    path: '/operation/couponTemplate',
    component: Layout,
    hidden: true,
    permissions: ['system:invest:list'],
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/couponTemplate/index'),
        name: 'CouponTemplate',
        meta: { title: '优惠券模板', activeMenu: '/operation/couponTemplate/index' }
      }
    ]
  },
  {
    path: '/operation/levelTrial',
    component: Layout,
    hidden: true,
    permissions: ['system:invest:list'],
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/levelTrial/index'),
        name: 'LevelTrial',
        meta: { title: '等级体验券', activeMenu: '/operation/levelTrial/index' }
      }
    ]
  },
  {
    path: '/operation/investTag',
    component: Layout,
    hidden: true,
    permissions: ['system:invest:list'],
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/investTag/index'),
        name: 'InvestTag',
        meta: { title: '投资标签管理', activeMenu: '/operation/investTag/index' }
      }
    ]
  },
  {
    path: '/operation/teamLevel',
    component: Layout,
    hidden: true,
    permissions: ['system:teamLevel:list'],
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/teamLevel/index'),
        name: 'TeamLevel',
        meta: { title: '团队等级', activeMenu: '/operation/teamLevel/index' }
      }
    ]
  },
  {
    path: '/operation/teamStats',
    component: Layout,
    hidden: true,
    permissions: ['system:teamStats:list'],
    children: [
      {
        path: 'index',
        component: () => import('@/views/operation/teamStats/index'),
        name: 'TeamStats',
        meta: { title: '我的团队统计', activeMenu: '/operation/teamStats/index' }
      }
    ]
  },
  {
    path: '/system/user-auth',
    component: Layout,
    hidden: true,
    permissions: ['system:user:edit'],
    children: [
      {
        path: 'role/:userId(\\d+)',
        component: () => import('@/views/system/user/authRole'),
        name: 'AuthRole',
        meta: { title: '分配角色', activeMenu: '/system/user' }
      }
    ]
  },
  {
    path: '/system/role-auth',
    component: Layout,
    hidden: true,
    permissions: ['system:role:edit'],
    children: [
      {
        path: 'user/:roleId(\\d+)',
        component: () => import('@/views/system/role/authUser'),
        name: 'AuthUser',
        meta: { title: '分配用户', activeMenu: '/system/role' }
      }
    ]
  },
  {
    path: '/system/dict-data',
    component: Layout,
    hidden: true,
    permissions: ['system:dict:list'],
    children: [
      {
        path: 'index/:dictId(\\d+)',
        component: () => import('@/views/system/dict/data'),
        name: 'Data',
        meta: { title: '字典数据', activeMenu: '/system/dict' }
      }
    ]
  },
  {
    path: '/monitor/job-log',
    component: Layout,
    hidden: true,
    permissions: ['monitor:job:list'],
    children: [
      {
        path: 'index/:jobId(\\d+)',
        component: () => import('@/views/monitor/job/log'),
        name: 'JobLog',
        meta: { title: '调度日志', activeMenu: '/monitor/job' }
      }
    ]
  },
  {
    path: '/tool/gen-edit',
    component: Layout,
    hidden: true,
    permissions: ['tool:gen:edit'],
    children: [
      {
        path: 'index/:tableId(\\d+)',
        component: () => import('@/views/tool/gen/editTable'),
        name: 'GenEdit',
        meta: { title: '修改生成配置', activeMenu: '/tool/gen' }
      }
    ]
  }
]

let routerPush = Router.prototype.push
let routerReplace = Router.prototype.replace

Router.prototype.push = function push(location) {
  return routerPush.call(this, location).catch(err => err)
}

Router.prototype.replace = function replace(location) {
  return routerReplace.call(this, location).catch(err => err)
}

export default new Router({
  mode: 'history',
  scrollBehavior: () => ({ y: 0 }),
  routes: constantRoutes
})
