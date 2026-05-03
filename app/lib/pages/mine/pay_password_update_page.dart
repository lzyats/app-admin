import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/tools/auth_tool.dart';

class PayPasswordUpdatePage extends StatefulWidget {
  const PayPasswordUpdatePage({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  State<PayPasswordUpdatePage> createState() => _PayPasswordUpdatePageState();
}

class _PayPasswordUpdatePageState extends State<PayPasswordUpdatePage> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool submitting = false;
  bool _useSecurityQuestions = false;
  
  // 安全问题相关
  List<SecurityQuestion> _securityQuestions = [];
  final Map<int, TextEditingController> _answerControllers = {};
  bool _isLoadingQuestions = false;

  Future<void> _submit() async {
    final i18n = AppLocalizations.of(context);
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (!_useSecurityQuestions) {
      if (oldPassword.isEmpty) {
        _showError(i18n.t('payPasswordOldRequired'));
        return;
      }
      if (!_isNumeric(oldPassword)) {
        _showError(i18n.t('payPasswordMustBeNumber'));
        return;
      }
    } else {
      if (!_validateSecurityAnswers()) {
        _showError(i18n.t('securityQuestionAnswerRequired'));
        return;
      }
    }
    
    if (newPassword.length < 6) {
      _showError(i18n.t('payPasswordLengthError'));
      return;
    }
    if (!_isNumeric(newPassword)) {
      _showError(i18n.t('payPasswordMustBeNumber'));
      return;
    }
    if (newPassword != confirmPassword) {
      _showError(i18n.t('payPasswordConfirmError'));
      return;
    }

    setState(() {
      submitting = true;
    });

    try {
      if (_useSecurityQuestions) {
        // 通过安全问题验证修改支付密码
        final answers = _answerControllers.entries.map((entry) {
          return SecurityAnswerBody(
            questionId: entry.key,
            answer: entry.value.text.trim(),
          );
        }).toList();

        await AuthApi.updatePayPasswordWithSecurityQuestions(
          newPassword: newPassword,
          answers: answers,
        );
      } else {
        // 通过旧支付密码验证修改支付密码
        await AuthApi.updatePayPwd(widget.userId, oldPassword, newPassword);
      }
      // 更新本地缓存
      await AuthTool.setPayPasswordSet();
      if (mounted) {
        Navigator.of(context).pop(true);
        return;
      }
      _showSuccess(i18n.t('payPasswordUpdateSuccess'));
    } on ApiException catch (e) {
      _showError(e.userMessage.isEmpty ? i18n.t('payPasswordUpdateFailed') : e.userMessage);
    } catch (_) {
      _showError(i18n.t('payPasswordUpdateFailed'));
    } finally {
      setState(() {
        submitting = false;
      });
    }
  }

  Future<void> _loadSecurityQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
    });
    
    try {
      // 清空之前的控制器
      for (var controller in _answerControllers.values) {
        controller.dispose();
      }
      _answerControllers.clear();
      
      // 获取用户已设置的安全问题答案
      final myAnswers = await AuthApi.getMySecurityAnswers();
      
      if (myAnswers.isEmpty) {
        setState(() {
          _securityQuestions = [];
        });
        return;
      }
      
      // 提取用户已设置的安全问题ID
      final userQuestionIds = myAnswers.map((answer) => answer.questionId).toList();
      
      // 获取所有安全问题
      final i18n = AppLocalizations.of(context);
      final langCode = i18n.locale.toString();
      final allQuestions = await AuthApi.getSecurityQuestions(lang: langCode);
      
      // 过滤出用户已设置的安全问题
      final userQuestions = allQuestions.where((question) => userQuestionIds.contains(question.questionId)).toList();
      
      setState(() {
        _securityQuestions = userQuestions;
        for (var question in userQuestions) {
          _answerControllers[question.questionId] = TextEditingController();
        }
      });
    } catch (e) {
      String errorMessage = e.toString();
      if (e is ApiException) {
        errorMessage = e.userMessage;
      }
      _showError(errorMessage);
    } finally {
      setState(() {
        _isLoadingQuestions = false;
      });
    }
  }

  void _toggleVerificationMethod() {
    setState(() {
      _useSecurityQuestions = !_useSecurityQuestions;
      if (_useSecurityQuestions) {
        _loadSecurityQuestions();
      }
    });
  }

  bool _validateSecurityAnswers() {
    for (var controller in _answerControllers.values) {
      if (controller.text.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  bool _isNumeric(String str) {
    if (str.isEmpty) return false;
    return RegExp(r'^\d+$').hasMatch(str);
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
        title: Text(i18n.t('payPasswordUpdateTitle')),
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
                      // 验证方式切换
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _useSecurityQuestions
                                ? i18n.t('loginPasswordVerifyWithSecurityQuestions')
                                : i18n.t('loginPasswordVerifyWithOldPassword'),
                            style: const TextStyle(
                              color: Color(0xFFE9F3FF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: _toggleVerificationMethod,
                            child: Text(
                              _useSecurityQuestions
                                  ? i18n.t('loginPasswordUseOldPassword')
                                  : i18n.t('loginPasswordUseSecurityQuestions'),
                              style: const TextStyle(
                                color: Color(0xFF39E6FF),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 旧支付密码验证方式
                      if (!_useSecurityQuestions)
                        Column(
                          children: [
                            TextField(
                              controller: oldPasswordController,
                              decoration: InputDecoration(
                                labelText: i18n.t('payPasswordOld'),
                                labelStyle: const TextStyle(color: Color(0xFF9DB1C9)),
                                hintText: i18n.t('payPasswordOldHint'),
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
                          ],
                        ),

                      // 安全问题验证方式
                      if (_useSecurityQuestions)
                        Column(
                          children: [
                            if (_isLoadingQuestions)
                              const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF39E6FF),
                                ),
                              )
                            else if (_securityQuestions.isEmpty)
                              Center(
                                child: Text(
                                  i18n.t('securityQuestionNoQuestions'),
                                  style: const TextStyle(
                                    color: Color(0xFF9DB1C9),
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: _securityQuestions.map((question) {
                                  return Column(
                                    children: [
                                      Text(
                                        question.questionText,
                                        style: const TextStyle(
                                          color: Color(0xFFE9F3FF),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _answerControllers[question.questionId],
                                        decoration: InputDecoration(
                                          hintText: i18n.t('securityQuestionAnswerHint'),
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
                                        style: const TextStyle(color: Color(0xFFE9F3FF)),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                }).toList(),
                              ),
                          ],
                        ),

                      // 新支付密码输入
                      TextField(
                        controller: newPasswordController,
                        decoration: InputDecoration(
                          labelText: i18n.t('payPasswordNew'),
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
                                  i18n.t('payPasswordUpdateButton'),
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
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    for (var controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
