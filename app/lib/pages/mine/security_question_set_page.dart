import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/tools/auth_tool.dart';

class SecurityQuestionSetPage extends StatefulWidget {
  const SecurityQuestionSetPage({super.key});

  @override
  State<SecurityQuestionSetPage> createState() =>
      _SecurityQuestionSetPageState();
}

class _SecurityQuestionSetPageState extends State<SecurityQuestionSetPage> {
  List<SecurityQuestion> _allQuestions = [];
  List<SecurityAnswerBody> _selectedAnswers = [];
  final Map<int, TextEditingController> _answerControllers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 延迟加载数据，确保BuildContext完全初始化
    Future.microtask(() {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 获取当前语言代码
      final i18n = AppLocalizations.of(context);
      final langCode = i18n.locale.toString();

      if (!mounted) {
        return;
      }
      final questions = await AuthApi.getSecurityQuestions(lang: langCode);
      final myAnswers = await AuthApi.getMySecurityAnswers();

      if (!mounted) {
        return;
      }
      setState(() {
        _allQuestions = questions;
        _isLoading = false;
      });

      if (myAnswers.isNotEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _selectedAnswers = myAnswers
              .map((e) =>
                  SecurityAnswerBody(questionId: e.questionId, answer: ''))
              .toList();
          for (var answer in _selectedAnswers) {
            _answerControllers[answer.questionId] = TextEditingController();
          }
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleQuestionSelection(SecurityQuestion question) {
    setState(() {
      final existingIndex = _selectedAnswers
          .indexWhere((a) => a.questionId == question.questionId);
      if (existingIndex >= 0) {
        _selectedAnswers.removeAt(existingIndex);
        _answerControllers[question.questionId]?.dispose();
        _answerControllers.remove(question.questionId);
      } else {
        if (_selectedAnswers.length >= 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context).t('securityQuestionMaxTip')),
              backgroundColor: const Color(0xFFFFA500),
            ),
          );
          return;
        }
        _selectedAnswers.add(
            SecurityAnswerBody(questionId: question.questionId, answer: ''));
        _answerControllers[question.questionId] = TextEditingController();
      }
    });
  }

  void _updateAnswer(int questionId, String answer) {
    setState(() {
      final index =
          _selectedAnswers.indexWhere((a) => a.questionId == questionId);
      if (index >= 0) {
        _selectedAnswers[index] =
            SecurityAnswerBody(questionId: questionId, answer: answer);
      }
    });
  }

  bool _isQuestionSelected(int questionId) {
    return _selectedAnswers.any((a) => a.questionId == questionId);
  }

  Future<void> _submit() async {
    if (_selectedAnswers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).t('securityQuestionSelectTwo')),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
      return;
    }

    for (var answer in _selectedAnswers) {
      if (answer.answer.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .t('securityQuestionAnswerRequired')),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthApi.setSecurityAnswers(_selectedAnswers);
      await AuthTool.updateSecurityQuestionSet(1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context).t('securityQuestionSetSuccess')),
            backgroundColor: const Color(0xFF38FFB3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
    // 调试信息
    debugPrint('Current locale: ${i18n.locale}');
    debugPrint(
        'securityQuestionSaveButton translation: ${i18n.t('securityQuestionSaveButton')}');

    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        title: Text(i18n.t('mineSecurityQuestion')),
        backgroundColor: const Color(0xCC101C30),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF39E6FF)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        i18n.t('mineProfileLoadFailed'),
                        style: const TextStyle(color: Color(0xFFFF6B6B)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text(i18n.t('mineRetryLoad')),
                      ),
                    ],
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0xFF0A1220), Color(0xFF0D1B2A)],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i18n.t('securityQuestionSelectTip'),
                                style: const TextStyle(
                                  color: Color(0xFF9DB1C9),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                i18n.t('securityQuestionSelectTip2'),
                                style: const TextStyle(
                                  color: Color(0xFFFFA500),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _allQuestions.length,
                            itemBuilder: (context, index) {
                              final question = _allQuestions[index];
                              final isSelected =
                                  _isQuestionSelected(question.questionId);
                              final controller =
                                  _answerControllers[question.questionId];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xCC101C30),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF39E6FF)
                                        : const Color(0x334CE3FF),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          _toggleQuestionSelection(question),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? const Color(0xFF39E6FF)
                                                    : Colors.transparent,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(0xFF39E6FF)
                                                      : const Color(0xFF9DB1C9),
                                                  width: 2,
                                                ),
                                              ),
                                              child: isSelected
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 16,
                                                      color: Color(0xFF0A1220),
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                question.questionText,
                                                style: const TextStyle(
                                                  color: Color(0xFFE9F3FF),
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (isSelected && controller != null)
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 0, 16, 16),
                                        child: TextField(
                                          controller: controller,
                                          onChanged: (value) => _updateAnswer(
                                            question.questionId,
                                            value,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: i18n.t(
                                                'securityQuestionAnswerHint'),
                                            hintStyle: const TextStyle(
                                              color: Color(0xFF6B7A8A),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFF0A1220),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0x334CE3FF),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0x334CE3FF),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF39E6FF),
                                              ),
                                            ),
                                          ),
                                          style: const TextStyle(
                                              color: Color(0xFFE9F3FF)),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Color(0xFF0A1220),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      i18n.t('securityQuestionSaveButton'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
