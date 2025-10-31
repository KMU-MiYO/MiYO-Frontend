import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT 토큰 저장/조회/삭제를 관리하는 서비스
class TokenStorageService {
  static const String _accessTokenKey = 'access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Access Token 저장
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Access Token 조회
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// 모든 토큰 삭제 (로그아웃 시)
  Future<void> deleteAllTokens() async {
    await _storage.delete(key: _accessTokenKey);
  }

  /// Access Token 존재 여부 확인
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
