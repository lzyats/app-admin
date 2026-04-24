import 'package:myapp/request/api_exception.dart';

class ApiResponse<T> {
  /// 创建统一接口响应对象。
  ApiResponse({
    required this.code,
    required this.msg,
    required this.data,
    this.raw = const {},
  });

  final int code;
  final String msg;
  final T? data;
  final Map<String, dynamic> raw;

  /// 判断业务状态码是否成功。
  bool get isSuccess => code == 200;

  /// 从 JSON 构建统一响应对象。
  static ApiResponse<dynamic> fromJson(Map<String, dynamic> json) {
    return ApiResponse<dynamic>(
      code: (json['code'] is int) ? json['code'] as int : int.tryParse('${json['code']}') ?? -1,
      msg: (json['msg'] ?? '').toString(),
      data: json['data'],
      raw: json,
    );
  }

  /// 强制获取 data 字段并映射为目标类型。
  T requireData<T>(T Function(dynamic value) mapper) {
    if (!isSuccess) {
      throw ApiException(msg, code: code);
    }
    return mapper(data);
  }
}
