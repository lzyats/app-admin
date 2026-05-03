class ApiException implements Exception {
  ApiException(
    this.message, {
    this.code,
    this.origin,
    this.rawMessage = '',
  });

  /// 统一错误键（可走 i18n），例如 authNetworkError。
  final String message;
  final int? code;
  final Object? origin;
  /// 后端原始错误消息（若有），用于无法映射时直接展示。
  final String rawMessage;

  /// 返回面向 UI 的消息：优先使用后端原始消息，否则返回错误键。
  String get userMessage => rawMessage.isNotEmpty ? rawMessage : message;

  @override
  /// 返回异常字符串描述，便于日志排查。
  String toString() =>
      'ApiException(code: $code, message: $message, rawMessage: $rawMessage, origin: $origin)';
}
