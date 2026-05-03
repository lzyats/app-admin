import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/auth_api.dart';

class LoginController extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool loadingCaptcha = false;
  bool submitting = false;
  bool captchaEnabled = true;
  String captchaUuid = '';
  String captchaImageBase64 = '';

  bool _disposed = false;

  bool get _canNotify => !_disposed;

  void _safeNotify() {
    if (_canNotify) {
      notifyListeners();
    }
  }

  Future<void> init() async {
    if (_disposed) {
      return;
    }
    await refreshCaptcha();
  }

  Future<void> refreshCaptcha() async {
    if (_disposed || loadingCaptcha) {
      return;
    }

    loadingCaptcha = true;
    captchaUuid = '';
    captchaImageBase64 = '';
    codeController.clear();
    _safeNotify();

    try {
      final CaptchaPayload payload = await AuthApi.captcha();
      if (_disposed) {
        return;
      }
      captchaEnabled = payload.captchaEnabled;
      captchaUuid = payload.uuid;
      captchaImageBase64 = payload.imageBase64;
      if (!captchaEnabled) {
        codeController.clear();
      }
    } catch (_) {
      captchaEnabled = true;
      captchaUuid = '';
      captchaImageBase64 = '';
      codeController.clear();
    } finally {
      loadingCaptcha = false;
      _safeNotify();
    }
  }

  Future<String?> submit() async {
    if (_disposed) {
      return 'authLoginFailed';
    }

    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();
    final String code = codeController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      return 'authRequiredFields';
    }
    if (captchaEnabled && loadingCaptcha) {
      return 'authCaptchaRequired';
    }
    if (captchaEnabled && captchaUuid.isEmpty) {
      await refreshCaptcha();
      return 'authCaptchaRequired';
    }
    if (captchaEnabled && code.isEmpty) {
      return 'authCaptchaRequired';
    }

    if (kDebugMode) {
      debugPrint(
        'LoginController.submit captchaEnabled=$captchaEnabled '
        'loadingCaptcha=$loadingCaptcha captchaUuid=$captchaUuid codeLen=${code.length}',
      );
    }

    submitting = true;
    _safeNotify();

    try {
      await AuthApi.loginWithParams(
        username: username,
        password: password,
        code: code,
        uuid: captchaUuid,
      );
      if (_disposed) {
        return null;
      }
      return null;
    } on ApiException catch (e) {
      if (!_disposed) {
        await refreshCaptcha();
      }
      return e.userMessage.isEmpty ? 'authLoginFailed' : e.userMessage;
    } catch (_) {
      if (!_disposed) {
        await refreshCaptcha();
      }
      return 'authLoginFailed';
    } finally {
      submitting = false;
      _safeNotify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    usernameController.dispose();
    passwordController.dispose();
    codeController.dispose();
    super.dispose();
  }
}
