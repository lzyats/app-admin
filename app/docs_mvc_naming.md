# 目录命名规范

## 目录层级

```text
lib/
  config/
  event/
  pages/
  request/
  res/
  routers/
  tools/
  widgets/
```

## 命名规则

- 目录名：`lowercase_with_underscores`
- 文件名：`lowercase_with_underscores`
- 控制器文件：`*_controller.dart`
- 页面文件：`*_page.dart`
- 类名：`UpperCamelCase`
- 变量和方法：`lowerCamelCase`

## 约束

- 页面层不直接编写底层网络细节。
- 请求封装统一放在 `lib/request`。
- 公共样式和资源统一放在 `lib/res`。
- 公共组件统一放在 `lib/widgets`。