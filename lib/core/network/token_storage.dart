import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _nsgAccessToken = 'access_token';
  static const _nsgRefreshToken = 'refresh_token';

  final FlutterSecureStorage _storage;

  const TokenStorage(this._storage);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _nsgAccessToken, value: accessToken);
    await _storage.write(key: _nsgRefreshToken, value: refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: _nsgAccessToken);

  Future<String?> readRefreshToken() => _storage.read(key: _nsgRefreshToken);

  Future<void> clear() async {
    await _storage.delete(key: _nsgAccessToken);
    await _storage.delete(key: _nsgRefreshToken);
  }
}
