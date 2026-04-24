class ApiException implements Exception {
  ApiException(this.message, {this.code, this.origin});

  final String message;
  final int? code;
  final Object? origin;

  @override
  /// 返回异常字符串描述，便于日志排查。
  String toString() => 'ApiException(code: $code, message: $message, origin: $origin)';
}
