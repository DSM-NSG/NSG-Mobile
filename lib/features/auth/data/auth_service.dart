import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nsg_mobile/core/network/api_client.dart';
import 'package:nsg_mobile/core/network/api_endpoints.dart';
import 'package:nsg_mobile/features/auth/domain/models/user_model.dart';

class AuthService {
  static const _keyUser = 'user';

  /// 로그인 - 성공 시 토큰 및 유저 저장
  static Future<UserModel> login(String accountId, String password) async {
    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.login,
        data: {'account_id': accountId, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;

      await ApiClient.tokenStorage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );

      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _saveUser(user);
      return user;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 400 || status == 401) {
        throw AuthException('아이디 또는 비밀번호가 잘못되었습니다.');
      }
      throw AuthException('네트워크 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  /// 로그인 여부 확인 (토큰 존재 시 true)
  static Future<bool> isLoggedIn() async {
    final token = await ApiClient.tokenStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// 로그아웃 - 토큰 및 유저 정보 삭제
  static Future<void> logout() async {
    await ApiClient.tokenStorage.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  /// 저장된 유저 정보 조회
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyUser);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  static Future<void> cacheUser(UserModel user) async {
    await _saveUser(user);
  }

  static Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
