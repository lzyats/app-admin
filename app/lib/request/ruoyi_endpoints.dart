class RuoYiEndpoints {
  const RuoYiEndpoints._();

  // 认证与用户信息
  static const String login = '/login';
  static const String register = '/register';
  static const String captchaImage = '/captchaImage';
  static const String forgotPassword = '/app/auth/forgotPwd';
  static const String logout = '/logout';
  static const String getInfo = '/getInfo';
  static const String getRouters = '/getRouters';

  // 字典
  static const String dictType = '/system/dict/data/type/';

  // 文件上传
  static const String upload = '/common/upload';

  // APP 升级配置
  static const String upgradeConfig = '/app/upgrade/config';
}
