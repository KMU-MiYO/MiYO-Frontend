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

  /// 회원 가입
  ///
  /// [nickname]: 닉네임
  /// [userId]: 사용자 아이디 (중복 불가)
  /// [email]: 이메일 주소 (중복 불가)
  /// [password]: 비밀번호
  /// [profileImagePath]: 프로필 이미지 파일 경로 (선택사항)
  Future<Map<String, dynamic>> signup({
    required String nickname,
    required String userId,
    required String email,
    required String password,
    String? profileImagePath,
  }) async {
    try {
      // 개발 모드: 더미 응답 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 800));

        // 회원가입 성공 응답 시뮬레이션
        return {
          'success': true,
          'message': '회원가입이 완료되었습니다.',
          'user': {
            'id': userId,
            'nickname': nickname,
            'email': email,
            'profileImage': profileImagePath != null
                ? 'https://example.com/profile/$userId.jpg'
                : null,
            'createdAt': DateTime.now().toIso8601String(),
          }
        };
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: POST /users/signup
      final formData = FormData.fromMap({
        'nickname': nickname,
        'userId': userId,
        'email': email,
        'password': password,
        if (profileImagePath != null)
          'profileImage': await MultipartFile.fromFile(
            profileImagePath,
            filename: profileImagePath.split('/').last,
          ),
      });

      final response = await _apiService.postMultipart('/users/signup', formData);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('회원가입에 실패했습니다.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('잘못된 요청입니다. (중복된 아이디/이메일 등)');
      } else if (e.response?.statusCode == 500) {
        throw Exception('서버 오류가 발생했습니다.');
      }
      print('DioException: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  // 로그인
  /// [userId]: 사용자 아이디 (중복 불가)
  /// [password]: 비밀번호
  Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
  }) async {
    try {
      // 개발 모드: 더미 응답 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 600));

        // 로그인 성공 응답 시뮬레이션
        if (userId == dummyLoginInfo['id'] && password == 'password123') {
          return {
            'success': true,
            'message': '로그인에 성공했습니다.',
            'user': dummyLoginInfo,
          };
        } else {
          throw Exception('아이디 또는 비밀번호가 올바르지 않습니다.');
        }
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: POST /users/login
      final response = await _apiService.post('/users/login', data: {
        'userId': userId,
        'password': password,
      });

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('로그인에 실패했습니다.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('아이디 또는 비밀번호가 올바르지 않습니다.');
      }
      print('DioException: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  // 이메일 인증코드 요청
  /// [email]: 인증코드를 받을 이메일 주소
  Future<void> requestEmailVerificationCode(String email) async {
    try {
      // 개발 모드: 더미 응답 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 400));
        return;
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: POST /users/request-email-verification
      final response = await _apiService.post('/users/email-verification-request', data: {
        'email': email,
      });

      if (response.statusCode != 200) {
        throw Exception('이메일 인증코드 요청에 실패했습니다.');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  // 인증코드 확인
  /// [email]: 인증코드를 받을 이메일 주소
  /// [code]: 이메일로 받은 인증코드
  Future<bool> verifyEmailCode(String email, String code) async {
    try {
      // 개발 모드: 더미 응답 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 400));
        // 더미 코드: "123456"
        return code == '123456';
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: POST /users/verify-email-code
      final response = await _apiService.post('/users/email-verification-confirm', data: {
        'email': email,
        'code': code,
      });

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['isValid'] as bool;
      } else {
        throw Exception('이메일 인증코드 확인에 실패했습니다.');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
