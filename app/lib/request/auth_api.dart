import 'package:myapp/request/api_exception.dart';
import 'package:myapp/request/api_response.dart';
import 'package:myapp/request/http_client.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

/// 认证模块接口封装，统一处理登录/注册/验证码/忘记密码。
class AuthApi {
  AuthApi._();

  /// 获取验证码数据。
  static Future<CaptchaPayload> captcha() async {
    final ApiResponse<dynamic> res =
        await HttpClient.get(RuoYiEndpoints.captchaImage);
    final Map<String, dynamic> json = _asMap(res.data);
    return CaptchaPayload(
      captchaEnabled: json['captchaEnabled'] == true,
      uuid: (json['uuid'] ?? '').toString(),
      imageBase64: (json['img'] ?? '').toString(),
    );
  }

  /// 执行登录并返回 token。
  static Future<String> login({
    required String username,
    required String password,
    String code = '',
    String uuid = '',
  }) async {
    final ApiResponse<dynamic> res = await HttpClient.post(
      RuoYiEndpoints.login,
      data: <String, dynamic>{
        'username': username,
        'password': password,
        'code': code,
        'uuid': uuid,
      },
    );
    final String token = (res.raw['token'] ?? '').toString();
    if (token.isEmpty) {
      throw ApiException('authTokenMissing');
    }
    return token;
  }

  /// 执行注册。
  static Future<void> register({
    required String username,
    required String password,
    String code = '',
    String uuid = '',
  }) async {
    await HttpClient.post(
      RuoYiEndpoints.register,
      data: <String, dynamic>{
        'username': username,
        'password': password,
        'code': code,
        'uuid': uuid,
      },
    );
  }

  /// 执行忘记密码（用户名 + 邮箱校验后重置密码）。
  static Future<void> forgotPassword({
    required String username,
    required String email,
    required String newPassword,
    String code = '',
    String uuid = '',
  }) async {
    await HttpClient.post(
      RuoYiEndpoints.forgotPassword,
      data: <String, dynamic>{
        'username': username,
        'email': email,
        'newPassword': newPassword,
        'code': code,
        'uuid': uuid,
      },
    );
  }

  /// 将动态对象安全转换为 Map。
  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return <String, dynamic>{};
  }
}

/// 验证码接口返回结构。
class CaptchaPayload {
  const CaptchaPayload({
    required this.captchaEnabled,
    required this.uuid,
    required this.imageBase64,
  });

  final bool captchaEnabled;
  final String uuid;
  final String imageBase64;
}


