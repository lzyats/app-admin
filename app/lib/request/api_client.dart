import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:myapp/config/app_config.dart';
import 'package:myapp/request/api_error_code.dart';
import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/api_response.dart';
import 'package:myapp/request/interceptors/auth_sign_interceptor.dart';
import 'package:myapp/request/interceptors/retry_interceptor.dart';
import 'package:myapp/request/request_extra.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';
import 'package:myapp/tools/auth_tool.dart';
import 'package:myapp/tools/line_host_tool.dart';
import 'package:myapp/tools/local_proxy_manager.dart';
import 'package:myapp/tools/runtime_proxy.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  late final Dio _dio = _buildDio();
  int _lastBaseUrlRevision = -1;
  String _lastResolvedBaseUrl = '';

  Dio get dio => _dio;

  String? resolveImageUrl(String? value) {
    final String? raw = value?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    if (raw.startsWith('http://') ||
        raw.startsWith('https://') ||
        raw.startsWith('data:image/') ||
        raw.startsWith('blob:') ||
        raw.startsWith('file:')) {
      return raw;
    }
    final Uri baseUri = Uri.parse(_dio.options.baseUrl.endsWith('/')
        ? _dio.options.baseUrl
        : '${_dio.options.baseUrl}/');
    final String normalizedPath = raw.startsWith('/') ? raw.substring(1) : raw;
    return baseUri.resolve(normalizedPath).toString();
  }

  static const String apiSecretHeader = 'X-Api-Secret';
  static const String apiSecret = 'GoApiApp2024SecretKey';

  Dio _buildDio() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: _defaultBaseUrl(),
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: kIsWeb ? null : AppConfig.sendTimeout,
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
      ),
    );
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('ApiClient request headers before: ${options.headers}');
        debugPrint('ApiClient request uri: ${options.uri}');
        debugPrint('ApiClient enableLocalProxy: ${AppConfig.enableLocalProxy}');
        debugPrint('ApiClient RuntimeProxy.authToken: ${RuntimeProxy.authToken}');

        if (options.uri.host == '127.0.0.1' && options.uri.port != 8080) {
          options.headers['x-local-proxy'] = RuntimeProxy.authToken;
          debugPrint('ApiClient added x-local-proxy header: ${RuntimeProxy.authToken}');
        }

        options.headers[apiSecretHeader] = apiSecret;
        debugPrint('ApiClient added $apiSecretHeader header: $apiSecret');
        options.headers['X-Client-Type'] = 'app';
        debugPrint('ApiClient added X-Client-Type header: app');

        debugPrint('ApiClient request headers after: ${options.headers}');
        handler.next(options);
      },
    ));
    dio.interceptors.add(AuthSignInterceptor());
    dio.interceptors.add(RetryInterceptor(dio));
    return dio;
  }

  String _defaultBaseUrl() {
    if (AppConfig.enableLocalProxy) {
      return RuntimeProxy.httpBaseUrl();
    }
    return _buildUpstreamBaseUrl(AppConfig.defaultRequestHost.httpUrl);
  }

  Future<String> _computeBaseUrl() async {
    if (AppConfig.enableLocalProxy) {
      await LocalProxyManager.instance.startHttpProxy();
      return RuntimeProxy.httpBaseUrl();
    }
    final RequestHost host = await LineHostTool.getCurrentHost();
    return _buildUpstreamBaseUrl(host.httpUrl);
  }

  String _buildUpstreamBaseUrl(String hostUrl) {
    final Uri uri = Uri.parse(hostUrl);
    final bool hasCustomPath = uri.path.isNotEmpty && uri.path != '/';
    if (hasCustomPath) {
      return hostUrl;
    }
    return '$hostUrl${AppConfig.requestBasePath}';
  }

  Future<void> refreshBaseUrl() async {
    final int currentRevision = LineHostTool.revision;
    if (AppConfig.enableLocalProxy) {
      if (RuntimeProxy.httpReady &&
          _lastBaseUrlRevision == currentRevision &&
          _dio.options.baseUrl == RuntimeProxy.httpBaseUrl()) {
        return;
      }
    } else if (_lastBaseUrlRevision == currentRevision &&
        _lastResolvedBaseUrl.isNotEmpty &&
        _dio.options.baseUrl == _lastResolvedBaseUrl) {
      return;
    }

    final String newBase = await _computeBaseUrl();
    _lastBaseUrlRevision = currentRevision;
    _lastResolvedBaseUrl = newBase;
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

  void setDirectBaseUrl(String baseUrl) {
    if (_dio.options.baseUrl != baseUrl) {
      _dio.options.baseUrl = baseUrl;
      debugPrint('API baseUrl forced direct: $baseUrl');
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

  Future<ApiResponse<dynamic>> put(
    String path, {
    dynamic data,
    bool encrypt = true,
    bool retry = true,
  }) async {
    return _request(
      path,
      method: 'PUT',
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
    String fileFieldName = 'file',
    Map<String, dynamic>? fields,
    bool retry = true,
  }) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      ...?fields,
      fileFieldName: file,
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

      if (path == RuoYiEndpoints.captchaImage) {
        final dynamic rawData = response.data;
        final Map<String, dynamic> captchaData = rawData is Map<String, dynamic>
            ? rawData
            : rawData is Map
                ? Map<String, dynamic>.from(rawData)
                : <String, dynamic>{};
        return ApiResponse(
          code: ApiErrorCode.ok,
          msg: 'success',
          data: captchaData,
          raw: captchaData,
        );
      }

      if (response.data is! Map<String, dynamic>) {
        throw ApiException('authInvalidResponse', origin: response.data);
      }

      final ApiResponse<dynamic> ajax = ApiResponse.fromJson(response.data as Map<String, dynamic>);
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
      throw ApiException('authNetworkError',
          origin: e, code: e.response?.statusCode);
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
      throw ApiException(
        'authUnauthorized',
        code: ajax.code,
        rawMessage: ajax.msg,
      );
    }

    if (ajax.code == ApiErrorCode.banned ||
        ajax.code == ApiErrorCode.forbidden) {
      throw ApiException(
        'authForbidden',
        code: ajax.code,
        rawMessage: ajax.msg,
      );
    }

    throw ApiException(
      'authRequestFailed',
      code: ajax.code,
      rawMessage: ajax.msg,
    );
  }

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
