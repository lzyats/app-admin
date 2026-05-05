# 投资理财后台系统

> 本仓库是一个基于 RuoYi-Vue 的投资理财后台系统，包含后端管理端与 Flutter 移动端。
>
> 这是项目自己的首页说明，不再沿用若依原始 README。

## 项目导航

- [docs/README.md](docs/README.md) - 文档总入口
- [docs/project_context.md](docs/project_context.md) - 项目全局上下文与硬规则
- [docs/project_conventions.md](docs/project_conventions.md) - 项目级长期约定
- [docs/workflow_map.md](docs/workflow_map.md) - 改动工作流地图
- [docs/module_registry.md](docs/module_registry.md) - 模块级永久索引
- [docs/module_registry_login_register.md](docs/module_registry_login_register.md) - 登录注册专项约定
- [docs/API_DOCUMENT.md](docs/API_DOCUMENT.md) - 接口总览

## 5 行版总入口

1. 先看 `docs/project_context.md`，确认全局硬规则。
2. 再看 `docs/project_conventions.md`，确认改动守则。
3. 按场景看 `docs/workflow_map.md`，找到该先看哪份文档。
4. 具体模块看 `docs/module_registry.md`，登录注册优先看专项文档。
5. 接口路径和字段看 `docs/API_DOCUMENT.md`，改完记得回写文档。

## 项目约定

- CNY 是唯一统计基准，双币种规则不能改。
- 改 `sys_user` 字段，必须同步 `getInfo` 和 Flutter 用户模型。
- 改 `app.*` 配置，必须同步后端、`sys_config`、Flutter、`ruoyi-ui`。
- 改接口，必须同步后端、前端、文档。
- 改缓存，必须写库成功后再清。
- APP 登录注册保持轻量，不引入后台完整权限树。
- 改资产、换汇、钱包，必须按文档的币种和汇率规则走。
- SQL 必须可重复执行、兼容旧数据。
- 改动尽量最小，保持若依风格。
- 先看模块文档，再动代码。

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
4. `docs/module_registry.md`
5. `docs/API_DOCUMENT.md`

## 开工前提示

如果你要改代码，优先确认下面四件事：

1. 这个改动属于哪个模块。
2. 有没有接口、字段、配置、缓存或页面联动。
3. 有没有文档需要同步。
4. 有没有历史数据或旧逻辑需要兼容。

## 说明

本项目的长期维护口径以 `docs/` 下文档为准。
如果代码和文档存在不一致，先以当前代码现状为准，再判断是否需要回写文档。
