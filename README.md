# 投资理财后台系统

> 这是项目自己的首页说明，不再沿用若依原始 README。

## 项目导航

- [docs/README.md](docs/README.md) - 文档总入口
- [docs/project_context.md](docs/project_context.md) - 项目全局上下文与硬规则
- [docs/project_conventions.md](docs/project_conventions.md) - 项目长期约定
- [docs/workflow_map.md](docs/workflow_map.md) - 改动工作流地图
- [docs/investment_settlement_map.md](docs/investment_settlement_map.md) - 产品投资与后台结算地图
- [docs/module_registry.md](docs/module_registry.md) - 模块级永久索引
- [docs/module_registry_login_register.md](docs/module_registry_login_register.md) - 登录注册专项约定
- [docs/API_DOCUMENT.md](docs/API_DOCUMENT.md) - 接口总览

## 5 行版总入口

1. 先看 `docs/project_context.md`，确认全局硬规则。
2. 再看 `docs/project_conventions.md`，确认改动守则。
3. 按场景看 `docs/workflow_map.md`，找到该先看哪份文档。
4. 投资产品和结算先看 `docs/investment_settlement_map.md`。
5. 具体模块看 `docs/module_registry.md`，接口路径和字段看 `docs/API_DOCUMENT.md`。

## 项目约定

- CNY 是唯一统计基准，双币种规则不能改。
- 改 `sys_user` 字段，必须同步 `getInfo` 和 Flutter 用户模型。
- 改 `app.*` 配置，必须同步后端、`sys_config`、Flutter、`ruoyi-ui`。
- 改接口，必须同步后端、前端、文档。
- 改缓存，必须写库成功后再清。
- APP 登录注册保持轻量，不引入后台完整权限树。
- 改资产、换汇、钱包，必须按文档的币种和汇率规则走。
- 改投资和结算，必须同步产品配置、Quartz 任务、钱包流水与奖励。
- SQL 必须可重复执行、兼容旧数据。
- 改动尽量最小，保持若依风格。

## 运行环境

- 数据库：MySQL 8.4.8
- 后端：Java / SpringBoot
- 管理端：Vue2 / ElementUI
- 移动端：Flutter

## 项目结构

- `ruoyi-admin` - 后端启动与控制器层
- `ruoyi-framework` - 安全、权限、基础框架
- `ruoyi-system` - 核心业务服务与数据访问
- `ruoyi-common` - 公共工具和通用能力
- `ruoyi-ui` - Vue 管理端
- `app` - Flutter 移动端
- `docs` - 永久文档与上下文说明
- `sql` - 数据库脚本与初始化文件

## 推荐阅读顺序

1. `docs/project_context.md`
2. `docs/project_conventions.md`
3. `docs/workflow_map.md`
4. `docs/investment_settlement_map.md`
5. `docs/module_registry.md`
6. `docs/API_DOCUMENT.md`

## 开工前提示

如果你要改代码，优先确认下面四件事：

1. 这次改动属于哪个模块。
2. 有没有接口、字段、配置、缓存或页面联动。
3. 有没有文档需要同步。
4. 有没有历史数据或旧逻辑需要兼容。
