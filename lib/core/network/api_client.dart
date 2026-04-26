import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nsg_mobile/core/config/app_env.dart';
import 'package:nsg_mobile/core/network/auth_interceptor.dart';
import 'package:nsg_mobile/core/network/token_storage.dart';

class ApiClient {
  ApiClient._();

  static final tokenStorage = TokenStorage(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  static final Dio dio = _buildDio();

  static Dio _buildDio() {
    final baseUrl = AppEnv.baseUrl.endsWith('/')
        ? AppEnv.baseUrl.substring(0, AppEnv.baseUrl.length - 1)
        : AppEnv.baseUrl;

    final d = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    d.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        onAuthFailed: () {
          // 401 발생 시 토큰 삭제 (AuthInterceptor 내부에서 처리)
        },
      ),
    );

    return d;
  }
}
