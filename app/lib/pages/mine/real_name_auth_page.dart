import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/pages/mine/real_name_auth_controller.dart';
import 'package:myapp/res/app_colors.dart';
import 'package:myapp/widgets/app_network_image.dart';

class RealNameAuthPage extends StatefulWidget {
  const RealNameAuthPage({super.key});

  @override
  State<RealNameAuthPage> createState() => _RealNameAuthPageState();
}

class _RealNameAuthPageState extends State<RealNameAuthPage> {
  late RealNameAuthController _controller;
  final _formKey = GlobalKey<FormState>();
  final _realNameController = TextEditingController();
  final _idCardController = TextEditingController();
  String? _idCardFrontError;
  String? _idCardBackError;
  String? _handheldPhotoError;

  @override
  void initState() {
    super.initState();
    _controller = RealNameAuthController();
    _controller.loadStatus();
  }

  @override
  void dispose() {
    _realNameController.dispose();
    _idCardController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildImageUploader({
    required String label,
    required String? imageUrl,
    Uint8List? imageBytes,
    required VoidCallback onTap,
    String? errorText,
    double aspectRatio = 1.0,
    Widget? placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x401A2A40),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: errorText != null
                      ? const Color(0xFFFF6B6B)
                      : const Color(0x334CE3FF),
                  width: errorText != null ? 1.2 : 1,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: imageBytes != null && imageBytes.isNotEmpty
                          ? Image.memory(
                              imageBytes,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            )
                          : imageUrl != null && imageUrl.isNotEmpty
                              ? AppNetworkImage(
                                  src: imageUrl,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  errorBuilder: (_, __, ___) =>
                                      placeholder ?? _buildPlaceholder(label),
                                )
                              : placeholder ?? _buildPlaceholder(label),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xCC101C30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x334CE3FF)),
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.add_photo_alternate_outlined,
          color: AppColors.primary,
          size: 40,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCardPlaceholder(String title, String hint) {
    return Container(
      color: AppColors.primary.withOpacity(0.05),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.credit_card_outlined,
              color: AppColors.primary,
              size: 38,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hint,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;

    switch (_controller.status) {
      case 1:
        color = const Color(0xFFFFA500);
        text = AppLocalizations.of(context).t('realNameStatusPending');
        icon = Icons.access_time;
        break;
      case 3:
        color = const Color(0xFF38FFB3);
        text = AppLocalizations.of(context).t('realNameStatusApproved');
        icon = Icons.check_circle;
        break;
      case 2:
        color = const Color(0xFFFF6B6B);
        text = AppLocalizations.of(context).t('realNameStatusRejected');
        icon = Icons.cancel;
        break;
      default:
        color = const Color(0xFF888888);
        text = AppLocalizations.of(context).t('realNameStatusNotSubmitted');
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    _controller.realName = _realNameController.text.trim();
    _controller.idCardNumber = _idCardController.text.trim();

    if (_formKey.currentState?.validate() != true) return;

    final String? imageError = _validateImageSelections();
    if (imageError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(imageError),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
      return;
    }

    final success = await _controller.submit();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).t('realNameSubmitSuccess')),
          backgroundColor: const Color(0xFF38FFB3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('realNameSubmitFailed')),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    }
  }

  String? _validateImageSelections() {
    final bool missingFront =
        (_controller.idCardFront == null || _controller.idCardFront!.isEmpty) &&
            _controller.idCardFrontImage == null;
    final bool missingBack =
        (_controller.idCardBack == null || _controller.idCardBack!.isEmpty) &&
            _controller.idCardBackImage == null;
    final bool missingHandheld = _controller.handheldRequired &&
        (_controller.handheldPhoto == null ||
            _controller.handheldPhoto!.isEmpty) &&
        _controller.handheldPhotoImage == null;

    setState(() {
      _idCardFrontError = missingFront
          ? AppLocalizations.of(context).t('realNameIdCardFrontRequired')
          : null;
      _idCardBackError = missingBack
          ? AppLocalizations.of(context).t('realNameIdCardBackRequired')
          : null;
      _handheldPhotoError = missingHandheld
          ? AppLocalizations.of(context).t('realNameHandheldRequired')
          : null;
    });

    if (missingFront) {
      return AppLocalizations.of(context).t('realNameIdCardFrontRequired');
    }
    if (missingBack) {
      return AppLocalizations.of(context).t('realNameIdCardBackRequired');
    }
    if (missingHandheld) {
      return AppLocalizations.of(context).t('realNameHandheldRequired');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1220),
        appBar: AppBar(
          title: Text(i18n.t('mineRealNameAuth')),
          backgroundColor: const Color(0xFF0A1220),
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF0A1220),
                Color(0xFF0D1B2A),
              ],
            ),
          ),
          child: SafeArea(
            child: Consumer<RealNameAuthController>(
              builder: (context, controller, _) {
                if (controller.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (controller.status == 1) {
                  return _buildSubmittedView(i18n, controller);
                }

                if (controller.status == 3) {
                  return _buildApprovedView(i18n, controller);
                }

                return _buildFormView(i18n, controller);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmittedView(
      AppLocalizations i18n, RealNameAuthController controller) {
    return _buildStatusSummaryPage(
      i18n: i18n,
      controller: controller,
      title: i18n.t('realNameReviewingTitle'),
      description: i18n.t('realNameReviewingDesc'),
      statusColor: const Color(0xFFFFA500),
      statusIcon: Icons.access_time_rounded,
    );
  }

  Widget _buildApprovedView(
      AppLocalizations i18n, RealNameAuthController controller) {
    return _buildStatusSummaryPage(
      i18n: i18n,
      controller: controller,
      title: i18n.t('realNameStatusApproved'),
      description: i18n.t('realNameApprovedDesc'),
      statusColor: const Color(0xFF38FFB3),
      statusIcon: Icons.verified_rounded,
    );
  }

  Widget _buildStatusSummaryPage({
    required AppLocalizations i18n,
    required RealNameAuthController controller,
    required String title,
    required String description,
    required Color statusColor,
    required IconData statusIcon,
  }) {
    final Map<String, dynamic>? latest = controller.latestAuth;
    final String displayName =
        (latest?['realName']?.toString().isNotEmpty ?? false)
            ? latest!['realName'].toString()
            : controller.realName;
    final String displayIdCard =
        (latest?['idCardNumber']?.toString().isNotEmpty ?? false)
            ? latest!['idCardNumber'].toString()
            : controller.idCardNumber;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: statusColor.withOpacity(0.22)),
                  ),
                  child: Icon(
                    statusIcon,
                    size: 54,
                    color: statusColor.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  icon: Icons.badge_outlined,
                  iconColor: statusColor,
                  title: i18n.t('realNameIdentityInfo'),
                ),
                const SizedBox(height: 14),
                const Divider(color: Color(0x2239E6FF), height: 1),
                const SizedBox(height: 18),
                _buildInfoRow(
                  label: i18n.t('realNameName'),
                  value: displayName.isEmpty ? '-' : displayName,
                ),
                const SizedBox(height: 18),
                _buildInfoRow(
                  label: i18n.t('realNameIdCard'),
                  value: _maskIdCard(displayIdCard),
                ),
                const SizedBox(height: 18),
                _buildInfoRow(
                  label: i18n.t('realNameCurrentStatus'),
                  value: title,
                ),
                if ((latest?['rejectReason']?.toString().isNotEmpty ??
                    false)) ...[
                  const SizedBox(height: 18),
                  _buildInfoRow(
                    label: i18n.t('realNameRejectReason'),
                    value: latest!['rejectReason'].toString(),
                    valueColor: const Color(0xFFFF6B6B),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_controller.status == 2) ...[
            _buildRejectedNotice(i18n),
            const SizedBox(height: 20),
            _buildFormView(i18n, controller),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
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
      child: child,
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      filled: true,
      fillColor: const Color(0x401A2A40),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x334CE3FF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x334CE3FF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.2),
      ),
    );
  }

  Widget _buildRejectedNotice(AppLocalizations i18n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x22FF6B6B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x66FF6B6B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              i18n.t('realNameRejectedHint'),
              style: const TextStyle(
                color: Color(0xFFFFD7D7),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color valueColor = AppColors.textPrimary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF39E6FF).withOpacity(0.8),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _maskIdCard(String idCard) {
    if (idCard.isEmpty) return '-';
    if (idCard.length <= 8) {
      return idCard;
    }
    final String prefix = idCard.substring(0, 4);
    final String suffix = idCard.substring(idCard.length - 4);
    return '$prefix${'*' * (idCard.length - 8)}$suffix';
  }

  Widget _buildFormView(
      AppLocalizations i18n, RealNameAuthController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    icon: Icons.verified_user_outlined,
                    iconColor: AppColors.primary,
                    title: i18n.t('mineRealNameAuth'),
                    trailing: _buildStatusBadge(),
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0x2239E6FF), height: 1),
                  const SizedBox(height: 14),
                  Text(
                    i18n.t('realNameIdentityInfo'),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (controller.status == 2) ...[
              _buildRejectedNotice(i18n),
              if (controller.rejectReason != null &&
                  controller.rejectReason!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildSectionCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '${i18n.t('realNameRejectReason')}: ${controller.rejectReason}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
            ],
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.primary,
                    title: i18n.t('realNameIdentityInfo'),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    i18n.t('realNameName'),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _realNameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _buildInputDecoration(
                      hintText: i18n.t('realNameNameHint'),
                      icon: Icons.badge_outlined,
                    ),
                    onChanged: (value) => controller.realName = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return i18n.t('realNameNameRequired');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    i18n.t('realNameIdCard'),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _idCardController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _buildInputDecoration(
                      hintText: i18n.t('realNameIdCardHint'),
                      icon: Icons.credit_card_outlined,
                    ),
                    onChanged: (value) => controller.idCardNumber = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return i18n.t('realNameIdCardRequired');
                      }
                      if (value.length != 15 && value.length != 18) {
                        return i18n.t('realNameIdCardLengthError');
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    icon: Icons.photo_library_outlined,
                    iconColor: AppColors.secondary,
                    title: i18n.t('realNameIdCardFront'),
                    subtitle: i18n.t('realNameIdCardBack'),
                  ),
                  const SizedBox(height: 18),
                  _buildImageUploader(
                    label: i18n.t('realNameIdCardFront'),
                    imageUrl: controller.idCardFront,
                    imageBytes: controller.idCardFrontPreview,
                    onTap: () {
                      controller.pickImage(0);
                      if (mounted) {
                        setState(() {
                          _idCardFrontError = null;
                        });
                      }
                    },
                    aspectRatio: 1.586,
                    placeholder: _buildCardPlaceholder(
                      i18n.t('realNameIdCardFront'),
                      i18n.t('realNameIdCardFrontRequired'),
                    ),
                    errorText: _idCardFrontError,
                  ),
                  const SizedBox(height: 18),
                  _buildImageUploader(
                    label: i18n.t('realNameIdCardBack'),
                    imageUrl: controller.idCardBack,
                    imageBytes: controller.idCardBackPreview,
                    onTap: () {
                      controller.pickImage(1);
                      if (mounted) {
                        setState(() {
                          _idCardBackError = null;
                        });
                      }
                    },
                    aspectRatio: 1.586,
                    placeholder: _buildCardPlaceholder(
                      i18n.t('realNameIdCardBack'),
                      i18n.t('realNameIdCardBackRequired'),
                    ),
                    errorText: _idCardBackError,
                  ),
                  if (controller.handheldRequired) ...[
                    const SizedBox(height: 18),
                    _buildImageUploader(
                      label: i18n.t('realNameHandheld'),
                      imageUrl: controller.handheldPhoto,
                      imageBytes: controller.handheldPhotoPreview,
                      onTap: () {
                        controller.pickImage(2);
                        if (mounted) {
                          setState(() {
                            _handheldPhotoError = null;
                          });
                        }
                      },
                      aspectRatio: 0.75,
                      placeholder: _buildCardPlaceholder(
                        i18n.t('realNameHandheld'),
                        i18n.t('realNameHandheldRequired'),
                      ),
                      errorText: _handheldPhotoError,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: controller.submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: const Color(0xFF0A1220),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: controller.submitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0A1220),
                        ),
                      )
                    : Text(
                        i18n.t('realNameSubmit'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
