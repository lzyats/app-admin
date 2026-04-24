import 'package:dio/dio.dart';

import 'package:myapp/config/app_config.dart';
import 'package:myapp/tools/auth_tool.dart';
import 'package:myapp/tools/encrypt_tool.dart';
import 'package:myapp/request/request_extra.dart';

class AuthSignInterceptor extends Interceptor {
  /// 创建鉴权与签名拦截器。
  AuthSignInterceptor();

  @override
  /// 请求发送前注入 token、签名与加密头。
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final bool encryptPayload = (options.extra[RequestExtra.encrypt] as bool?) ?? AppConfig.enableApiAes;
    final String token = _formatToken(AuthTool.tokenNotifier.value);

    options.headers.addAll(<String, dynamic>{
      'Authorization': token,
      'version': AppConfig.appVersion,
      'device': AppConfig.device,
    });

    if (encryptPayload) {
      options.headers[AppConfig.apiEncryptHeader] = AppConfig.apiEncryptHeaderValue;
    }

    if (AppConfig.enableLocalProxy && options.uri.host == AppConfig.localProxyHost) {
      options.headers['x-local-proxy'] = AppConfig.localProxyAuthToken;
    }

    if (AppConfig.enableLegacySign) {
      _addSignHeaders(options);
    }

    if (encryptPayload && options.data != null && options.data is! FormData) {
      options.data = <String, dynamic>{
        'data': EncryptTool.encryptAny(options.data),
      };
    }

    handler.next(options);
  }

  /// 统一规范 token 格式，确保带协议前缀。
  String _formatToken(String? rawToken) {
    final String token = (rawToken ?? '').trim();
    if (token.isEmpty) {
      return '';
    }
    if (token.startsWith('${AppConfig.authScheme} ')) {
      return token;
    }
    return '${AppConfig.authScheme} $token';
  }

  /// 为请求添加时间戳签名头。
  void _addSignHeaders(RequestOptions options) {
    final String ts = DateTime.now().millisecondsSinceEpoch.toString();
    final String path = _buildPathWithQuery(options);
    final String sign = EncryptTool.sign(
      appId: AppConfig.appId,
      secret: AppConfig.appSecret,
      timestamp: ts,
      pathWithQuery: path,
    );

    options.headers.addAll(<String, dynamic>{
      'appId': AppConfig.appId,
      'timestamp': ts,
      'sign': sign,
    });
  }

  /// 拼接包含查询参数的签名路径。
  String _buildPathWithQuery(RequestOptions options) {
    final String path = options.path;
    if (options.queryParameters.isEmpty) {
      return path;
    }

    final List<String> segments = <String>[];
    options.queryParameters.forEach((dynamic k, dynamic v) {
      final String key = Uri.encodeQueryComponent('$k');
      final String val = Uri.encodeQueryComponent('$v');
      segments.add('$key=$val');
    });
    return '$path?${segments.join('&')}';
  }

  @override
  /// 响应返回后按需解密 data 字段。
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (response.data is Map<String, dynamic>) {
      final Map<String, dynamic> map = response.data as Map<String, dynamic>;
      final bool encryptPayload = (response.requestOptions.extra[RequestExtra.encrypt] as bool?) ?? AppConfig.enableApiAes;
      final String? encryptHeaderValue = response.headers.value(AppConfig.apiEncryptHeader);
      final bool markedEncrypted = encryptHeaderValue != null &&
          encryptHeaderValue.toLowerCase() == AppConfig.apiEncryptHeaderValue.toLowerCase();
      if ((encryptPayload || markedEncrypted) && map['data'] is String) {
        try {
          map['data'] = EncryptTool.decryptAny(map['data']);
          response.data = map;
        } catch (_) {}
      }
    }
    handler.next(response);
  }
}
