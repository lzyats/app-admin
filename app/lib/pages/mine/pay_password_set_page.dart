import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/routers/app_router.dart';
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
  final TextEditingController payPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final Map<int, TextEditingController> _answerControllers = {};
  List<SecurityQuestion> _securityQuestions = <SecurityQuestion>[];
  bool _loadingQuestions = false;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _loadSecurityQuestions();
  }

  Future<void> _loadSecurityQuestions() async {
    if (!mounted) {
      return;
    }
    try {
      setState(() {
        _loadingQuestions = true;
      });
      final myAnswers = await AuthApi.getMySecurityAnswers();
      if (myAnswers.isEmpty) {
        setState(() {
          _securityQuestions = <SecurityQuestion>[];
        });
        return;
      }
      final i18n = AppLocalizations.of(context);
      final allQuestions = await AuthApi.getSecurityQuestions(lang: i18n.locale.toString());
      final userQuestionIds = myAnswers.map((e) => e.questionId).toSet();
      final userQuestions = allQuestions.where((q) => userQuestionIds.contains(q.questionId)).toList();
      setState(() {
        _securityQuestions = userQuestions;
        for (final controller in _answerControllers.values) {
          controller.dispose();
        }
        _answerControllers.clear();
        for (final q in userQuestions) {
          _answerControllers[q.questionId] = TextEditingController();
        }
      });
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _loadingQuestions = false;
        });
      }
    }
  }

  bool _isNumeric(String str) {
    if (str.isEmpty) return false;
    return RegExp(r'^\d+$').hasMatch(str);
  }

  Future<void> _submit() async {
    final i18n = AppLocalizations.of(context);
    final payPassword = payPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    if (_securityQuestions.isEmpty) {
      _showError(i18n.t('securityQuestionNoQuestions'));
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
    final answers = <SecurityAnswerBody>[];
    for (final question in _securityQuestions) {
      final value = _answerControllers[question.questionId]?.text.trim() ?? '';
      if (value.isEmpty) {
        _showError(i18n.t('securityQuestionAnswerRequired'));
        return;
      }
      answers.add(SecurityAnswerBody(questionId: question.questionId, answer: value));
    }

    setState(() {
      submitting = true;
    });

    try {
      await AuthApi.setPayPasswordWithSecurityQuestions(
        newPassword: payPassword,
        answers: answers,
      );
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
                      if (_loadingQuestions)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: CircularProgressIndicator(color: Color(0xFF39E6FF)),
                        ),
                      if (!_loadingQuestions && _securityQuestions.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0x1AFFFFFF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0x334CE3FF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                i18n.t('securityQuestionNoQuestions'),
                                style: const TextStyle(color: Color(0xFFE9F3FF), fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () async {
                                  await Navigator.pushNamed(context, AppRouter.securityQuestionSet);
                                  if (mounted) {
                                    _loadSecurityQuestions();
                                  }
                                },
                                child: Text(i18n.t('mineSecurityQuestion')),
                              ),
                            ],
                          ),
                        ),
                      if (_securityQuestions.isNotEmpty)
                        Column(
                          children: _securityQuestions.map((question) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextField(
                                controller: _answerControllers[question.questionId],
                                decoration: InputDecoration(
                                  labelText: question.questionText,
                                  labelStyle: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
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
                            );
                          }).toList(),
                        ),
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
    payPasswordController.dispose();
    confirmPasswordController.dispose();
    for (final controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
