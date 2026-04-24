import 'api_exception.dart';

class ApiResponse<T> {
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

  bool get isSuccess => code == 200;

  static ApiResponse<dynamic> fromJson(Map<String, dynamic> json) {
    return ApiResponse<dynamic>(
      code: (json['code'] is int) ? json['code'] as int : int.tryParse('${json['code']}') ?? -1,
      msg: (json['msg'] ?? '').toString(),
      data: json['data'],
      raw: json,
    );
  }

  T requireData<T>(T Function(dynamic value) mapper) {
    if (!isSuccess) {
      throw ApiException(msg, code: code);
    }
    return mapper(data);
  }
}
