import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends InterceptorsWrapper {
  int maxCharactersPerLine = 200;

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (kDebugMode) {
      // Allowlist metadata only: URLs, headers and bodies can contain secrets.
      debugPrint('--> ${options.method} HTTP');
    }

    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (kDebugMode) {
      debugPrint(
        '<-- ${response.statusCode} ${response.requestOptions.method} HTTP');
    }

    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      debugPrint(
        'ERROR[${err.response?.statusCode}] ${err.requestOptions.method} ${err.type.name}');
    }
    return super.onError(err, handler);
  }
}
