import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/auth_api.dart';

class ForgotController extends ChangeNotifier {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool loadingCaptcha = false;
  bool loadingSecurityQuestions = false;
  bool submitting = false;
  bool captchaEnabled = true;
  String captchaUuid = '';
  String captchaImageBase64 = '';
  List<SecurityQuestion> securityQuestions = [];
  int? selectedQuestionId1;
  int? selectedQuestionId2;
  final Map<int, TextEditingController> answerControllers = {};
  String? currentLanguage;

  void setLanguage(String language) {
    currentLanguage = language;
  }

  Future<void> init() async {
    await loadCaptcha();
    await loadSecurityQuestions();
  }

  Future<void> loadCaptcha() async {
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

  Future<void> refreshCaptcha() async {
    await loadCaptcha();
  }

  Future<void> loadSecurityQuestions() async {
    if (loadingSecurityQuestions) {
      return;
    }
    loadingSecurityQuestions = true;
    notifyListeners();
    try {
      securityQuestions = await AuthApi.getSecurityQuestions(lang: currentLanguage ?? 'zh');
    } catch (_) {
      securityQuestions = [];
    } finally {
      loadingSecurityQuestions = false;
      notifyListeners();
    }
  }

  void selectQuestion1(int? questionId) {
    if (selectedQuestionId1 != null && selectedQuestionId1 != questionId) {
      answerControllers[selectedQuestionId1!]?.dispose();
      answerControllers.remove(selectedQuestionId1!);
    }
    selectedQuestionId1 = questionId;
    if (questionId != null) {
      answerControllers[questionId] ??= TextEditingController();
    }
    notifyListeners();
  }

  void selectQuestion2(int? questionId) {
    if (selectedQuestionId2 != null && selectedQuestionId2 != questionId) {
      answerControllers[selectedQuestionId2!]?.dispose();
      answerControllers.remove(selectedQuestionId2!);
    }
    selectedQuestionId2 = questionId;
    if (questionId != null) {
      answerControllers[questionId] ??= TextEditingController();
    }
    notifyListeners();
  }

  List<SecurityQuestion> get availableQuestionsForDropdown1 {
    return securityQuestions;
  }

  List<SecurityQuestion> get availableQuestionsForDropdown2 {
    return securityQuestions.where((q) => q.questionId != selectedQuestionId1).toList();
  }

  bool validateSecurityAnswers() {
    if (selectedQuestionId1 != null) {
      final controller = answerControllers[selectedQuestionId1!];
      if (controller == null || controller.text.trim().isEmpty) {
        return false;
      }
    }
    if (selectedQuestionId2 != null) {
      final controller = answerControllers[selectedQuestionId2!];
      if (controller == null || controller.text.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  Future<String?> submit() async {
    final String username = usernameController.text.trim();
    final String newPassword = newPasswordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();
    final String code = codeController.text.trim();

    if (username.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      return 'authRequiredFields';
    }
    if (newPassword != confirmPassword) {
      return 'authPasswordNotMatch';
    }
    if (captchaEnabled && code.isEmpty) {
      return 'authCaptchaRequired';
    }
    if (selectedQuestionId1 == null || selectedQuestionId2 == null) {
      return 'authSelectTwoSecurityQuestions';
    }
    if (!validateSecurityAnswers()) {
      return 'authSecurityAnswersRequired';
    }

    submitting = true;
    notifyListeners();
    try {
      final answers = <SecurityAnswerBody>[
        SecurityAnswerBody(
          questionId: selectedQuestionId1!,
          answer: answerControllers[selectedQuestionId1!]!.text.trim(),
        ),
        SecurityAnswerBody(
          questionId: selectedQuestionId2!,
          answer: answerControllers[selectedQuestionId2!]!.text.trim(),
        ),
      ];

      await AuthApi.forgotPasswordBySecurity(
        username: username,
        newPassword: newPassword,
        answers: answers,
        code: code,
        uuid: captchaUuid,
      );
      return null;
    } on ApiException catch (e) {
      await loadCaptcha();
      return e.userMessage.isEmpty ? 'authForgotFailed' : e.userMessage;
    } catch (_) {
      await loadCaptcha();
      return 'authForgotFailed';
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    codeController.dispose();
    for (var controller in answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}