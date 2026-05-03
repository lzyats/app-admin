import 'package:flutter/material.dart';
import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/tools/app_bootstrap_tool.dart';

class RegisterController extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController inviteCodeController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool loadingCaptcha = false;
  bool submitting = false;
  bool captchaEnabled = false;
  bool inviteCodeEnabled = false;
  String captchaUuid = '';
  String captchaImageBase64 = '';

  void _syncBootstrapConfig() {
    final bool remoteInviteCodeEnabled = AppBootstrapTool.config.inviteCodeEnabled;
    if (inviteCodeEnabled != remoteInviteCodeEnabled) {
      inviteCodeEnabled = remoteInviteCodeEnabled;
      notifyListeners();
    }
  }

  Future<void> init() async {
    AppBootstrapTool.configNotifier.addListener(_syncBootstrapConfig);
    inviteCodeEnabled = AppBootstrapTool.config.inviteCodeEnabled;
    await refreshCaptcha();
  }

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
      captchaEnabled = true;
      captchaUuid = '';
      captchaImageBase64 = '';
    } finally {
      loadingCaptcha = false;
      notifyListeners();
    }
  }

  Future<String?> submit() async {
    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();
    final String inviteCode = inviteCodeController.text.trim();
    final String code = codeController.text.trim();

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return 'authRequiredFields';
    }
    if (password != confirmPassword) {
      return 'authPasswordNotMatch';
    }
    if (inviteCodeEnabled && inviteCode.isEmpty) {
      return 'authInviteCodeRequired';
    }
    if (captchaEnabled && code.isEmpty) {
      return 'authCaptchaRequired';
    }

    submitting = true;
    notifyListeners();
    try {
      await AuthApi.registerWithParams(
        username: username,
        password: password,
        inviteCode: inviteCode,
        code: code,
        uuid: captchaUuid,
      );
      return null;
    } on ApiException catch (e) {
      await refreshCaptcha();
      return e.userMessage.isEmpty ? 'authRegisterFailed' : e.userMessage;
    } catch (_) {
      await refreshCaptcha();
      return 'authRegisterFailed';
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    AppBootstrapTool.configNotifier.removeListener(_syncBootstrapConfig);
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    inviteCodeController.dispose();
    codeController.dispose();
    super.dispose();
  }
}
