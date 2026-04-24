import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/auth_api.dart';

class ForgotController extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool loadingCaptcha = false;
  bool submitting = false;
  bool captchaEnabled = false;
  String captchaUuid = '';
  String captchaImageBase64 = '';

  /// 初始化忘记密码页面并加载验证码。
  Future<void> init() async {
    await refreshCaptcha();
  }

  /// 刷新验证码。
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

  /// 提交忘记密码请求。
  Future<String?> submit() async {
    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String newPassword = newPasswordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();
    final String code = codeController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      return 'authRequiredFields';
    }
    if (newPassword != confirmPassword) {
      return 'authPasswordNotMatch';
    }
    if (captchaEnabled && code.isEmpty) {
      return 'authCaptchaRequired';
    }

    submitting = true;
    notifyListeners();
    try {
      await AuthApi.forgotPassword(
        username: username,
        email: email,
        newPassword: newPassword,
        code: code,
        uuid: captchaUuid,
      );
      return null;
    } on ApiException catch (e) {
      await refreshCaptcha();
      return e.message.isEmpty ? 'authForgotFailed' : e.message;
    } catch (_) {
      await refreshCaptcha();
      return 'authForgotFailed';
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  @override
  /// 释放控制器资源。
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    codeController.dispose();
    super.dispose();
  }
}

