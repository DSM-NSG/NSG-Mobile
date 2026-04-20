import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nsg_mobile/core/network/auth_interceptor.dart';
import 'package:nsg_mobile/core/network/token_storage.dart';
import 'package:nsg_mobile/router/router.dart';

import 'api_endpoints.dart';

class DioClient {
  final Dio dio;

  DioClient({required Ref ref})
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {Headers.acceptHeader: Headers.jsonContentType},
        ),
      ) {
    final tokenStorage = TokenStorage(const FlutterSecureStorage());

    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        onAuthFailed: () {
          ref.read(goRouterProvider).go('/login');
        },
      ),
    );
  }
}
