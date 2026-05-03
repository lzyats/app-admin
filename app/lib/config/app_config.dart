import 'package:flutter/foundation.dart';
import 'package:myapp/config/backend_profile.dart';

class AppConfig {
  const AppConfig._();

  static const String appName = 'Go API App';
  static const BackendProfile backendProfile = BackendProfile.ruoyi;

  static const String localProxyHost = '127.0.0.1';
  static const int localProxyPort = 19080;

  static const List<RequestHost> requestHost = <RequestHost>[
    RequestHost(
      name: '国内线路一(推荐)',
      httpUrl: 'http://192.168.140.1:8080',
      wsUrl: 'ws://43.139.165.6:7777',
    ),
    RequestHost(
      name: '国内线路二(备用)',
      httpUrl: 'http://192.168.0.2:8080',
      wsUrl: 'ws://43.139.165.6:7777',
    ),
    RequestHost(
      name: '国际线路一(香港)',
      httpUrl: 'http://192.168.0.3:8080',
      wsUrl: 'ws://110.42.56.223:7777',
    ),
    RequestHost(
      name: '高防线路(访问极慢)',
      httpUrl: 'https://noos.51dai.cn/api',
      wsUrl: 'wss://noos.51dai.cn/ws',
    ),
    RequestHost(
      name: '内部线路(勿选)',
      httpUrl: 'http://192.168.140.1:8080',
      wsUrl: 'ws://43.139.165.6:7777',
    ),
  ];
  /// 获取默认请求线路，优先使用第一条配置。
  static RequestHost get defaultRequestHost {
    if (requestHost.isNotEmpty) {
      return requestHost[0];
    }
    return const RequestHost(
      name: '默认线路',
      httpUrl: 'http://127.0.0.1:8080',
      wsUrl: 'ws://127.0.0.1:8080',
    );
  }

  /// 直连 RuoYi 后端时不需要前缀；若后续走网关反向代理可改为 '/prod-api'。
  static const String requestBasePath = '';
  static const Duration connectTimeout = Duration(seconds: 12);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);
  static const int retryCount = 2;
  static const Duration retryDelay = Duration(milliseconds: 400);

  static const String appId = 'goapi-app';
  static const String appSecret = 'replace-with-server-secret';
  static const String appVersion = '0.1.0';
  static const String device = 'flutter';

  static const bool enableLegacySign = false;
  static const bool enableApiAes = true;
  static const String apiEncryptHeader = 'X-Api-Encrypt';
  static const String apiEncryptHeaderValue = '1';
  static const String aesKey = '0123456789abcdef0123456789abcdef';
  static const String aesIv = '0123456789abcdef';
  static const String lineQrCryptoSeed = 'replace-line-qr-seed';

  static const bool enableLocalProxyOnNative = true;
  /// Web 端不启用本地代理，避免浏览器跨域与混合内容限制导致请求失败。
  static bool get enableLocalProxy => !kIsWeb && enableLocalProxyOnNative;
  static const String localProxyAuthToken = 'replace-local-proxy-token';
  static const String authScheme = 'Bearer';
}

class RequestHost {
  const RequestHost({
    required this.name,
    required this.httpUrl,
    required this.wsUrl,
  });

  final String name;
  final String httpUrl;
  final String wsUrl;

  /// 将线路对象转换为可序列化的 JSON Map。
  Map<String, String> toJson() {
    return <String, String>{
      'name': name,
      'httpUrl': httpUrl,
      'wsUrl': wsUrl,
    };
  }

  /// 从 JSON 反序列化线路对象，字段不完整时返回 null。
  static RequestHost? fromJson(Map<String, dynamic> json) {
    final String name = (json['name'] ?? '').toString().trim();
    final String httpUrl = (json['httpUrl'] ?? '').toString().trim();
    final String wsUrl = (json['wsUrl'] ?? '').toString().trim();

    if (name.isEmpty || httpUrl.isEmpty || wsUrl.isEmpty) {
      return null;
    }

    return RequestHost(name: name, httpUrl: httpUrl, wsUrl: wsUrl);
  }
}

