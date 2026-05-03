# 项目全局上下文 - Trae 永久记忆文件 
 > 所有AI编码、修改、优化、新增功能，必须严格遵守本文档约束，不得擅自变更规则 
 
 ## 一、项目基础信息 
 - 项目名称：投资理财后台系统 
 - 开发框架：RuoYi-Vue 若依框架 
 - 后端语言：Java / SpringBoot / MySQL 
 - 数据库：MySQL 8.0 
 - 前端：Vue2 / ElementUI 
 - 移动端：Flutter 
 - 架构模式：单体架构、后台管理系统 + 移动端应用 
 
 ## 二、双币种核心业务规则【强制记住】 
 1. 币种类型：CNY 人民币、USD 美元 
 2. 系统基准货币：固定以 CNY 人民币为唯一统计基准 
 3. 用户个人配置：sys_user 表 default_currency 为历史字段，APP 不再作为默认币种切换入口使用 
 4. 汇率存储：存放于系统配置 sys_config 
    - app.currency.usdRate ：1美元 兑换 人民币 
 5. 三种模式说明 
    - 1: 单币种（人民币）：无论后台还是前端，只使用人民币进行结算和显示 
    - 2: 双币种：用户同时拥有人民币钱包和美元钱包，APP 不再提供默认币种切换入口 
    - 3: 双币种（双钱包）：新用户默认生成双币种钱包，一个人民币，一个美元，两个钱包相对独立，用户可进行钱包切换和余额互换 
 6. 钱包设计方案 
    - 采用：独立双钱包设计 
    - 一个用户对应多条钱包数据，按 currency 隔离 
    - 唯一索引：user_id + currency 
 7. 资产&金额计算规则 
    - 所有币种资产、投资金额、充值、收益，统计时**先统一换算为基准CNY再累加** 
    - 订单必须保存：交易时真实币种、原始金额、当时汇率、基准金额 
    - 历史订单金额锁定当时汇率，不受后续汇率波动影响 
8. 汇兑规则 
    - 系统不自动货币兑换 
    - 如需跨币种使用资金，需单独开发兑换功能，手动互转 
    - 人民币兑换美元时，需检查是否支持人民币兑换美元，或是否在可兑换美元额度内 
    - 美元兑换人民币时，自动增加可兑换美元额度 
9. 用户表与前端用户信息类必须同步维护：`sys_user` 字段变更后，必须同步更新后端 `getInfo` 返回结构和 Flutter 的 `AuthUserProfile` 模型，避免页面因为字段缺失报错 
9. 用户表与前端用户信息类必须同步维护：`sys_user` 字段变更后，必须同步更新后端 `getInfo` 返回结构和 Flutter 的 `AuthUserProfile` 模型，避免页面因为字段缺失报错 
 
 ## 三、已完成数据库变更 
 1. sys_user 增加 default_currency 字段，作为历史兼容字段保留，APP 不再依赖该字段 
 2. sys_user 增加 usd_balance 字段，存储美元余额 
3. sys_user_wallet 增加 usd_exchange_quota 字段，存储可兑换美元额度
 4. 系统配置新增：美元汇率、投资货币方式、支持人民币兑换美元配置项 
 5. 钱包表、账变表 支持多币种存储结构 
 6. 创建 currency_exchange_log 表，记录货币互换操作 
 
 ## 四、数据表约束 
 1. 所有金额字段：decimal 类型，保留2位或4位小数 
 2. 所有流水、订单、账单必须留存操作时间、币种、汇率快照 
 3. 后台管理员提醒：基于原生 sys_notice 实现，业务触发直接插入通知记录 
 
 ## 五、UI&后台规则 
 1. 后台右上角铃铛通知，用于业务待办、异常提醒、审核通知 
 2. 支持浏览器原生语音播报（普通话），新业务提醒可触发朗读 
 3. 所有列表页面，金额按当前业务币种规则展示 
 4. 移动端应用根据投资货币方式动态调整UI和功能 
 
 ## 六、AI 开发约束（永久生效） 
 1. 后续新增表、接口、业务，必须兼容双币种结构 
 2. 不准私自删减现有字段、不准修改已确定的基准货币规则 
 3. 改动代码只做最小改动，兼容原有若依代码风格 
4. 给出SQL必须可直接执行、支持重复执行、兼容旧数据 
5. 代码注释完整、便于后期维护 
6. 移动端应用必须根据投资货币方式动态调整UI和功能 
7. 所有API请求必须使用加密模式，确保数据安全
8. 当前保留的 SQL 基线文件仅以 `ry_20260417.sql` 为准，其他临时追加的 SQL 已清理；后续如需变更用户表或配置表，必须以幂等迁移脚本或更新基线文件的方式记录，并同步更新后端与 Flutter

## 七、全局配置添加方法【永久记住】

当需要添加新的全局配置项时，必须同时修改以下所有位置，确保配置在后台系统、数据库和移动端应用三层保持一致。

### 1. 后端Java代码修改
- **文件**：`ruoyi-admin/src/main/java/com/ruoyi/web/controller/common/AppConfigController.java`
- **常量定义**：在类顶部添加新的常量定义（ITEM_XXX 和 KEY_XXX）
- **bootstrap方法**：添加新的数据读取逻辑，使用readBool/readInt/readDouble/readString方法
- **options方法**：添加新的配置项到列表中
```java
private static final String ITEM_XXX = "xxx";
private static final String KEY_XXX = "app.xxx.xxx";

if (selected.contains(ITEM_XXX)) {
    data.put(ITEM_XXX, readBool(KEY_XXX, false)); // 或 readInt/readDouble/readString
}

data.add(buildOption(ITEM_XXX, KEY_XXX, "配置显示名称", defaultValue));
```

### 2. 数据库配置记录
- **表**：sys_config
- **字段**：config_id, config_name, config_key, config_value, config_type, create_by, create_time, update_by, update_time, remark
- **添加方式**：使用INSERT IGNORE或存储过程检查是否存在
```sql
INSERT IGNORE INTO sys_config (config_name, config_key, config_value, config_type, create_by, create_time, update_by, update_time, remark)
VALUES ('配置显示名称', 'app.xxx.xxx', '默认值', 'Y', 'admin', NOW(), 'admin', NOW(), '配置说明');
```

### 3. Vue前端管理页面
- **文件**：`ruoyi-ui/src/views/system/appConfig/index.vue`
- **DEFAULT_OPTIONS数组**：添加新的配置项定义
```javascript
{
  item: 'xxx',
  name: '配置显示名称',
  configKey: 'app.xxx.xxx',
  defaultValue: 默认值,
  valueType: 'bool' // 或 'number', 'string', 'currencyMode'
}
```
- **模板部分**：如果valueType为特殊类型，需要添加对应的输入控件
- **parseValue方法**：如果valueType为特殊类型，添加对应的解析逻辑
- **saveItem方法**：如果valueType为特殊类型，添加对应的保存逻辑

### 4. Flutter移动端应用
- **文件**：`app/lib/request/app_config_api.dart`
- **AppBootstrapConfigData类**：添加新的字段和getter
```dart
final type xxx;
```
- **getByItem/getByItemInt/getByItemDouble/getByItemString方法**：添加对应的case
- **toJson/fromJson方法**：添加新字段的序列化/反序列化
- **defaults常量**：添加新字段的默认值
- **AppConfigOptionItem类**：添加新的常量定义
- **AppConfigOptionItem.all列表**：添加新配置项
- **AppConfigOptionItemMeta.defaults列表**：添加新配置项的元数据

### 5. 配置使用位置
- **后台系统**：在相应的业务逻辑中使用configService.selectConfigByKey(key)读取
- **移动端应用**：使用AppBootstrapConfigData的实例方法读取，如`AppBootstrapTool.config.investCurrencyMode`

### 6. 重要约束
- 配置键必须以`app.`开头，遵循分层命名规范
- 每个配置项必须在后台系统、数据库和移动端应用三层同时添加
- 遵循现有代码风格，保持最小改动原则
- 所有修改必须同步更新到本记忆文件
 

## 十二、Flutter Web 跨域问题记录【永久记忆】
Flutter Web 在本地开发时，常见页面地址是 `http://localhost:51993`，后端地址是 `http://192.168.140.1:8080`。即使两边都是 HTTP，只要协议、主机或端口任一项不同，浏览器就会判定为跨域。

### 现象
- 页面请求后端时返回 `DioExceptionType.connectionError`
- 浏览器开发者工具里看得到请求头，但响应头为空或预检失败
- 请求常带 `Authorization`、`Device`、`Version`、`X-Api-Encrypt`、`X-Api-Secret`，会触发 `OPTIONS` 预检

### 已确认根因
- `Referer` 防盗链配置不等于 CORS
- 后端必须允许浏览器当前 origin
- 后端必须允许自定义请求头和 `OPTIONS` 预检
- 只配置部分请求头会导致 Flutter Web 看起来“发出去了”，但浏览器直接拦截

### 处理要求
- 后端 CORS 配置要同时放行：
  - `Authorization`
  - `Device`
  - `Version`
  - `X-Api-Encrypt`
  - `X-Api-Secret`
- 后端必须对 `OPTIONS` 请求放行
- `ruoyi-admin` 和 `ruoyi-framework` 中的 CORS 配置要保持一致，避免一处放行、一处拦截

### 经验结论
- Flutter Web 不要依赖本地代理绕过浏览器策略
- 发现 `connectionError` 且浏览器显示 `onError` 时，优先检查 CORS 预检和响应头
- 如果请求头越来越多，CORS 白名单必须同步更新

## 十三、APP 用户信息缓存服务【永久记忆】
为了避免 APP 首页、个人信息页、后台用户详情页重复直查数据库，系统用户信息统一通过 `ISysUserService` 入口访问，并在服务层接入 Redis 缓存。

### 1. 统一读取规则
- `selectUserById(Long userId)`
- `selectUserByUserName(String userName)`
- `selectUserByInviteCode(String inviteCode)`

以上查询先读 Redis，命中直接返回；未命中时再查数据库，查到后写回缓存。

### 2. 缓存 Key 规则
- `cache:app:user:v2:id:{userId}`
- `cache:app:user:v2:name:{userName}`
- `cache:app:user:v2:invite:{inviteCode}`

APP 端“我的 / 个人信息 / 安全中心”页面优先读取本地缓存的用户资料，只有缓存缺失或明确需要刷新时才请求 `getInfo`。

### 3. 失效规则
所有会修改用户主数据的入口，在数据库更新成功后必须清理缓存，包括但不限于：
- 新增用户
- 用户注册
- 修改用户资料
- 修改头像
- 修改登录信息
- 重置密码
- 修改支付密码
- `payPasswordSet` 是 `getInfo` 返回的派生状态字段，必须随着 `pay_password` 的写入结果同步返回给 APP 前端
- 用户币种偏好字段为历史字段，APP 不再提供默认币种切换入口
- 修改状态
- 删除用户

### 4. 接入位置
- 后台登录后获取用户信息：`SysLoginController.getInfo`
- APP 端获取个人资料：`AppUserController`、`AppAuthController`
- 后台用户详情页：`SysUserController`
- 用户资料页：`SysProfileController`

### 5. 维护要求
- 以后新增用户字段时，若会影响页面展示或登录态，优先复用这套缓存服务
- 写库成功后再失效缓存，避免写库失败导致缓存被提前删除
- 不要在控制器层直接查表，统一走 `ISysUserService`
- 修改 `sys_user` 字段时的检查清单：
  1. 先确认该字段是否属于历史兼容字段，若是历史字段要在注释里明确说明
  2. 若 `getInfo` 页面会用到，必须同步更新 `SysUser`、`SysUserMapper.xml` 和 `SysLoginController.getInfo`
  3. 若 APP 个人信息页或“我的”页会展示，必须同步更新 Flutter 的 `AuthUserProfile` 和对应页面
  4. 若字段会影响登录态或页面决策逻辑，优先在 `getInfo` 里返回派生状态字段，而不是让 Flutter 单独猜测
  5. 改完后必须检查永久文档里的接口示例与字段说明是否同步更新
- `payPasswordSet` 是 `getInfo` 返回的派生状态字段，必须随着 `pay_password` 的写入结果同步返回给 APP 前端

## 十四、登录与会话职责分工【永久记忆】
为了避免用户信息、登录态和 token 刷新职责混乱，登录链路按下面规则分层：

### 1. 用户加载层
- `UserDetailsServiceImpl`
- 负责根据用户名加载用户对象
- 底层必须先走 `ISysUserService`，再由缓存服务回源数据库

### 2. 登录校验层
- `SysLoginService`
- 负责验证码校验、登录前置校验、认证失败/成功日志、登录成功后记录登录信息
- 不负责保存用户基础资料

### 3. 登录态层
- `TokenService`
- 负责 token 创建、刷新、获取、删除
- 只管理会话，不承载用户资料的读写

### 4. 用户缓存层
- `SysUserApiServiceImpl`
- 负责用户信息的 Redis 缓存读写
- 缓存 key 统一按 `userId / userName / inviteCode` 三种维度组织

### 5. 用户业务层
- `SysUserServiceImpl`
- 作为统一用户服务入口
- 读取时委托缓存层，写入成功后失效缓存

## 十五、实名认证状态同步规则【永久记忆】
1. `sys_user.real_name_status` 是 APP 端和后台页统一使用的实名认证状态来源，不再要求前端单独查询实名表。
2. 状态含义统一为：
   - `0`：未实名
   - `1`：已提交
   - `2`：驳回
   - `3`：已实名
3. 实名表发生变化时，必须同步维护用户表的 `real_name_status`：
   - 新增实名记录或重新提交时，写入 `1`
   - 审核通过时，写入 `3`
   - 审核驳回时，写入 `2`
   - 删除实名记录或清空实名记录时，回落到 `0`
4. APP 端“我的 / 个人信息 / 实名认证”页面只能读取 `getInfo.user.realNameStatus`，禁止再单独调用实名状态查询接口作为主流程。
5. 后端 `getInfo` 返回用户基础信息时，必须同步带出 `realNameStatus`，Flutter 的 `AuthUserProfile` 也必须同步维护。

## 十六、APP 配置缓存失效规则【永久记忆】
1. `http://192.168.140.1:8080/app/config/bootstrap` 是 APP 初始化配置聚合接口，必须和后台 `sys_config` 保持一致。
2. 只要后台 APP 基础配置发生变化，就必须清空并重建 Redis 中的配置缓存，不能只更新单个 key 造成脏读。
3. 当前配置服务约定：
   - `insertConfig`
   - `updateConfig`
   - `deleteConfigByIds`
   这些写操作成功后都要执行 `resetConfigCache()`
4. 后台 `system/config` 页面保存后也必须刷新配置缓存，确保 APP 下一次启动或刷新时拿到最新值。
5. 如果后续再新增 `app.*` 配置项，必须同时更新：
   - 后端 `AppConfigController`
   - `sys_config` 数据
   - Flutter `AppBootstrapConfigData`
   - 后台 `ruoyi-ui` 配置管理页

## 十五、实名认证状态同步规则【永久记忆】
1. `sys_user.real_name_status` 是 APP 端和后台页统一使用的实名认证状态来源，不再要求前端单独查询实名表。
2. 状态含义统一为：
   - `0`：未实名
   - `1`：已提交
   - `2`：驳回
   - `3`：已实名
3. 实名表发生变化时，必须同步维护用户表的 `real_name_status`：
   - 新增实名记录或重新提交时，写入 `1`
   - 审核通过时，写入 `3`
   - 审核驳回时，写入 `2`
   - 删除实名记录或清空实名记录时，回落到 `0`
4. APP 端“我的 / 个人信息 / 实名认证”页面只能读取 `getInfo.user.realNameStatus`，禁止再单独调用实名状态查询接口作为主流程。
5. 后端 `getInfo` 返回用户基础信息时，必须同步带出 `realNameStatus`，Flutter 的 `AuthUserProfile` 也必须同步维护。

## 十六、APP 配置缓存失效规则【永久记忆】
1. `http://192.168.140.1:8080/app/config/bootstrap` 是 APP 初始化配置聚合接口，必须和后台 `sys_config` 保持一致。
2. 只要后台 APP 基础配置发生变化，就必须清空并重建 Redis 中的配置缓存，不能只更新单个 key 造成脏读。
3. 当前配置服务约定：
   - `insertConfig`
   - `updateConfig`
   - `deleteConfigByIds`
   这些写操作成功后都要执行 `resetConfigCache()`
4. 后台 `system/config` 页面保存后也必须刷新配置缓存，确保 APP 下一次启动或刷新时拿到最新值。
5. 如果后续再新增 `app.*` 配置项，必须同时更新：
   - 后端 `AppConfigController`
   - `sys_config` 数据
   - Flutter `AppBootstrapConfigData`
   - 后台 `ruoyi-ui` 配置管理页

## 15. ?? / ?? / ?? / ??? ??????????

### 15.1 ???????
- ??????????????????????? `zh-CN.json`?
- `assetsRmb` ???????????????????????RMB??
- ????????????????????????????????????

### 15.2 ?????
- ???? `app.currency.investMode` ?????/????
  - `1`??????????????
  - `2`????????????? USDT ???
- ??????????????????
- ?????????????
  - ???
  - ????
  - ????
  - ????
  - ????
  - ????
  - ????
  - ????
- ???????????????????????????????????

### 15.3 ???
- ????????????????????????
- ??????? / ????????
  - ????????????
  - ???????????? USDT ?????
- ??????????????????????????
- ?????????????????????

### 15.4 ???
- ????????????????????
- ???????????????????????????????????????????
- ??????? / ?????????????????????????

### 15.5 ????
- ???????????????
- ?????????????
- ??????????????? USD ?????
- ??????????????????
- RMB ?????????????? RMB?

### 15.6 ????
- ?????????????????????????????
- ?????????????????????
  - Flutter ??
  - `zh-CN.json`
  - `en-US.json`
  - ?????????
- ????????????????????????
