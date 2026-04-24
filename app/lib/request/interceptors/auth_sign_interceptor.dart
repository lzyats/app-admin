import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../../tools/auth_tool.dart';
import '../../tools/encrypt_tool.dart';
import '../request_extra.dart';

class AuthSignInterceptor extends Interceptor {
  AuthSignInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String token = _formatToken(AuthTool.tokenNotifier.value);

    options.headers.addAll(<String, dynamic>{
      'Authorization': token,
      'version': AppConfig.appVersion,
      'device': AppConfig.device,
    });

    if (AppConfig.enableLocalProxy && options.uri.host == AppConfig.localProxyHost) {
      options.headers['x-local-proxy'] = AppConfig.localProxyAuthToken;
    }

    if (AppConfig.enableLegacySign) {
      _addSignHeaders(options);
    }

    final bool encryptPayload = (options.extra[RequestExtra.encrypt] as bool?) ?? AppConfig.enableApiAes;
    if (encryptPayload && options.data != null && options.data is! FormData) {
      options.data = <String, dynamic>{
        'data': EncryptTool.encryptAny(options.data),
      };
    }

    handler.next(options);
  }

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
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (response.data is Map<String, dynamic>) {
      final Map<String, dynamic> map = response.data as Map<String, dynamic>;
      final bool encryptPayload = (response.requestOptions.extra[RequestExtra.encrypt] as bool?) ?? AppConfig.enableApiAes;
      if (encryptPayload && map['data'] is String) {
        try {
          map['data'] = EncryptTool.decryptAny(map['data']);
          response.data = map;
        } catch (_) {}
      }
    }
    handler.next(response);
  }
}
