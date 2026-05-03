import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/pages/auth/forgot/forgot_controller.dart';
import 'package:myapp/widgets/auth/auth_shell.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  late final ForgotController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ForgotController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final AppLocalizations i18n = AppLocalizations.of(context);
      String fullLanguageCode = i18n.locale.languageCode;
      if (i18n.locale.countryCode != null) {
        fullLanguageCode = '${i18n.locale.languageCode}-${i18n.locale.countryCode}';
      }
      _controller.setLanguage(fullLanguageCode);
      _controller.init();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return AuthShell(
          title: i18n.t('authForgotTitle'),
          subtitle: i18n.t('authForgotSubTitle'),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _authField(
                  controller: _controller.usernameController,
                  label: i18n.t('authUsername'),
                  hint: i18n.t('authUsernameHint'),
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),
                _buildSecurityQuestionsSection(i18n),
                const SizedBox(height: 16),
                _authField(
                  controller: _controller.newPasswordController,
                  label: i18n.t('authNewPassword'),
                  hint: i18n.t('authPasswordHint'),
                  icon: Icons.lock_reset_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                _authField(
                  controller: _controller.confirmPasswordController,
                  label: i18n.t('authConfirmPassword'),
                  hint: i18n.t('authConfirmPasswordHint'),
                  icon: Icons.verified_user_outlined,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
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
          ),
        );
      },
    );
  }

  Widget _buildSecurityQuestionsSection(AppLocalizations i18n) {
    if (_controller.loadingSecurityQuestions) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF13243E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x333CE3FF)),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF39E6FF),
          ),
        ),
      );
    }

    if (_controller.securityQuestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF13243E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x333CE3FF)),
        ),
        child: Center(
          child: Text(
            i18n.t('authNoSecurityQuestions'),
            style: const TextStyle(color: Color(0xFF9DB1C9)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          i18n.t('authSelectSecurityQuestions'),
          style: const TextStyle(
            color: Color(0xFFE6F2FF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          i18n.t('authSelectTwoQuestionsHint'),
          style: const TextStyle(
            color: Color(0xFF6B7A8A),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF13243E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x333CE3FF)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDropdown(
                label: i18n.t('authSecurityQuestion1'),
                value: _controller.selectedQuestionId1,
                items: _controller.availableQuestionsForDropdown1,
                onChanged: (value) => _controller.selectQuestion1(value),
                i18n: i18n,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: i18n.t('authSecurityQuestion2'),
                value: _controller.selectedQuestionId2,
                items: _controller.availableQuestionsForDropdown2,
                onChanged: (value) => _controller.selectQuestion2(value),
                i18n: i18n,
              ),
              if (_controller.selectedQuestionId1 != null) ...[
                const SizedBox(height: 16),
                _buildAnswerField(
                  i18n: i18n,
                  questionId: _controller.selectedQuestionId1!,
                  label: i18n.t('authSecurityAnswer1'),
                ),
              ],
              if (_controller.selectedQuestionId2 != null) ...[
                const SizedBox(height: 12),
                _buildAnswerField(
                  i18n: i18n,
                  questionId: _controller.selectedQuestionId2!,
                  label: i18n.t('authSecurityAnswer2'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required int? value,
    required List<dynamic> items,
    required ValueChanged<int?> onChanged,
    required AppLocalizations i18n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE6F2FF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF102033),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x334CE3FF)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  i18n.t('selectPlaceholder'),
                  style: const TextStyle(color: Color(0xFF6B7A8A)),
                ),
              ),
              items: items.map((item) {
                return DropdownMenuItem<int>(
                  value: item.questionId,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      item.questionText,
                      style: const TextStyle(color: Color(0xFFE6F2FF)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              isExpanded: true,
              dropdownColor: const Color(0xFF13243E),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF6B7A8A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerField({
    required AppLocalizations i18n,
    required int questionId,
    required String label,
  }) {
    final controller = _controller.answerControllers[questionId];
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE6F2FF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Color(0xFFE6F2FF)),
          decoration: InputDecoration(
            hintText: i18n.t('authSecurityAnswerHint'),
            hintStyle: const TextStyle(color: Color(0xFF6B7A8A)),
            filled: true,
            fillColor: const Color(0xFF102033),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x334CE3FF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x334CE3FF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF39E6FF), width: 1.4),
            ),
          ),
        ),
      ],
    );
  }

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
