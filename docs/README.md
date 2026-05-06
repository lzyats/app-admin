# 文档总入口

> 这里是 `docs/` 目录的导航页，用来快速找到项目约定、模块索引、改动工作流和接口总览。

## 快速导航

| 文档 | 作用 |
|---|---|
| [project_context.md](project_context.md) | 项目全局上下文与硬规则 |
| [project_conventions.md](project_conventions.md) | 项目长期约定 |
| [workflow_map.md](workflow_map.md) | 改动工作流地图 |
| [investment_settlement_map.md](investment_settlement_map.md) | 产品投资与后台结算地图 |
| [module_registry.md](module_registry.md) | 模块级永久索引 |
| [module_registry_login_register.md](module_registry_login_register.md) | 登录注册专项约定 |
| [API_DOCUMENT.md](API_DOCUMENT.md) | 接口总览 |
| [asset_wallet_handoff_20260429.md](asset_wallet_handoff_20260429.md) | 资产页与换汇交接记录 |
| [module_registry.dart](module_registry.dart) | 模块索引数据结构定义 |

## 推荐阅读顺序

1. `project_context.md`
2. `project_conventions.md`
3. `workflow_map.md`
4. `investment_settlement_map.md`
5. `module_registry.md`
6. `API_DOCUMENT.md`

## 使用说明

- 任何涉及业务口径的改动，先看上下文和约定，再改代码。
- 任何涉及模块实现的改动，先看模块索引，再看接口说明。
- 任何涉及投资产品或结算的改动，优先看 `investment_settlement_map.md`。
