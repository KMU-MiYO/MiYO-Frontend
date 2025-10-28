import 'package:dio/dio.dart';
import 'api_service.dart';
import 'token_storage_service.dart';
import '../dummy/user_dummy_data.dart';

/// 유저 관련 API 서비스
class UserService {
  final ApiService _apiService = ApiService();
  final TokenStorageService _tokenStorage = TokenStorageService();

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
        // 응답이 String인 경우 처리
        if (response.data is String) {
          return {
            'success': true,
            'message': response.data.toString(),
            'user': {
              'id': userId,
              'nickname': nickname,
              'email': email,
            }
          };
        }
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('회원가입에 실패했습니다.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('잘못된 요청입니다.');
      } else if (e.response?.statusCode == 409) {
        // 서버에서 보낸 에러 메시지가 있으면 사용, 없으면 기본 메시지
        final errorMessage = e.response?.data?.toString() ?? '이미 사용 중인 아이디 또는 이메일입니다.';
        throw Exception(errorMessage);
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
        final data = response.data as Map<String, dynamic>;

        // JWT 토큰 저장
        if (data.containsKey('accessToken')) {
          await _tokenStorage.saveAccessToken(data['accessToken']);
          print('✅ Access token saved');
        }

        // // Refresh 토큰이 있으면 저장
        // if (data.containsKey('refreshToken')) {
        //   await _tokenStorage.saveRefreshToken(data['refreshToken']);
        //   print('✅ Refresh token saved');
        // }

        return data;
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

  // 아이디 찾기
  /// [email]: 가입된 이메일 주소
  Future<void> findUserId(String email) async {
    try {
      // 개발 모드: 더미 응답 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: POST /users/find-id
      final response = await _apiService.post('/users/find-id', data: {
        'email': email,
      });

      if (response.statusCode != 200) {
        throw Exception('아이디 찾기 요청에 실패했습니다.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('해당 이메일로 가입된 사용자를 찾을 수 없습니다.');
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

  // 비밀번호 재설정 링크
  /// [email]: 가입된 이메일 주소
  Future<void> passwordResetRequest(String email) async {
    try {
      // 개발 모드: 더미 응답 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: POST /users/password-reset-request
      final response = await _apiService.post('/users/password-reset-request', data: {
        'email': email,
      });

      if (response.statusCode != 200) {
        throw Exception('비밀번호 찾기 요청에 실패했습니다.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('해당 이메일로 가입된 사용자를 찾을 수 없습니다.');
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

  // 비밀번호 재설정 확인
  /// [token]: 이메일로 받은 비밀번호 재설정 토큰
  /// [newPassword]: 새로운 비밀번호
  Future<void> passwordResetConfirm({
    required String token,
    required String newPassword,
  }) async {
    try {
      // 개발 모드: 더미 응답 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: POST /users/password-reset-confirm?token={token}
      final response = await _apiService.dio.post(
        '/users/password-reset-confirm',
        queryParameters: {'token': token},
        data: {'newPassword': newPassword},
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode != 200) {
        throw Exception('비밀번호 재설정에 실패했습니다.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final errorMessage = e.response?.data?.toString() ?? '유효하지 않거나 만료된 토큰입니다.';
        throw Exception(errorMessage);
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
      final response = await _apiService.post(
        '/users/email-verification-confirm',
        data: {'email': email, 'code': code},
        responseType: ResponseType.plain, // plain text 응답 처리
      );

      if (response.statusCode == 200) {
        // API는 성공 시 plain string
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        // 400 응답은 plain text로 에러 메시지 반환
        final errorMessage = e.response?.data?.toString() ?? '유효하지 않거나 만료된 인증코드입니다.';
        throw Exception(errorMessage);
      }
      print('DioException: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  /// 로그아웃
  /// 저장된 토큰을 삭제합니다.
  Future<void> logout() async {
    try {
      await _tokenStorage.deleteAllTokens();
      print('✅ Logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }

  /// 디버깅: 현재 저장된 토큰 확인
  Future<void> debugPrintTokens() async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      // final refreshToken = await _tokenStorage.getRefreshToken();

      print('=== 저장된 토큰 디버깅 ===');
      if (accessToken != null && accessToken.isNotEmpty) {
        print('✅ Access Token: ${accessToken.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...');
      } else {
        print('❌ Access Token: 없음');
      }

      // 리프레시 토큰은 없어서 우선 주석처리
      // if (refreshToken != null && refreshToken.isNotEmpty) {
      //   print('✅ Refresh Token: ${refreshToken.substring(0, refreshToken.length > 20 ? 20 : refreshToken.length)}...');
      // } else {
      //   print('❌ Refresh Token: 없음');
      // }
      // print('========================');
    } catch (e) {
      print('Error checking tokens: $e');
    }
  }

  /// 토큰 존재 여부 확인
  Future<bool> isLoggedIn() async {
    return await _tokenStorage.hasAccessToken();
  }
}
