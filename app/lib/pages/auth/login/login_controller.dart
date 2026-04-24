import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/tools/auth_tool.dart';

class LoginController extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool loadingCaptcha = false;
  bool submitting = false;
  bool captchaEnabled = false;
  String captchaUuid = '';
  String captchaImageBase64 = '';

  /// 初始化登录默认值并加载验证码。
  Future<void> init() async {
    if (usernameController.text.isEmpty) {
      usernameController.text = 'admin';
    }
    await refreshCaptcha();
  }

  /// 刷新验证码信息。
  Future<void> refreshCaptcha() async {
    if (loadingCaptcha) {
      return;
    }
    loadingCaptcha = true;
    notifyListeners();
    try {
      final CaptchaPayload payload = await AuthApi.captcha();
      captchaEnabled = payload.captchaEnabled;
      captchaUuid = payload.uuid;
      captchaImageBase64 = payload.imageBase64;
      if (!captchaEnabled) {
        codeController.clear();
      }
    } catch (_) {
      captchaEnabled = false;
      captchaUuid = '';
      captchaImageBase64 = '';
    } finally {
      loadingCaptcha = false;
      notifyListeners();
    }
  }

  /// 执行登录请求，成功后写入 token。
  Future<String?> submit() async {
    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();
    final String code = codeController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      return 'authRequiredFields';
    }
    if (code.isEmpty) {
      return 'authCaptchaRequired';
    }

    submitting = true;
    notifyListeners();
    try {
      final String token = await AuthApi.login(
        username: username,
        password: password,
        code: code,
        uuid: captchaUuid,
      );
      await AuthTool.login(token);
      return null;
    } on ApiException catch (e) {
      await refreshCaptcha();
      return e.message.isEmpty ? 'authLoginFailed' : e.message;
    } catch (_) {
      await refreshCaptcha();
      return 'authLoginFailed';
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  @override
  /// 释放控制器资源。
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    codeController.dispose();
    super.dispose();
  }
}
