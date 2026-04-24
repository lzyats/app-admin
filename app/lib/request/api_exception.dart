class ApiException implements Exception {
  ApiException(this.message, {this.code, this.origin});

  final String message;
  final int? code;
  final Object? origin;

  @override
  String toString() => 'ApiException(code: $code, message: $message, origin: $origin)';
}
