import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/widgets/app_image_cache.dart';
import 'package:myapp/pages/mine/avatar_crop_page.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/request/upload_api.dart';
import 'package:myapp/tools/auth_tool.dart';
import 'package:myapp/widgets/app_network_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthUserProfile? _userInfo;
  bool _isLoading = true;
  bool _loadedInitialUserInfo = false;

  AppLocalizations get i18n => AppLocalizations.of(context)!;

  void _showSnackMessage(String message, {bool success = false}) {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialUserInfo();
    });
  }

  Future<void> _loadInitialUserInfo() async {
    if (!mounted) {
      return;
    }
    if (_loadedInitialUserInfo) {
      return;
    }
    _loadedInitialUserInfo = true;

    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is AuthUserProfile) {
      await AuthTool.saveUserProfile(arguments);
      unawaited(_warmAvatarCache(arguments.resolvedAvatarUrl));
      if (mounted) {
        setState(() {
          _userInfo = arguments;
          _isLoading = false;
        });
      }
      return;
    }

    final AuthUserProfile? cachedUser = await AuthTool.getUserProfile();
    if (cachedUser != null && cachedUser.userId > 0) {
      if (mounted) {
        setState(() {
          _userInfo = cachedUser;
          _isLoading = false;
        });
      }
    }
    await _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await AuthApi.getInfo();
      await AuthTool.saveUserProfile(userInfo);
      unawaited(_warmAvatarCache(userInfo.resolvedAvatarUrl));
      if (!mounted) {
        return;
      }
      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      _showSnackMessage(i18n.t('loadFailed'));
    }
  }

  Future<void> _applyLocalProfilePatch(AuthUserProfile Function(AuthUserProfile current) patch) async {
    final AuthUserProfile? current = _userInfo ?? await AuthTool.getUserProfile();
    if (current == null) {
      return;
    }
    final AuthUserProfile updated = patch(current);
    await AuthTool.saveUserProfile(updated);
    if (mounted) {
      setState(() {
        _userInfo = updated;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      final Uint8List? croppedBytes = await Navigator.of(context).push<Uint8List>(
        MaterialPageRoute<Uint8List>(
          builder: (BuildContext context) => AvatarCropPage(
            imageBytes: imageBytes,
            title: i18n.t('avatarCropTitle'),
          ),
        ),
      );

      if (croppedBytes == null || croppedBytes.isEmpty) {
        return;
      }

      try {
        final result = await UploadApi.uploadBytes(
          croppedBytes,
          pickedFile.name.isNotEmpty ? _buildAvatarFileName(pickedFile.name) : 'avatar.png',
        );
        if (!result.success || result.url == null || result.url!.isEmpty) {
          throw Exception(result.error ?? 'upload failed');
        }
        final String avatarUrl = result.url!;
        await AuthApi.updateUserInfo({'avatar': avatarUrl});
        await _applyLocalProfilePatch((AuthUserProfile current) => current.copyWith(avatar: avatarUrl));
        unawaited(_warmAvatarCache(avatarUrl));
        if (!mounted) {
          return;
        }
        _showSnackMessage(i18n.t('uploadSuccess'), success: true);
      } catch (e) {
        if (!mounted) {
          return;
        }
        _showSnackMessage(i18n.t('uploadFailed'));
      }
    }
  }

  String _buildAvatarFileName(String fileName) {
    final String trimmed = fileName.trim();
    if (trimmed.isEmpty) {
      return 'avatar.png';
    }
    final int dotIndex = trimmed.lastIndexOf('.');
    if (dotIndex <= 0) {
      return '$trimmed.png';
    }
    return '${trimmed.substring(0, dotIndex)}.png';
  }

  Future<void> _warmAvatarCache(String? avatarUrl) async {
    final String url = (avatarUrl ?? '').trim();
    if (url.isEmpty) {
      return;
    }
    await AppImageCache.instance.prefetch(url);
  }

  void _showEditNickName() {
    _showEditDialog(
      title: i18n.t('mineNickname'),
      currentValue: _userInfo?.nickName ?? '',
      onSave: (value) async {
        try {
          await AuthApi.updateUserInfo({'nickName': value});
          await _applyLocalProfilePatch((AuthUserProfile current) => current.copyWith(nickName: value));
          if (!mounted) {
            return;
          }
          _showSnackMessage(i18n.t('saveSuccess'), success: true);
        } catch (e) {
          if (!mounted) {
            return;
          }
          _showSnackMessage(i18n.t('saveFailed'));
        }
      },
    );
  }

  void _showEditRemark() {
    _showEditDialog(
      title: i18n.t('mineRemark'),
      currentValue: _userInfo?.remark ?? '',
      onSave: (value) async {
        try {
          await AuthApi.updateUserInfo({'remark': value});
          await _applyLocalProfilePatch((AuthUserProfile current) => current.copyWith(remark: value));
          if (!mounted) {
            return;
          }
          _showSnackMessage(i18n.t('saveSuccess'), success: true);
        } catch (e) {
          if (!mounted) {
            return;
          }
          _showSnackMessage(i18n.t('saveFailed'));
        }
      },
    );
  }

  void _showEditPhone() {
    _showEditDialog(
      title: i18n.t('minePhone'),
      currentValue: _userInfo?.phonenumber ?? '',
      onSave: (value) async {
        try {
          await AuthApi.updateUserInfo({'phonenumber': value});
          await _applyLocalProfilePatch((AuthUserProfile current) => current.copyWith(phonenumber: value));
          if (!mounted) {
            return;
          }
          _showSnackMessage(i18n.t('saveSuccess'), success: true);
        } catch (e) {
          if (!mounted) {
            return;
          }
          _showSnackMessage(i18n.t('saveFailed'));
        }
      },
    );
  }

  void _showEditEmail() {
    _showEditDialog(
      title: i18n.t('mineEmail'),
      currentValue: _userInfo?.email ?? '',
      onSave: (value) async {
        try {
          await AuthApi.updateUserInfo({'email': value});
          await _applyLocalProfilePatch((AuthUserProfile current) => current.copyWith(email: value));
          if (!mounted) {
            return;
          }
          _showSnackMessage(i18n.t('saveSuccess'), success: true);
        } catch (e) {
          if (!mounted) {
            return;
          }
          _showSnackMessage(i18n.t('saveFailed'));
        }
      },
    );
  }

  void _showEditBirthday() {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _parseBirthday(_userInfo?.birthday) ?? now;
    final DateTime firstDate = DateTime(now.year - 100);
    final DateTime lastDate = DateTime(now.year + 1);

    showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate)
          ? firstDate
          : (initialDate.isAfter(lastDate) ? lastDate : initialDate),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('zh', 'CN'),
    ).then((DateTime? selected) async {
      if (selected == null) {
        return;
      }
      final String value = _formatBirthday(selected);
      try {
        await AuthApi.updateUserInfo({'birthday': value});
        await _applyLocalProfilePatch((AuthUserProfile current) => current.copyWith(birthday: value));
        if (!mounted) {
          return;
        }
        _showSnackMessage(i18n.t('saveSuccess'), success: true);
      } catch (e) {
        if (!mounted) {
          return;
        }
        _showSnackMessage(i18n.t('saveFailed'));
      }
    });
  }

  void _showEditGender() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(i18n.t('mineGenderMale')),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await AuthApi.updateUserInfo({'sex': 0});
                  await _applyLocalProfilePatch((AuthUserProfile current) => current.copyWith(sex: 0));
                  if (!mounted) {
                    return;
                  }
                  _showSnackMessage(i18n.t('saveSuccess'), success: true);
                } catch (e) {
                  if (!mounted) {
                    return;
                  }
                  _showSnackMessage(i18n.t('saveFailed'));
                }
              },
            ),
            ListTile(
              title: Text(i18n.t('mineGenderFemale')),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await AuthApi.updateUserInfo({'sex': 1});
                  await _applyLocalProfilePatch((AuthUserProfile current) => current.copyWith(sex: 1));
                  if (!mounted) {
                    return;
                  }
                  _showSnackMessage(i18n.t('saveSuccess'), success: true);
                } catch (e) {
                  if (!mounted) {
                    return;
                  }
                  _showSnackMessage(i18n.t('saveFailed'));
                }
              },
            ),
            ListTile(
              title: Text(i18n.t('mineGenderUnknown')),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await AuthApi.updateUserInfo({'sex': 2});
                  await _applyLocalProfilePatch((AuthUserProfile current) => current.copyWith(sex: 2));
                  if (!mounted) {
                    return;
                  }
                  _showSnackMessage(i18n.t('saveSuccess'), success: true);
                } catch (e) {
                  if (!mounted) {
                    return;
                  }
                  _showSnackMessage(i18n.t('saveFailed'));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog({
    required String title,
    required String currentValue,
    required Function(String) onSave,
  }) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: i18n.t('pleaseInput') + title,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(i18n.t('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onSave(controller.text);
              },
              child: Text(i18n.t('submit')),
            ),
          ],
        );
      },
    );
  }

  String _getGenderText(int? sex) {
    switch (sex) {
      case 0:
        return i18n.t('mineGenderMale');
      case 1:
        return i18n.t('mineGenderFemale');
      case 2:
        return i18n.t('mineGenderUnknown');
      default:
        return i18n.t('mineGenderUnknown');
    }
  }

  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('邀请码已复制'),
        backgroundColor: Color(0xFF38FFB3),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyUserId(int userId) {
    Clipboard.setData(ClipboardData(text: userId.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('用户ID已复制'),
        backgroundColor: Color(0xFF38FFB3),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.t('mineProfile')),
        backgroundColor: const Color(0xFF101C30),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(),
            const SizedBox(height: 24),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final String? avatarUrl = _userInfo?.resolvedAvatarUrl;
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF39E6FF),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? AppNetworkImage(
                      src: avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          i18n.t('clickToChangeAvatar'),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9DB1C9),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    final String initial = _displayNickName().substring(0, 1);
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF39E6FF), Color(0xFF38FFB3)],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A1220),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            i18n.t('mineBasicInfo'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE9F3FF),
            ),
          ),
          const SizedBox(height: 16),
          _buildReadOnlyItem(
            label: i18n.t('mineNickname'),
            value: _displayNickName(),
            onTap: _showEditNickName,
          ),
          _buildReadOnlyItem(
            label: '用户名',
            value: _userInfo?.username ?? '',
          ),
          _buildReadOnlyItem(
            label: '用户ID',
            value: _userInfo?.userId.toString() ?? '',
            onTap: _userInfo?.userId != null
                ? () => _copyUserId(_userInfo!.userId!)
                : null,
            showCopyIcon: true,
          ),
          _buildEditableItem(
            label: i18n.t('mineGender'),
            value: _getGenderText(_userInfo?.sex),
            onTap: _showEditGender,
          ),
          _buildEditableItem(
            label: i18n.t('minePhone'),
            value: _userInfo?.phonenumber ?? '',
            onTap: _showEditPhone,
          ),
          _buildEditableItem(
            label: i18n.t('mineEmail'),
            value: _userInfo?.email ?? '',
            onTap: _showEditEmail,
          ),
          _buildEditableItem(
            label: i18n.t('mineBirthday'),
            value: _userInfo?.birthday ?? '',
            onTap: _showEditBirthday,
          ),
          _buildReadOnlyItem(
            label: i18n.t('mineInviteCode'),
            value: _userInfo?.inviteCode ?? '',
            onTap: _userInfo?.inviteCode != null
                ? () => _copyInviteCode(_userInfo!.inviteCode!)
                : null,
            showCopyIcon: true,
          ),
        ],
      ),
    );
  }

  String _displayNickName() {
    final String nickName = (_userInfo?.nickName ?? '').trim();
    if (nickName.isNotEmpty) {
      return nickName;
    }
    return '用户';
  }

  Widget _buildReadOnlyItem({
    required String label,
    required String value,
    VoidCallback? onTap,
    bool showCopyIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xCC101C30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x334CE3FF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9DB1C9),
                fontSize: 14,
              ),
            ),
            Row(
              children: [
                Text(
                  value.isEmpty ? i18n.t('notSet') : value,
                  style: const TextStyle(
                    color: Color(0xFFE9F3FF),
                    fontSize: 14,
                  ),
                ),
                if (showCopyIcon && onTap != null)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.copy,
                      size: 16,
                      color: Color(0xFF39E6FF),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableItem({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xCC101C30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x334CE3FF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9DB1C9),
                fontSize: 14,
              ),
            ),
            Row(
              children: [
                Text(
                  value.isEmpty ? i18n.t('notSet') : value,
                  style: const TextStyle(
                    color: Color(0xFFE9F3FF),
                    fontSize: 14,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Color(0xFF9DB1C9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _parseBirthday(String? birthday) {
    final String raw = (birthday ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }
    final String normalized = raw.contains(' ') ? raw.split(' ').first : raw;
    return DateTime.tryParse(normalized);
  }

  String _formatBirthday(DateTime date) {
    final int month = date.month;
    final int day = date.day;
    return '${date.year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
