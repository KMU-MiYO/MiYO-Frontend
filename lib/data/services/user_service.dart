import 'package:dio/dio.dart';
import 'api_service.dart';
import '../dummy/user_dummy_data.dart';

/// 유저 관련 API 서비스
class UserService {
  final ApiService _apiService = ApiService();

  /// 현재 로그인한 유저 정보 가져오기
  ///
  /// 개발 모드(isDevelopmentMode = true)일 때: 더미 데이터 반환
  /// 프로덕션 모드일 때: Spring Boot API 호출
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      // 개발 모드: 더미 데이터 사용
      if (ApiService.isDevelopmentMode) {
        // 실제 API 응답 시뮬레이션 (약간의 지연)
        await Future.delayed(const Duration(milliseconds: 500));
        return dummyLoginInfo;
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: GET /api/user/me
      final response = await _apiService.get('/user/me');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('유저 정보를 가져오는데 실패했습니다.');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  /// 특정 유저 정보 가져오기
  ///
  /// [userId]: 조회할 유저 ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      // 개발 모드: 더미 데이터에서 검색
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 300));

        final user = dummyUsers.firstWhere(
          (user) => user['id'] == userId,
          orElse: () => throw Exception('유저를 찾을 수 없습니다.'),
        );
        return user;
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: GET /api/user/{userId}
      final response = await _apiService.get('/user/$userId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('유저 정보를 가져오는데 실패했습니다.');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  /// 유저 정보 업데이트
  ///
  /// [userId]: 업데이트할 유저 ID
  /// [data]: 업데이트할 데이터 (예: {'name': '새이름', 'email': 'new@example.com'})
  Future<Map<String, dynamic>> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      // 개발 모드: 더미 응답 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 500));

        // 업데이트된 데이터를 포함한 응답 반환
        return {
          ...dummyLoginInfo,
          ...data,
          'updatedAt': DateTime.now().toIso8601String(),
        };
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: PUT /api/user/{userId}
      final response = await _apiService.put('/user/$userId', data: data);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('유저 정보 업데이트에 실패했습니다.');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  /// 모든 유저 목록 가져오기 (관리자용)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      // 개발 모드: 더미 데이터 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 400));
        return dummyUsers;
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: GET /api/user/all
      final response = await _apiService.get('/user/all');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('유저 목록을 가져오는데 실패했습니다.');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
