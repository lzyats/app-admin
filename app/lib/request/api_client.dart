import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../tools/auth_tool.dart';
import 'api_error_code.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'interceptors/auth_sign_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'request_extra.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  Dio _buildDio() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: _computeBaseUrl(),
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
      ),
    );
    dio.interceptors.add(AuthSignInterceptor());
    dio.interceptors.add(RetryInterceptor(dio));
    return dio;
  }

  String _computeBaseUrl() {
    if (AppConfig.enableLocalProxy) {
      return 'http://${AppConfig.localProxyHost}:${AppConfig.localProxyPort}';
    }
    return '${AppConfig.requestHost}${AppConfig.requestBasePath}';
  }

  Future<void> refreshBaseUrl() async {
    final String newBase = _computeBaseUrl();
    if (_dio.options.baseUrl != newBase) {
      _dio.options.baseUrl = newBase;
      debugPrint('API baseUrl switched: $newBase');
    }
  }

  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool encrypt = true,
    bool retry = true,
  }) async {
    return _request(
      path,
      method: 'GET',
      query: query,
      encrypt: encrypt,
      retry: retry,
    );
  }

  Future<ApiResponse<dynamic>> post(
    String path, {
    dynamic data,
    bool encrypt = true,
    bool retry = true,
  }) async {
    return _request(
      path,
      method: 'POST',
      data: data,
      encrypt: encrypt,
      retry: retry,
    );
  }

  Future<ApiResponse<dynamic>> page(
    String path, {
    required int pageNum,
    int pageSize = 10,
    Map<String, dynamic>? data,
    bool encrypt = true,
    bool retry = true,
  }) async {
    final Map<String, dynamic> query = <String, dynamic>{
      'pageNum': pageNum < 1 ? 1 : pageNum,
      'pageSize': pageSize,
      ...?data,
    };
    return get(path, query: query, encrypt: encrypt, retry: retry);
  }

  Future<ApiResponse<dynamic>> upload(
    String path, {
    required MultipartFile file,
    Map<String, dynamic>? fields,
    bool retry = true,
  }) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      ...?fields,
      'file': file,
    });

    return _request(
      path,
      method: 'POST',
      data: formData,
      encrypt: false,
      retry: retry,
    );
  }

  Future<ApiResponse<dynamic>> _request(
    String path, {
    required String method,
    Map<String, dynamic>? query,
    dynamic data,
    required bool encrypt,
    required bool retry,
  }) async {
    await refreshBaseUrl();

    try {
      final Response<dynamic> response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: Options(
          method: method,
          extra: <String, dynamic>{
            RequestExtra.encrypt: encrypt,
            RequestExtra.retry: retry,
            RequestExtra.retryCount: 0,
          },
        ),
      );

      if (response.data is! Map<String, dynamic>) {
        throw ApiException('Invalid response format', origin: response.data);
      }

      final ApiResponse<dynamic> ajax = ApiResponse.fromJson(response.data as Map<String, dynamic>);
      _handleBusinessCode(ajax);
      return ajax;
    } on DioException catch (e) {
      throw ApiException('Network error', origin: e, code: e.response?.statusCode);
    }
  }

  void _handleBusinessCode(ApiResponse<dynamic> ajax) {
    if (ajax.code == ApiErrorCode.ok) {
      return;
    }

    if (ajax.code == ApiErrorCode.unauthorized ||
        ajax.code == ApiErrorCode.tokenExpired ||
        ajax.code == ApiErrorCode.forceLogin) {
      AuthTool.logout();
      throw ApiException(ajax.msg.isEmpty ? 'Unauthorized' : ajax.msg, code: ajax.code);
    }

    if (ajax.code == ApiErrorCode.banned || ajax.code == ApiErrorCode.forbidden) {
      throw ApiException(ajax.msg.isEmpty ? 'Forbidden' : ajax.msg, code: ajax.code);
    }

    throw ApiException(ajax.msg.isEmpty ? 'Request failed' : ajax.msg, code: ajax.code);
  }
}
