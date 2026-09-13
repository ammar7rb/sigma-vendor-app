import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends InterceptorsWrapper {
  int maxCharactersPerLine = 200;

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (kDebugMode) {
      print("--> ${options.method} ${options.path}");
    }
    if (kDebugMode) {
      // Authentication and support headers must never be logged.
    }
    if (kDebugMode) {
      print("<-- END HTTP");
    }

    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (kDebugMode) {
      print(
        "<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}");
    }

    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      print("ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}");
    }
    return super.onError(err, handler);
  }
}
