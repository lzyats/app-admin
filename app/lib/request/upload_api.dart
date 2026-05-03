import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:myapp/request/http_client.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';
import 'package:myapp/tools/auth_tool.dart';

class UploadResult {
  final bool success;
  final String? fileName;
  final String? url;
  final String? error;

  UploadResult({
    required this.success,
    this.fileName,
    this.url,
    this.error,
  });
}

class PresignedResponse {
  final String url;
  final String key;
  final String type;
  final String? accessKey;
  final String? signature;
  final String? policy;
  final int? expire;

  PresignedResponse({
    required this.url,
    required this.key,
    required this.type,
    this.accessKey,
    this.signature,
    this.policy,
    this.expire,
  });

  factory PresignedResponse.fromMap(Map<String, dynamic> map) {
    return PresignedResponse(
      url: map['url'] ?? '',
      key: map['key'] ?? '',
      type: map['type'] ?? 'local',
      accessKey: map['accessKey'],
      signature: map['signature'],
      policy: map['policy'],
      expire: map['expire'],
    );
  }
}

abstract class CloudUploader {
  Future<UploadResult> upload(
    String filePath,
    String fileName,
    PresignedResponse presigned,
    {
    Uint8List? bytes,
  });
}

class OssUploader implements CloudUploader {
  @override
  Future<UploadResult> upload(
    String filePath,
    String fileName,
    PresignedResponse presigned,
    {
    Uint8List? bytes,
  }) async {
    try {
      final uploadBytes = bytes ?? await File(filePath).readAsBytes();

      final formData = FormData.fromMap({
        'key': presigned.key,
        'OSSAccessKeyId': presigned.accessKey,
        'signature': presigned.signature,
        'policy': presigned.policy,
        'success_action_status': '200',
        'file': MultipartFile.fromBytes(uploadBytes, filename: fileName),
      });

      final dio = Dio();
      final response = await dio.post(
        presigned.url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final fileUrl = '${presigned.url}/${presigned.key}';
        return UploadResult(
          success: true,
          fileName: fileName,
          url: fileUrl,
        );
      }

      return UploadResult(
        success: false,
        error: '涓婁紶澶辫触: ${response.statusCode}',
      );
    } catch (e) {
      return UploadResult(
        success: false,
        error: '涓婁紶澶辫触: $e',
      );
    }
  }
}

class CosUploader implements CloudUploader {
  @override
  Future<UploadResult> upload(
    String filePath,
    String fileName,
    PresignedResponse presigned,
    {
    Uint8List? bytes,
  }) async {
    try {
      final uploadBytes = bytes ?? await File(filePath).readAsBytes();

      final formData = FormData.fromMap({
        'key': presigned.key,
        'signature': presigned.signature,
        'policy': presigned.policy,
        'file': MultipartFile.fromBytes(uploadBytes, filename: fileName),
      });

      final dio = Dio();
      final response = await dio.post(
        presigned.url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final fileUrl = '${presigned.url}/${presigned.key}';
        return UploadResult(
          success: true,
          fileName: fileName,
          url: fileUrl,
        );
      }

      return UploadResult(
        success: false,
        error: '涓婁紶澶辫触: ${response.statusCode}',
      );
    } catch (e) {
      return UploadResult(
        success: false,
        error: '涓婁紶澶辫触: $e',
      );
    }
  }
}

class S3Uploader implements CloudUploader {
  @override
  Future<UploadResult> upload(
    String filePath,
    String fileName,
    PresignedResponse presigned,
    {
    Uint8List? bytes,
  }) async {
    try {
      final uploadBytes = bytes ?? await File(filePath).readAsBytes();

      final formData = FormData.fromMap({
        'key': presigned.key,
        'X-Amz-Credential': presigned.accessKey,
        'X-Amz-Signature': presigned.signature,
        'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
        'policy': presigned.policy,
        'file': MultipartFile.fromBytes(uploadBytes, filename: fileName),
      });

      final dio = Dio();
      final response = await dio.post(
        presigned.url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final fileUrl = '${presigned.url}/${presigned.key}';
        return UploadResult(
          success: true,
          fileName: fileName,
          url: fileUrl,
        );
      }

      return UploadResult(
        success: false,
        error: '涓婁紶澶辫触: ${response.statusCode}',
      );
    } catch (e) {
      return UploadResult(
        success: false,
        error: '涓婁紶澶辫触: $e',
      );
    }
  }
}

class LocalUploader implements CloudUploader {
  @override
  Future<UploadResult> upload(
    String filePath,
    String fileName,
    PresignedResponse presigned,
    {
    Uint8List? bytes,
  }) async {
    try {
      final uploadBytes = bytes ?? await File(filePath).readAsBytes();

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(uploadBytes, filename: fileName),
      });

      final dio = Dio();
      final response = await dio.post(
        presigned.url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return UploadResult(
          success: true,
          fileName: data['fileName'] ?? fileName,
          url: data['url'],
        );
      }

      return UploadResult(
        success: false,
        error: '涓婁紶澶辫触: ${response.statusCode}',
      );
    } catch (e) {
      return UploadResult(
        success: false,
        error: '涓婁紶澶辫触: $e',
      );
    }
  }
}

class UploadApi {
  static CloudUploader _getUploader(String type) {
    switch (type) {
      case 'oss':
        return OssUploader();
      case 'cos':
        return CosUploader();
      case 's3':
        return S3Uploader();
      case 'local':
      default:
        return LocalUploader();
    }
  }

  static Future<UploadResult> _uploadViaCommonEndpoint(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final MultipartFile file = MultipartFile.fromBytes(bytes, filename: fileName);
      final response = await HttpClient.api.upload(
        RuoYiEndpoints.upload,
        file: file,
        fileFieldName: 'file',
        retry: false,
      );

      if (response.isSuccess) {
        final dynamic raw = response.raw;
        final String url = (raw['url'] ?? '').toString();
        final String savedFileName = (raw['fileName'] ?? fileName).toString();
        if (url.isNotEmpty) {
          return UploadResult(
            success: true,
            fileName: savedFileName,
            url: url,
          );
        }
      }

      return UploadResult(
        success: false,
        error: response.msg.isNotEmpty ? response.msg : '获取上传地址失败',
      );
    } catch (e) {
      return UploadResult(
        success: false,
        error: '上传失败: $e',
      );
    }
  }

  static Future<PresignedResponse?> _getPresigned(
    String fileName,
    String fileType,
  ) async {
      if (!AuthTool.isLogin) {
        await AuthTool.init();
      }
      if (!AuthTool.isLogin) {
        return null;
      }

    try {
      final response = await HttpClient.post(
        RuoYiEndpoints.uploadPresigned,
        data: {
          'fileName': fileName,
          'fileType': fileType,
        },
        encrypt: true,
        retry: false,
      );

      if (response.isSuccess && response.data != null) {
        return PresignedResponse.fromMap(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<UploadResult> uploadFile(
    String filePath,
    String fileName, {
    String? fileType,
    Function(double)? onProgress,
  }) async {
    try {
      final uploadBytes = await File(filePath).readAsBytes();
      return await _uploadViaCommonEndpoint(uploadBytes, fileName);
    } catch (e) {
      return UploadResult(
        success: false,
        error: '上传失败: $e',
      );
    }
  }

  static Future<UploadResult> uploadBytes(
    Uint8List bytes,
    String fileName, {
    String? fileType,
    Function(double)? onProgress,
  }) async {
    try {
      return await _uploadViaCommonEndpoint(bytes, fileName);
    } catch (e) {
      return UploadResult(
        success: false,
        error: '上传失败: $e',
      );
    }
  }

  static Future<bool> uploadCallback(Map<String, dynamic> params) async {
    try {
      final response = await HttpClient.post(
        RuoYiEndpoints.uploadCallback,
        data: params,
        encrypt: true,
        retry: false,
      );
      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }

  static String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'mp4':
        return 'video/mp4';
      case 'avi':
        return 'video/x-msvideo';
      case 'mov':
        return 'video/quicktime';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      default:
        return 'application/octet-stream';
    }
  }
}



