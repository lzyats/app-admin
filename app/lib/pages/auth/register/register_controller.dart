import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/auth_api.dart';

class RegisterController extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool loadingCaptcha = false;
  bool submitting = false;
  bool captchaEnabled = false;
  String captchaUuid = '';
  String captchaImageBase64 = '';

  /// 初始化注册页数据并拉取验证码。
  Future<void> init() async {
    await refreshCaptcha();
  }

  /// 拉取验证码。
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

  /// 执行注册。
  Future<String?> submit() async {
    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();
    final String code = codeController.text.trim();

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return 'authRequiredFields';
    }
    if (password != confirmPassword) {
      return 'authPasswordNotMatch';
    }
    if (code.isEmpty) {
      return 'authCaptchaRequired';
    }

    submitting = true;
    notifyListeners();
    try {
      await AuthApi.register(
        username: username,
        password: password,
        code: code,
        uuid: captchaUuid,
      );
      return null;
    } on ApiException catch (e) {
      await refreshCaptcha();
      return e.message.isEmpty ? 'authRegisterFailed' : e.message;
    } catch (_) {
      await refreshCaptcha();
      return 'authRegisterFailed';
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
    confirmPasswordController.dispose();
    codeController.dispose();
    super.dispose();
  }
}
