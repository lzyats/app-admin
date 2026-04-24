import 'backend_profile.dart';

class AppConfig {
  const AppConfig._();

  static const String appName = 'Go API App';
  static const BackendProfile backendProfile = BackendProfile.ruoyi;

  static const String localProxyHost = '127.0.0.1';
  static const int localProxyPort = 19080;

  static const String requestHost = 'http://127.0.0.1:8080';
  static const String requestBasePath = '/prod-api';
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
  static const bool enableApiAes = false;
  static const String aesKey = '0123456789abcdef0123456789abcdef';
  static const String aesIv = '0123456789abcdef';

  static const bool enableLocalProxy = false;
  static const String localProxyAuthToken = 'replace-local-proxy-token';
  static const String authScheme = 'Bearer';
}
