import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/pages/auth/forgot/forgot_controller.dart';
import 'package:myapp/widgets/auth/auth_shell.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  /// 创建忘记密码页状态对象。
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  late final ForgotController _controller;

  @override
  /// 初始化页面并加载验证码。
  void initState() {
    super.initState();
    _controller = ForgotController();
    _controller.init();
  }

  @override
  /// 销毁控制器。
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  /// 构建忘记密码页面。
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return AuthShell(
          title: i18n.t('authForgotTitle'),
          subtitle: i18n.t('authForgotSubTitle'),
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
                controller: _controller.emailController,
                label: i18n.t('authEmail'),
                hint: i18n.t('authEmailHint'),
                icon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: 12),
              _authField(
                controller: _controller.newPasswordController,
                label: i18n.t('authNewPassword'),
                hint: i18n.t('authPasswordHint'),
                icon: Icons.lock_reset_rounded,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              _authField(
                controller: _controller.confirmPasswordController,
                label: i18n.t('authConfirmPassword'),
                hint: i18n.t('authConfirmPasswordHint'),
                icon: Icons.verified_user_outlined,
                obscureText: true,
              ),
              if (_controller.captchaEnabled) ...<Widget>[
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
              ],
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _controller.submitting ? null : _onSubmit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  backgroundColor: const Color(0xFFE2FF59),
                  foregroundColor: const Color(0xFF1E1A04),
                ),
                child: Text(
                  _controller.submitting
                      ? i18n.t('authSubmitting')
                      : i18n.t('authForgotAction'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(i18n.t('authBackToLogin')),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建统一认证输入框。
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

  /// 提交忘记密码表单。
  Future<void> _onSubmit() async {
    final String? message = await _controller.submit();
    if (!mounted) {
      return;
    }
    final AppLocalizations i18n = AppLocalizations.of(context);
    if (message == null || message.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(i18n.t('authForgotSuccess'))));
      Navigator.of(context).pop();
      return;
    }
    final String text = message.contains('auth') ? i18n.t(message) : message;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
