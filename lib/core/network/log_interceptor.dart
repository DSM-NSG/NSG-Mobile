import 'dart:developer';

import 'package:dio/dio.dart';

class NsgLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log(
      '→ ${options.method} ${options.baseUrl}${options.path}',
      name: 'Dio',
    );
    if (options.queryParameters.isNotEmpty) {
      log('  query: ${options.queryParameters}', name: 'Dio');
    }
    if (options.data != null) {
      log('  body: ${options.data}', name: 'Dio');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      '← ${response.statusCode} ${response.requestOptions.path}',
      name: 'Dio',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode ?? 'N/A';
    log(
      '✗ $status ${err.requestOptions.path}: ${err.message}',
      name: 'Dio',
    );
    if (err.response?.data != null) {
      log('  response: ${err.response?.data}', name: 'Dio');
    }
    handler.next(err);
  }
}
