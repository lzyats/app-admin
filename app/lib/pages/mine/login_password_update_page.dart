import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/request/api_exception.dart';

class LoginPasswordUpdatePage extends StatefulWidget {
  const LoginPasswordUpdatePage({super.key});

  @override
  State<LoginPasswordUpdatePage> createState() => _LoginPasswordUpdatePageState();
}

class _LoginPasswordUpdatePageState extends State<LoginPasswordUpdatePage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _useSecurityQuestions = false;
  
  // 安全问题相关
  List<SecurityQuestion> _securityQuestions = [];
  final Map<int, TextEditingController> _answerControllers = {};
  bool _isLoadingQuestions = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).t('authRequestFailed')}: $e'),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_useSecurityQuestions && !_validateSecurityAnswers()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('securityQuestionAnswerRequired')),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_useSecurityQuestions) {
        // 通过安全问题验证修改密码
        final answers = _answerControllers.entries.map((entry) {
          return SecurityAnswerBody(
            questionId: entry.key,
            answer: entry.value.text.trim(),
          );
        }).toList();

        await AuthApi.updatePasswordWithSecurityQuestions(
          newPassword: _newPasswordController.text.trim(),
          answers: answers,
        );
      } else {
        // 通过旧密码验证修改密码
        await AuthApi.updatePassword(
          oldPassword: _oldPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).t('loginPasswordUpdateSuccess')),
            backgroundColor: const Color(0xFF38FFB3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e is ApiException) {
          errorMessage = e.userMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        title: Text(i18n.t('mineLoginPassword')),
        backgroundColor: const Color(0xCC101C30),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF0A1220), Color(0xFF0D1B2A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  // 旧密码验证方式
                  if (!_useSecurityQuestions)
                    Column(
                      children: [
                        TextFormField(
                          controller: _oldPasswordController,
                          decoration: InputDecoration(
                            labelText: i18n.t('loginPasswordOld'),
                            labelStyle: const TextStyle(color: Color(0xFF9DB1C9)),
                            filled: true,
                            fillColor: const Color(0xCC101C30),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0x334CE3FF),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0x334CE3FF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF39E6FF),
                              ),
                            ),
                          ),
                          style: const TextStyle(color: Color(0xFFE9F3FF)),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return i18n.t('loginPasswordOldRequired');
                            }
                            return null;
                          },
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
                                  TextFormField(
                                    controller: _answerControllers[question.questionId],
                                    decoration: InputDecoration(
                                      hintText: i18n.t('securityQuestionAnswerHint'),
                                      hintStyle: const TextStyle(color: Color(0xFF6B7A8A)),
                                      filled: true,
                                      fillColor: const Color(0xCC101C30),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0x334CE3FF),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0x334CE3FF),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF39E6FF),
                                        ),
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

                  // 新密码输入
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: i18n.t('loginPasswordNew'),
                      labelStyle: const TextStyle(color: Color(0xFF9DB1C9)),
                      filled: true,
                      fillColor: const Color(0xCC101C30),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0x334CE3FF),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0x334CE3FF),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF39E6FF),
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Color(0xFFE9F3FF)),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return i18n.t('loginPasswordNewRequired');
                      }
                      if (value.length < 5) {
                        return i18n.t('loginPasswordLengthError');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 确认新密码
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: i18n.t('loginPasswordConfirm'),
                      labelStyle: const TextStyle(color: Color(0xFF9DB1C9)),
                      filled: true,
                      fillColor: const Color(0xCC101C30),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0x334CE3FF),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0x334CE3FF),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF39E6FF),
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Color(0xFFE9F3FF)),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return i18n.t('loginPasswordConfirmRequired');
                      }
                      if (value != _newPasswordController.text) {
                        return i18n.t('loginPasswordConfirmError');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // 提交按钮
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF39E6FF),
                        foregroundColor: const Color(0xFF0A1220),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0A1220),
                                ),
                              ),
                            )
                          : Text(
                              i18n.t('loginPasswordUpdateButton'),
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
          ),
        ),
      ),
    );
  }
}
