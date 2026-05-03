import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/tools/auth_tool.dart';

class PayPasswordSetPage extends StatefulWidget {
  const PayPasswordSetPage({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  State<PayPasswordSetPage> createState() => _PayPasswordSetPageState();
}

class _PayPasswordSetPageState extends State<PayPasswordSetPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController payPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool loading = false;
  bool submitting = false;
  bool captchaEnabled = false;
  String captchaUuid = '';
  String captchaImageBase64 = '';
  String initialEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await AuthApi.getInfo();
      if (userInfo.email != null && userInfo.email!.isNotEmpty) {
        initialEmail = userInfo.email!;
        emailController.text = userInfo.email!;
      }
    } catch (_) {
      // 忽略错误，使用空邮箱
    }
  }

  Future<void> _refreshCaptcha() async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      final payload = await AuthApi.captcha();
      setState(() {
        captchaEnabled = payload.captchaEnabled;
        captchaUuid = payload.uuid;
        captchaImageBase64 = payload.imageBase64;
      });
    } catch (_) {
      setState(() {
        captchaEnabled = false;
        captchaUuid = '';
        captchaImageBase64 = '';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  bool _isNumeric(String str) {
    if (str.isEmpty) return false;
    return RegExp(r'^\d+$').hasMatch(str);
  }

  Future<void> _submit() async {
    final i18n = AppLocalizations.of(context);
    final email = emailController.text.trim();
    final payPassword = payPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final code = codeController.text.trim();

    if (email.isEmpty) {
      _showError(i18n.t('payPasswordEmailRequired'));
      return;
    }
    if (!email.contains('@')) {
      _showError(i18n.t('payPasswordEmailInvalid'));
      return;
    }
    if (payPassword.isEmpty) {
      _showError(i18n.t('payPasswordRequired'));
      return;
    }
    if (!_isNumeric(payPassword)) {
      _showError(i18n.t('payPasswordMustBeNumber'));
      return;
    }
    if (payPassword.length < 6) {
      _showError(i18n.t('payPasswordLengthError'));
      return;
    }
    if (payPassword != confirmPassword) {
      _showError(i18n.t('payPasswordConfirmError'));
      return;
    }
    if (captchaEnabled && code.isEmpty) {
      _showError(i18n.t('authCaptchaRequired'));
      return;
    }

    setState(() {
      submitting = true;
    });

    try {
      // 如果邮箱与初始值不同，先更新邮箱信息
      if (email != initialEmail) {
        await AuthApi.updateProfile(email: email);
      }
      // 设置支付密码
      await AuthApi.setPayPwd(widget.userId, payPassword);
      // 更新本地缓存
      await AuthTool.setPayPasswordSet();
      if (mounted) {
        Navigator.of(context).pop(true);
        return;
      }
      _showSuccess(i18n.t('payPasswordSetSuccess'));
    } on ApiException catch (e) {
      _showError(e.userMessage.isEmpty ? i18n.t('payPasswordSetFailed') : e.userMessage);
    } catch (_) {
      _showError(i18n.t('payPasswordSetFailed'));
    } finally {
      setState(() {
        submitting = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF38FFB3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.t('payPasswordSetTitle')),
        backgroundColor: const Color(0xCC101C30),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF0A1220), Color(0xFF0D1B2A), Color(0xFF14233A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xCC101C30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x334CE3FF)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 28,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: i18n.t('payPasswordEmail'),
                          labelStyle: const TextStyle(color: Color(0xFF9DB1C9)),
                          hintText: i18n.t('payPasswordEmailHint'),
                          hintStyle: const TextStyle(color: Color(0xFF6B7A8A)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0x334CE3FF)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF39E6FF)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Color(0xFFE9F3FF)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: payPasswordController,
                        decoration: InputDecoration(
                          labelText: i18n.t('payPassword'),
                          labelStyle: const TextStyle(color: Color(0xFF9DB1C9)),
                          hintText: i18n.t('payPasswordHint'),
                          hintStyle: const TextStyle(color: Color(0xFF6B7A8A)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0x334CE3FF)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF39E6FF)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(color: Color(0xFFE9F3FF)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: i18n.t('payPasswordConfirm'),
                          labelStyle: const TextStyle(color: Color(0xFF9DB1C9)),
                          hintText: i18n.t('payPasswordConfirmHint'),
                          hintStyle: const TextStyle(color: Color(0xFF6B7A8A)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0x334CE3FF)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF39E6FF)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(color: Color(0xFFE9F3FF)),
                      ),
                      if (captchaEnabled)
                        Column(
                          children: <Widget>[
                            const SizedBox(height: 16),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    controller: codeController,
                                    decoration: InputDecoration(
                                      labelText: i18n.t('authCaptcha'),
                                      labelStyle: const TextStyle(color: Color(0xFF9DB1C9)),
                                      hintText: i18n.t('authCaptchaHint'),
                                      hintStyle: const TextStyle(color: Color(0xFF6B7A8A)),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Color(0x334CE3FF)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Color(0xFF39E6FF)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Color(0xFFE9F3FF)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: _refreshCaptcha,
                                  child: Container(
                                    width: 100,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0x334CE3FF)),
                                    ),
                                    child: loading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF39E6FF)),
                                              ),
                                            ),
                                          )
                                        : captchaImageBase64.isNotEmpty
                                            ? Image.memory(
                                                base64Decode(captchaImageBase64),
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 48,
                                              )
                                            : Center(
                                                child: Text(
                                                  i18n.t('authRefreshCaptcha'),
                                                  style: const TextStyle(color: Color(0xFF39E6FF)),
                                                ),
                                              ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: submitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF39E6FF),
                            foregroundColor: const Color(0xFF0A1220),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A1220)),
                                  ),
                                )
                              : Text(
                                  i18n.t('payPasswordSetButton'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    payPasswordController.dispose();
    confirmPasswordController.dispose();
    codeController.dispose();
    super.dispose();
  }
}
