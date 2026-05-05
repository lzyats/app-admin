# Go-Api 后端 API 接口文档

> 本文档为 APP 端常用接口总览与约定说明。
> 模块级详细链路（前后端文件、缓存、改动清单）请优先参考 `docs/module_registry.md`。

> 推荐阅读顺序:
> - 先看 `docs/project_context.md`，确认全局规则。
> - 再看 `docs/module_registry.md`，找到具体模块链路。
> - 最后回到本文档确认接口路径、请求字段和返回字段。

---

## 快速入口

下面这些接口和场景最常用，建议优先查看：

- 认证登录：`/login`、`/register`、`/getInfo`
- APP 配置：`/app/config/bootstrap`
- 用户资料：`/system/user/profile`、`/system/user/profile/avatar`
- 钱包与资产：`/app/user/wallets`、`/app/user/wallet/log/investList`
- 投资认购：`/app/invest/order/contract/preview`、`/app/invest/order/submit`
- 充值提现：`/app/recharge/submit`、`/app/withdraw/submit`
- 银行卡：`/app/bankCard/list`、`/app/bankCard`
- 实名认证：`/app/auth/realName/status`、`/app/auth/realName/submit`
- 签到：`/app/sign/config`、`/app/sign/status`、`/app/sign/submit`

## 一、API 基础规范

### 1.1 接口前缀
- APP 业务接口：`/app/**`（默认需要登录认证）
- 认证接口：`/login`、`/register`、`/getInfo`、`/captchaImage`
- 后台管理接口：`/system/**`（后台权限）

### 1.2 认证方式
- Header：`Authorization: Bearer {token}`
- 登录成功后返回 `token`

### 1.3 请求格式
- `Content-Type: application/json`
- 大部分 APP 接口兼容明文 JSON 与加密包裹体 `data`

### 1.4 返回格式
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {}
}
```

---

## 二、认证相关接口

### 2.1 获取验证码
```http
GET /captchaImage
```

返回字段：
- `captchaEnabled`
- `uuid`
- `img`

### 2.2 用户登录
```http
POST /login
```

请求字段：
- `username`
- `password`
- `code`（验证码开启时）
- `uuid`（验证码开启时）

### 2.3 用户注册
```http
POST /register
```

请求字段：
- `username`
- `password`
- `nickName`
- `inviteCode`
- `code`（验证码开启时）
- `uuid`（验证码开启时）

说明：
- 注册开关：`sys.account.registerUser`
- 验证码开关：`sys.account.captchaEnabled`
- 邀请码展示开关：`app.feature.inviteCodeEnabled`

### 2.4 获取当前登录信息
```http
GET /getInfo
```

返回重点：
- `user.userId`
- `user.userName`
- `user.nickName`
- `user.avatar`
- `user.phonenumber`
- `user.email`
- `user.level`
- `user.inviteCode`
- `user.payPasswordSet`
- `user.realNameStatus`
- `roles`
- `permissions`

---

## 三、APP 用户常用接口

### 3.1 支付密码
```http
GET  /app/user/payPwd/check
POST /app/user/payPwd/set
PUT  /app/user/payPwd/update
POST /app/user/payPwd/verify
```

### 3.2 用户资料
```http
PUT  /system/user/profile
POST /system/user/profile/avatar
```

### 3.3 钱包与资产
```http
GET  /app/user/wallets
GET  /app/user/wallet/log/investList
```

### 3.4 充值与提现
```http
POST /app/recharge/submit
GET  /app/recharge/list
POST /app/withdraw/submit
GET  /app/withdraw/list
```

### 3.5 银行卡
```http
GET  /app/bankCard/list
POST /app/bankCard
POST /app/bankCard/delete
```

### 3.6 实名认证
```http
POST /app/auth/realName/status
POST /app/auth/realName/submit
```

### 3.7 签到
```http
GET  /app/sign/config
GET  /app/sign/status
POST /app/sign/submit
```

---

## 四、投资与理财接口

### 4.1 投资产品
```http
GET /app/invest/product/list
GET /app/invest/product/{productId}
```

### 4.2 投资认购
```http
POST /app/invest/order/contract/preview
POST /app/invest/order/submit
GET  /app/invest/order/list
GET  /app/invest/order/incomes
```

### 4.3 余额宝
```http
GET  /app/yebao/my
GET  /app/yebao/orders
GET  /app/yebao/incomes
POST /app/yebao/purchase
POST /app/yebao/redeem
```

---

## 五、团队与邀请接口

### 5.1 团队
```http
GET /app/team/stats/me
GET /app/team/reward/info
```

### 5.2 邀请与升级配置
```http
GET  /app/upgrade/config
GET  /app/config/bootstrap
POST /app/invite/qr
```

---

## 六、配置与缓存约定

- APP 初始化配置接口：`GET /app/config/bootstrap`
- 后台修改 `app.*` 配置后，必须重置配置缓存（`resetConfigCache()`）
- 新增 `app.*` 配置项时，需同步四处：
  - 后端 `AppConfigController`
  - `sys_config` 数据
  - Flutter `AppBootstrapConfigData`
  - 后台 `ruoyi-ui` 配置管理页

## 目录（按场景）

| 场景 | 重点接口 |
|---|---|
| 认证与会话 | `/captchaImage`、`/login`、`/register`、`/getInfo` |
| APP 配置 | `/app/config/bootstrap` |
| 用户资料 | `/system/user/profile`、`/system/user/profile/avatar` |
| 支付密码 | `/app/user/payPwd/check`、`/app/user/payPwd/set`、`/app/user/payPwd/update`、`/app/user/payPwd/verify` |
| 钱包与资产 | `/app/user/wallets`、`/app/user/wallet/log/investList` |
| 充值提现 | `/app/recharge/submit`、`/app/recharge/list`、`/app/withdraw/submit`、`/app/withdraw/list` |
| 银行卡 | `/app/bankCard/list`、`/app/bankCard`、`/app/bankCard/delete` |
| 实名认证 | `/app/auth/realName/status`、`/app/auth/realName/submit` |
| 签到 | `/app/sign/config`、`/app/sign/status`、`/app/sign/submit` |
| 投资与理财 | `/app/invest/product/list`、`/app/invest/product/{productId}`、`/app/invest/order/contract/preview`、`/app/invest/order/submit`、`/app/invest/order/list`、`/app/invest/order/incomes` |
| 团队与邀请 | `/app/team/stats/me`、`/app/team/reward/info`、`/app/upgrade/config`、`/app/invite/qr` |

---

## 七、维护说明

- 本文件用于接口总览，详细实现请以代码与模块文档为准。
- 推荐修改顺序：先看 `docs/module_registry.md` 对应模块，再改代码，再回写文档。
- 若新增 APP 功能，需同步更新：
  - `docs/module_registry.md`
  - 本文档（如涉及新接口）
