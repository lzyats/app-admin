import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/pages/auth/login/login_controller.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/widgets/auth/auth_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onLocaleChanged,
    required this.selectedLocale,
  });

  final ValueChanged<Locale?> onLocaleChanged;
  final Locale? selectedLocale;

  @override
  /// 创建登录页状态对象。
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller;

  @override
  /// 初始化控制器并拉取验证码。
  void initState() {
    super.initState();
    _controller = LoginController();
    _controller.init();
  }

  @override
  /// 销毁控制器资源。
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  /// 构建登录页面。
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return AuthShell(
          title: i18n.t('authLoginTitle'),
          subtitle: i18n.t('authLoginSubTitle'),
          topRight: TextButton.icon(
            onPressed: _openLanguagePicker,
            icon: const Icon(Icons.language_rounded, size: 16),
            label: Text(i18n.t('language')),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _authField(
                controller: _controller.usernameController,
                label: i18n.t('authUsername'),
                hint: i18n.t('authUsernameHint'),
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              _authField(
                controller: _controller.passwordController,
                label: i18n.t('authPassword'),
                hint: i18n.t('authPasswordHint'),
                icon: Icons.lock_outline_rounded,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _authField(
                      controller: _controller.codeController,
                      label: i18n.t('authCaptcha'),
                      hint: i18n.t('authCaptchaHint'),
                      icon: Icons.shield_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _CaptchaImage(
                    loading: _controller.loadingCaptcha,
                    imageBase64: _controller.captchaImageBase64,
                    onTap: _controller.refreshCaptcha,
                    title: i18n.t('authRefreshCaptcha'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _goLine,
                  icon: const Icon(Icons.route_rounded, size: 18),
                  label: Text(i18n.t('authChooseLine')),
                ),
              ),
              const SizedBox(height: 6),
              FilledButton(
                onPressed: _controller.submitting ? null : _onSubmit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  backgroundColor: const Color(0xFF2AD0FF),
                  foregroundColor: const Color(0xFF061420),
                ),
                child: Text(
                  _controller.submitting
                      ? i18n.t('authSubmitting')
                      : i18n.t('authLoginAction'),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: _goRegister,
                    child: Text(i18n.t('authGoRegister')),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _goForgot,
                    child: Text(i18n.t('authGoForgotPassword')),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建统一风格输入框。
  Widget _authField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFFE6F2FF)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: const Color(0xFF13243E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x333CE3FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x333CE3FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF39E6FF), width: 1.4),
        ),
      ),
    );
  }

  /// 处理登录按钮点击。
  Future<void> _onSubmit() async {
    final String? message = await _controller.submit();
    if (!mounted) {
      return;
    }
    if (message == null || message.isEmpty) {
      return;
    }
    final AppLocalizations i18n = AppLocalizations.of(context);
    final String text = message.contains('auth') ? i18n.t(message) : message;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// 跳转注册页。
  void _goRegister() {
    Navigator.of(context).pushNamed(AppRouter.register);
  }

  /// 跳转忘记密码页。
  void _goForgot() {
    Navigator.of(context).pushNamed(AppRouter.forgotPassword);
  }

  /// 跳转线路页。
  void _goLine() {
    Navigator.of(context).pushNamed(AppRouter.line);
  }

  /// 打开语言选择面板。
  void _openLanguagePicker() {
    final AppLocalizations i18n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0E1A2B),
      builder: (BuildContext context) {
        final Locale? locale = widget.selectedLocale;
        final String selectedValue = locale == null
            ? 'system'
            : locale.languageCode == 'zh'
                ? 'zh_CN'
                : 'en_US';
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(i18n.t('language')),
                subtitle: Text(i18n.t('followSystem')),
              ),
              RadioListTile<String>(
                value: 'system',
                groupValue: selectedValue,
                onChanged: (String? value) {
                  widget.onLocaleChanged(null);
                  Navigator.of(context).pop();
                },
                title: Text(i18n.t('followSystem')),
              ),
              RadioListTile<String>(
                value: 'zh_CN',
                groupValue: selectedValue,
                onChanged: (String? value) {
                  widget.onLocaleChanged(const Locale('zh', 'CN'));
                  Navigator.of(context).pop();
                },
                title: Text(i18n.t('zhCN')),
              ),
              RadioListTile<String>(
                value: 'en_US',
                groupValue: selectedValue,
                onChanged: (String? value) {
                  widget.onLocaleChanged(const Locale('en', 'US'));
                  Navigator.of(context).pop();
                },
                title: Text(i18n.t('enUS')),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CaptchaImage extends StatelessWidget {
  const _CaptchaImage({
    required this.loading,
    required this.imageBase64,
    required this.onTap,
    required this.title,
  });

  final bool loading;
  final String imageBase64;
  final Future<void> Function() onTap;
  final String title;

  @override
  /// 构建验证码图组件。
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (imageBase64.isNotEmpty) {
      try {
        imageBytes = base64Decode(imageBase64);
      } catch (_) {
        imageBytes = null;
      }
    }
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: loading ? null : () => onTap(),
      child: Container(
        width: 122,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF102033),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x334CE3FF)),
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : imageBytes == null
                ? Text(
                    title,
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      imageBytes,
                      gaplessPlayback: true,
                      fit: BoxFit.cover,
                      width: 114,
                      height: 46,
                    ),
                  ),
      ),
    );
  }
}
