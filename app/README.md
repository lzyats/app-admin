# 项目说明

本项目使用 Flutter 实现客户端，支持安卓、苹果和网页。

## 目录规范

- `lib/config`：基础配置
- `lib/event`：事件总线
- `lib/pages`：页面目录（按模块拆分）
- `lib/request`：接口请求基座
- `lib/res`：样式与资源
- `lib/routers`：路由
- `lib/tools`：工具类
- `lib/widgets`：公共控件

## 页面文件约定

页面按模块拆分，通常包含：

- `xxx_controller.dart`
- `xxx_page.dart`

`lib/pages/main` 目录用于主流程控制：

- `main_controller.dart`
- `main_middle.dart`
- `main_page.dart`

其中 `main_middle.dart` 作为登录中间组件。

## 运行命令

```bash
flutter pub get
flutter run -d android
flutter run -d ios
flutter run -d chrome
```