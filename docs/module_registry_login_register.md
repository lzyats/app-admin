# 登录与注册模块永久说明

> 目的：记录 APP 端登录、注册、`getInfo`、个人资料同步的轻量化约定，避免后续修改其他模块时把这条链路改重、改慢或改失效。

## 1. 模块目标

- APP 端登录与注册要尽量轻量，不走 UI 后台那种完整权限树和联表路径。
- 登录成功后先保存 token，再异步刷新个人资料。
- 注册成功后直接签发 APP token，做到自动登录。
- `getInfo` 只补齐基础资料，不承担 UI 后台完整权限数据职责。
- UI 后台仍保持原有完整权限逻辑，不与 APP 轻量路径互相影响。

## 2. 前端文件

APP 侧主要文件：

- [app/lib/pages/auth/login/login_controller.dart](../app/lib/pages/auth/login/login_controller.dart)
- [app/lib/pages/auth/login/login_page.dart](../app/lib/pages/auth/login/login_page.dart)
- [app/lib/pages/auth/register/register_controller.dart](../app/lib/pages/auth/register/register_controller.dart)
- [app/lib/pages/auth/register/register_page.dart](../app/lib/pages/auth/register/register_page.dart)
- [app/lib/request/auth_api.dart](../app/lib/request/auth_api.dart)
- [app/lib/tools/auth_tool.dart](../app/lib/tools/auth_tool.dart)
- [app/lib/tools/app_bootstrap_tool.dart](../app/lib/tools/app_bootstrap_tool.dart)

前端职责：

- `LoginController` 负责登录提交、验证码刷新、token 保存。
- `RegisterController` 负责注册提交、自动登录、个人资料异步刷新。
- `AuthApi` 负责 `/login`、`/register`、`/getInfo` 等认证接口。
- `AuthTool` 负责本地 token 和用户资料缓存。
- `AppBootstrapTool` 只保留 APP 必需的基础开关读取，不承载 UI 后台完整配置展示。

## 3. 后端文件

认证与轻量用户读取相关文件：

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysLoginController.java)
- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysRegisterController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysRegisterController.java)
- [ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/UserDetailsServiceImpl.java](../ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/UserDetailsServiceImpl.java)
- [ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysLoginService.java](../ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/SysLoginService.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserService.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/ISysUserService.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserMapper.java)
- [ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml)

后端职责：

- `SysLoginController` 负责登录和 `getInfo`，APP 场景下只返回基础资料。
- `SysRegisterController` 负责注册后直接签发 APP token。
- `UserDetailsServiceImpl` 负责认证时读取用户数据，APP 场景走轻量查询。
- `SysUserServiceImpl` 负责基础用户信息读取和缓存失效。
- `SysUserMapper.xml` 把 APP 轻量查询和 UI 完整联表查询拆开。

## 4. API 说明

### 4.1 登录

```http
POST /login
```

说明：

- APP 登录成功后直接返回 token。
- 登录提交后不等待完整个人资料刷新，资料同步放到后台异步执行。

### 4.2 注册

```http
POST /register
```

说明：

- APP 注册成功后直接返回 token。
- 前端拿到 token 后立即写入登录态，不再要求用户二次登录。
- 注册后的个人资料刷新可以后台异步执行，不阻塞页面跳转。

### 4.3 当前登录信息

```http
GET /getInfo
```

说明：

- APP 侧只返回基础用户信息。
- APP 侧 `roles` 和 `permissions` 可以返回空数组。
- UI 后台仍保留完整返回值和权限树。

## 5. 缓存与性能

- 登录后保存 token 先于个人资料刷新完成。
- `getInfo` 只负责补齐昵称、头像、手机号、实名状态、支付密码状态等基础字段。
- 用户资料更新、头像更新、实名审核通过后都要清理用户缓存，避免多端看到旧值。
- 登录、注册、个人信息这三类接口尽量避免联表，优先走主表轻查询。

## 6. 业务规则

- 昵称为空时，前端默认显示“用户”。
- 注册成功自动登录。
- APP 端不要依赖 UI 后台权限树驱动首页。
- APP 端认证链路坚持“少查询、少等待、少联表”。

## 7. 构建与验证

后端编译校验：

```powershell
mvn -q -pl ruoyi-admin,ruoyi-system -am -DskipTests compile
```

建议验证点：

- 注册后是否立刻进入已登录态。
- 登录提交后是否明显减少等待时间。
- 头像、昵称、实名状态更新后，重新进入页面能否同步到最新值。
- UI 后台权限逻辑是否不受 APP 轻量查询影响。

## 8. 个人资料更新规则

### 8.1 模块目标

- APP 个人信息页只更新资料页允许修改的字段。
- 提交成功后必须立刻清理用户缓存，避免多端和登录态继续读到旧值。
- 不允许把登录态里整份 `SysUser` 对象直接回写数据库。
- 实名状态、角色、菜单、部门、登录信息等系统字段不得被个人资料接口覆盖。

### 8.2 后端文件

个人资料相关文件：

- [ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysProfileController.java](../ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/SysProfileController.java)
- [ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java](../ruoyi-system/src/main/java/com/ruoyi/system/service/impl/SysUserServiceImpl.java)
- [ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml](../ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml)
- [ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserMapper.java](../ruoyi-system/src/main/java/com/ruoyi/system/mapper/SysUserMapper.java)

后端职责：

- `SysProfileController` 负责接收头像、昵称、手机号、邮箱、生日、性别、备注等资料更新请求。
- `SysUserServiceImpl.updateUserProfile` 只允许写个人资料字段，不再调用通用用户更新逻辑。
- `SysUserMapper.updateUserProfile` 只更新资料页字段，避免把 `real_name_status` 等系统字段带回库里。
- `SysProfileController.syncLoginUserCache` 负责在更新完成后刷新登录态和用户缓存。

### 8.3 业务规则

- 头像已在资料提交时写入数据库，不再额外重复调用 `updateUserAvatar`。
- `realNameStatus` 只能由实名审核链路修改，个人资料编辑不得改动。
- 资料页修改成功后，前端应以本地缓存回填再异步刷新服务端，避免短暂回退。
- 多端登录场景下，任一端修改资料后都要重新拉取 `getInfo`。

### 8.4 构建与验证

后端编译校验：

```powershell
mvn -q -pl ruoyi-admin,ruoyi-system -am -DskipTests compile
```

建议验证点：

- 修改昵称后，返回页面和重新进入页面都应保持新值。
- 修改头像后，`sys_user.avatar` 和登录态缓存都应同步更新。
- 修改资料后，实名状态不应被改回旧值。
- 多设备登录时，另一台设备重新进入个人信息页应读到最新值。
