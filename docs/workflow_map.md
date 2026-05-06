# 改动工作流地图

> 这是一张给日常改动用的快速导航图。
> 目标很简单：先判断“改什么”，再决定“先看哪份文档”，最后确认“必须同步哪些位置”。

## 1. 使用方式

改动前先问自己一句：

- 这是改接口，还是改字段，还是改配置，还是改页面，还是改缓存？

然后按下面路线走。

## 2. 决策入口

| 你要改什么 | 先看什么 | 再看什么 | 必须同步什么 |
|---|---|---|---|
| 改业务规则或全局约束 | [project_context.md](project_context.md) | [project_conventions.md](project_conventions.md) | 相关代码、配置、缓存、文档 |
| 改具体模块 | [module_registry.md](module_registry.md) 对应模块 | [API_DOCUMENT.md](API_DOCUMENT.md) | 模块正文、接口、页面、缓存 |
| 改登录 / 注册 | [module_registry_login_register.md](module_registry_login_register.md) | [API_DOCUMENT.md](API_DOCUMENT.md) | `SysLoginController`、`SysRegisterController`、Flutter 登录注册链路 |
| 改接口路径或字段 | [API_DOCUMENT.md](API_DOCUMENT.md) | [module_registry.md](module_registry.md) | 后端 Controller / Service / Mapper / Flutter API |
| 改 `sys_user` 字段 | [project_context.md](project_context.md) | [module_registry_login_register.md](module_registry_login_register.md) | `getInfo`、Flutter 用户模型、相关页面与缓存 |
| 改 `app.*` 配置 | [project_context.md](project_context.md) | [API_DOCUMENT.md](API_DOCUMENT.md) | `AppConfigController`、`sys_config`、Flutter 配置模型、`ruoyi-ui` |
| 改缓存命中或失效 | [project_conventions.md](project_conventions.md) | 对应模块文档 | 写库顺序、缓存清理入口、多端一致性 |
| 改投资产品 / 结算 | [investment_settlement_map.md](investment_settlement_map.md) | [module_registry.md](module_registry.md) | 产品配置、APP 认购、Quartz 任务、后台结算、奖励发放 |
| 改 Flutter 页面 | [module_registry.md](module_registry.md) 对应模块 | [API_DOCUMENT.md](API_DOCUMENT.md) | 页面、API、模型、i18n、缓存 |

## 3. 常见改动路径

### 3.1 改用户字段
1. 先看 `docs/project_context.md` 里的用户缓存和 `getInfo` 规则。
2. 再看对应模块文档，确认这个字段属于哪条业务链路。
3. 同步后端实体、Mapper、`getInfo` 返回值。
4. 同步 Flutter 用户模型和页面展示。
5. 检查缓存是否需要失效。

### 3.2 改配置项
1. 先看 `docs/project_context.md` 里的“全局配置添加方法”。
2. 再看 `docs/API_DOCUMENT.md` 里的配置约定。
3. 同步后端 `AppConfigController`。
4. 同步 `sys_config`。
5. 同步 Flutter `AppBootstrapConfigData`。
6. 同步 `ruoyi-ui` 配置页。

### 3.3 改登录注册
1. 先看 `docs/module_registry_login_register.md`。
2. 再看 `docs/project_context.md` 里的登录会话规则。
3. 同步 `SysLoginController`、`SysRegisterController`、`UserDetailsServiceImpl`。
4. 同步 Flutter 登录 / 注册页和本地缓存。
5. 确认 APP 侧仍保持轻量链路。

### 3.4 改接口
1. 先看 `docs/API_DOCUMENT.md`。
2. 再看 `docs/module_registry.md` 对应模块。
3. 同步后端控制器、服务、Mapper。
4. 同步 Flutter 请求封装和页面调用。
5. 回写接口文档和模块文档。

### 3.5 改缓存
1. 先看 `docs/project_conventions.md` 里的缓存规则。
2. 确认是用户缓存、配置缓存，还是业务缓存。
3. 先保证写库成功，再做失效。
4. 检查是否存在多端读取或本地缓存兜底。

### 3.6 改投资或结算
1. 先看 `docs/investment_settlement_map.md`。
2. 先判断是产品配置、APP 认购，还是后台结算。
3. 同步检查 Quartz 任务、钱包余额、流水与奖励。
4. 如果改了后台状态流转，确认 APP 展示字段没有被带偏。

## 4. 最小检查清单

每次动手前，至少确认下面四件事：

1. 这次改动属于哪个模块。
2. 有没有接口、字段、配置、缓存或页面联动。
3. 有没有文档需要同步。
4. 有没有历史数据或旧逻辑需要兼容。

## 5. 文档关系

- [project_conventions.md](project_conventions.md) 负责全局守则。
- [project_context.md](project_context.md) 负责项目级上下文和硬规则。
- [workflow_map.md](workflow_map.md) 负责改动路径。
- [investment_settlement_map.md](investment_settlement_map.md) 负责投资与结算主线。
- [module_registry.md](module_registry.md) 负责模块级实现链路。
- [API_DOCUMENT.md](API_DOCUMENT.md) 负责接口总览。

## 6. 结论

如果你不确定从哪里看，优先顺序是：

1. `project_context.md`
2. `project_conventions.md`
3. `workflow_map.md`
4. `investment_settlement_map.md`
5. `module_registry.md`
6. `API_DOCUMENT.md`
