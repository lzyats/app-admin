import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/request/real_name_api.dart';
import 'package:myapp/request/upload_api.dart';
import 'package:myapp/tools/app_bootstrap_tool.dart';
import 'package:myapp/tools/auth_tool.dart';

class _PickedImageData {
  final String fileName;
  final Uint8List bytes;

  const _PickedImageData({
    required this.fileName,
    required this.bytes,
  });
}

class RealNameAuthController extends ChangeNotifier {
  final RealNameApi _api = RealNameApi();
  final ImagePicker _picker = ImagePicker();

  bool _loading = false;
  bool get loading => _loading;

  bool _submitting = false;
  bool get submitting => _submitting;

  bool _handheldRequired = false;
  bool get handheldRequired => _handheldRequired;

  int _status = -1;
  int get status => _status;

  String? _rejectReason;
  String? get rejectReason => _rejectReason;

  Map<String, dynamic>? _latestAuth;
  Map<String, dynamic>? get latestAuth => _latestAuth;

  String _realName = '';
  String get realName => _realName;
  set realName(String value) {
    _realName = value;
    notifyListeners();
  }

  String _idCardNumber = '';
  String get idCardNumber => _idCardNumber;
  set idCardNumber(String value) {
    _idCardNumber = value;
    notifyListeners();
  }

  String? _idCardFront;
  String? get idCardFront => _idCardFront;
  set idCardFront(String? value) {
    _idCardFront = value;
    notifyListeners();
  }

  String? _idCardBack;
  String? get idCardBack => _idCardBack;
  set idCardBack(String? value) {
    _idCardBack = value;
    notifyListeners();
  }

  String? _handheldPhoto;
  String? get handheldPhoto => _handheldPhoto;
  set handheldPhoto(String? value) {
    _handheldPhoto = value;
    notifyListeners();
  }

  _PickedImageData? _idCardFrontImage;
  _PickedImageData? get idCardFrontImage => _idCardFrontImage;

  _PickedImageData? _idCardBackImage;
  _PickedImageData? get idCardBackImage => _idCardBackImage;

  _PickedImageData? _handheldPhotoImage;
  _PickedImageData? get handheldPhotoImage => _handheldPhotoImage;

  Uint8List? get idCardFrontPreview => _idCardFrontImage?.bytes;
  Uint8List? get idCardBackPreview => _idCardBackImage?.bytes;
  Uint8List? get handheldPhotoPreview => _handheldPhotoImage?.bytes;

  Future<void> loadStatus() async {
    _loading = true;
    notifyListeners();

    try {
      _handheldRequired = AppBootstrapTool.config.realNameHandheldRequired;
      final statusData = await _api.status();
      _status = _toInt(statusData['status']);
      _latestAuth = _toMap(statusData['latestAuth']);
      await AuthTool.updateRealNameStatus(_status);
      _syncLatestAuthFields();
    } catch (e) {
      debugPrint('加载实名认证状态失败: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage(int type) async {
    try {
      if (type == 2 && !AppBootstrapTool.config.realNameHandheldRequired) {
        return;
      }
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      final picked = _PickedImageData(fileName: image.name, bytes: bytes);

      switch (type) {
        case 0:
          _idCardFrontImage = picked;
          _idCardFront = null;
          break;
        case 1:
          _idCardBackImage = picked;
          _idCardBack = null;
          break;
        case 2:
          _handheldPhotoImage = picked;
          _handheldPhoto = null;
          break;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('选择图片失败: $e');
    }
  }

  Future<String> _uploadPickedImage(_PickedImageData? image) async {
    if (image == null) {
      throw Exception('请选择图片');
    }

    final result = await UploadApi.uploadBytes(image.bytes, image.fileName);
    if (!result.success || result.url == null || result.url!.isEmpty) {
      throw Exception(result.error ?? '上传失败');
    }
    return result.url!;
  }

  Future<bool> submit() async {
    if (_realName.isEmpty) return false;
    if (_idCardNumber.isEmpty) return false;
    if ((_idCardFront == null || _idCardFront!.isEmpty) && _idCardFrontImage == null) return false;
    if ((_idCardBack == null || _idCardBack!.isEmpty) && _idCardBackImage == null) return false;
    final bool needHandheld = AppBootstrapTool.config.realNameHandheldRequired;
    if (needHandheld &&
        (_handheldPhoto == null || _handheldPhoto!.isEmpty) &&
        _handheldPhotoImage == null) {
      return false;
    }

    _submitting = true;
    notifyListeners();

    try {
      final frontUrl = (_idCardFront != null && _idCardFront!.isNotEmpty)
          ? _idCardFront!
          : await _uploadPickedImage(_idCardFrontImage);
      final backUrl = (_idCardBack != null && _idCardBack!.isNotEmpty)
          ? _idCardBack!
          : await _uploadPickedImage(_idCardBackImage);
      final handheldUrl = needHandheld
          ? ((_handheldPhoto != null && _handheldPhoto!.isNotEmpty)
              ? _handheldPhoto!
              : await _uploadPickedImage(_handheldPhotoImage))
          : null;

      _idCardFront = frontUrl;
      _idCardBack = backUrl;
      _handheldPhoto = handheldUrl;

      await _api.submit(
        realName: _realName,
        idCardNumber: _idCardNumber,
        idCardFront: frontUrl,
        idCardBack: backUrl,
        handheldPhoto: needHandheld ? handheldUrl : null,
      );

      await AuthTool.updateRealNameStatus(1);
      _status = 1;
      notifyListeners();
      await loadStatus();
      return true;
    } catch (e) {
      debugPrint('提交实名认证失败: $e');
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  void reset() {
    _realName = '';
    _idCardNumber = '';
    _idCardFront = null;
    _idCardBack = null;
    _handheldPhoto = null;
    _idCardFrontImage = null;
    _idCardBackImage = null;
    _handheldPhotoImage = null;
    _rejectReason = null;
    _latestAuth = null;
    notifyListeners();
  }

  void _syncLatestAuthFields() {
    final Map<String, dynamic>? latest = _latestAuth;
    if (latest == null) {
      if (_status == 0) {
        _realName = '';
        _idCardNumber = '';
        _idCardFront = null;
        _idCardBack = null;
        _handheldPhoto = null;
      }
      return;
    }
    _realName = latest['realName']?.toString() ?? _realName;
    _idCardNumber = latest['idCardNumber']?.toString() ?? _idCardNumber;
    _idCardFront = latest['idCardFront']?.toString();
    _idCardBack = latest['idCardBack']?.toString();
    _handheldPhoto = latest['handheldPhoto']?.toString();
    _rejectReason = latest['rejectReason']?.toString();
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }
}
