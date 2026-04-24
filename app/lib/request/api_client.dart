import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:myapp/config/app_config.dart';
import 'package:myapp/request/api_error_code.dart';
import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/api_response.dart';
import 'package:myapp/request/interceptors/auth_sign_interceptor.dart';
import 'package:myapp/request/interceptors/retry_interceptor.dart';
import 'package:myapp/request/request_extra.dart';
import 'package:myapp/tools/auth_tool.dart';
import 'package:myapp/tools/line_host_tool.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  /// 构建全局 Dio 实例并挂载拦截器。
  Dio _buildDio() {
    final Duration? sendTimeout = kIsWeb ? null : AppConfig.sendTimeout;
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: _defaultBaseUrl(),
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: sendTimeout,
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
      ),
    );
    dio.interceptors.add(AuthSignInterceptor());
    dio.interceptors.add(RetryInterceptor(dio));
    return dio;
  }

  /// 计算初始化时默认 baseUrl。
  String _defaultBaseUrl() {
    if (AppConfig.enableLocalProxy) {
      return 'http://${AppConfig.localProxyHost}:${AppConfig.localProxyPort}';
    }
    return _buildUpstreamBaseUrl(AppConfig.defaultRequestHost.httpUrl);
  }

  /// 根据当前线路配置或本地代理状态计算 baseUrl。
  Future<String> _computeBaseUrl() async {
    if (AppConfig.enableLocalProxy) {
      return 'http://${AppConfig.localProxyHost}:${AppConfig.localProxyPort}';
    }
    final RequestHost host = await LineHostTool.getCurrentHost();
    return _buildUpstreamBaseUrl(host.httpUrl);
  }

  /// 组装上游服务地址，若 host 自带路径则直接使用。
  String _buildUpstreamBaseUrl(String hostUrl) {
    final Uri uri = Uri.parse(hostUrl);
    final bool hasCustomPath = uri.path.isNotEmpty && uri.path != '/';
    if (hasCustomPath) {
      return hostUrl;
    }
    return '$hostUrl${AppConfig.requestBasePath}';
  }

  /// 刷新 Dio 的 baseUrl 到最新地址。
  Future<void> refreshBaseUrl() async {
    final String newBase = await _computeBaseUrl();
    if (_dio.options.baseUrl != newBase) {
      _dio.options.baseUrl = newBase;
      debugPrint('API baseUrl switched: $newBase');
    }
    debugPrint(
      'ApiClient proxy enabled=${AppConfig.enableLocalProxy}, '
      'proxy=${AppConfig.localProxyHost}:${AppConfig.localProxyPort}, '
      'baseUrl=${_dio.options.baseUrl}',
    );
  }

  /// 发送 GET 请求。
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

  /// 发送 POST 请求。
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

  /// 发送分页查询请求。
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

  /// 发送文件上传请求。
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

  /// 请求统一入口，负责异常与业务码处理。
  Future<ApiResponse<dynamic>> _request(
    String path, {
    required String method,
    Map<String, dynamic>? query,
    dynamic data,
    required bool encrypt,
    required bool retry,
  }) async {
    await refreshBaseUrl();
    final Uri finalUri = _buildFinalUri(path: path, query: query);
    debugPrint('ApiClient request => $method $finalUri');
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
      debugPrint(
        'ApiClient response <= $method $finalUri, '
        'status=${response.statusCode}, data=${response.data}',
      );

      if (response.data is! Map<String, dynamic>) {
        throw ApiException('Invalid response format', origin: response.data);
      }

      final ApiResponse<dynamic> ajax =
          ApiResponse.fromJson(response.data as Map<String, dynamic>);
      _handleBusinessCode(ajax);
      return ajax;
    } on DioException catch (e) {
      debugPrint(
        'ApiClient error => $method $finalUri, '
        'type=${e.type}, status=${e.response?.statusCode}, message=${e.message}, '
        'data=${e.response?.data}',
      );
      if (kIsWeb && e.type == DioExceptionType.connectionError) {
        debugPrint('Web 端连接异常，可能是跨域（CORS）或混合内容（HTTPS 页面请求 HTTP API）导致。');
      }
      throw ApiException('Network error',
          origin: e, code: e.response?.statusCode);
    }
  }

  /// 处理后端业务状态码并抛出对应异常。
  void _handleBusinessCode(ApiResponse<dynamic> ajax) {
    if (ajax.code == ApiErrorCode.ok) {
      return;
    }

    if (ajax.code == ApiErrorCode.unauthorized ||
        ajax.code == ApiErrorCode.tokenExpired ||
        ajax.code == ApiErrorCode.forceLogin) {
      AuthTool.logout();
      throw ApiException(ajax.msg.isEmpty ? 'Unauthorized' : ajax.msg,
          code: ajax.code);
    }

    if (ajax.code == ApiErrorCode.banned ||
        ajax.code == ApiErrorCode.forbidden) {
      throw ApiException(ajax.msg.isEmpty ? 'Forbidden' : ajax.msg,
          code: ajax.code);
    }

    throw ApiException(ajax.msg.isEmpty ? 'Request failed' : ajax.msg,
        code: ajax.code);
  }

  /// 构建最终请求地址，便于统一日志输出。
  Uri _buildFinalUri({
    required String path,
    Map<String, dynamic>? query,
  }) {
    final String base = _dio.options.baseUrl;
    final Uri baseUri = Uri.parse(base.endsWith('/') ? base : '$base/');
    final String normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final Uri uri = baseUri.resolve(normalizedPath);
    if (query == null || query.isEmpty) {
      return uri;
    }
    return uri.replace(
      queryParameters: query.map((String key, dynamic value) => MapEntry(key, '$value')),
    );
  }
}
