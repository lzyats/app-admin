import 'dart:async';

import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../request_extra.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);

  final Dio _dio;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final RequestOptions ro = err.requestOptions;
    final bool canRetry = (ro.extra[RequestExtra.retry] as bool?) ?? true;
    if (!canRetry || !_isRetryable(err)) {
      return handler.next(err);
    }

    final int current = (ro.extra[RequestExtra.retryCount] as int?) ?? 0;
    if (current >= AppConfig.retryCount) {
      return handler.next(err);
    }

    ro.extra[RequestExtra.retryCount] = current + 1;

    await Future<void>.delayed(AppConfig.retryDelay * (current + 1));

    try {
      final Response<dynamic> response = await _dio.fetch<dynamic>(ro);
      handler.resolve(response);
    } catch (e) {
      handler.next(e is DioException ? e : err);
    }
  }

  bool _isRetryable(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return true;
    }

    final int? status = e.response?.statusCode;
    return status == 429 || (status != null && status >= 500);
  }
}
