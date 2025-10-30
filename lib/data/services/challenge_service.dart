import 'package:dio/dio.dart';
import 'api_service.dart';
import 'token_storage_service.dart';

// 챌린지 관련 API 서비스
class ChallengeService {
  final ApiService _apiService = ApiService();
  final TokenStorageService _tokenStorage = TokenStorageService();

  // 주간 미션 불러오기
  Future<List<dynamic>> loadWeeklyMissions() async {
    try {
      final response = await _apiService.get('/v0/missions');

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('주간 미션 조회에 실패했습니다. (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('❌ DioException 발생:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');
      print('Request Data: ${e.requestOptions.data}');
      throw Exception('주간 미션 조회 중 오류가 발생했습니다.');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      rethrow;
    }
  }

  /// 전체 챌린지 불러오기
  ///
  /// [categories]: 카테고리 필터 (옵션)
  /// [sortBy]: 정렬 기준 (기본값: 'newest')
  /// [page]: 페이지 번호 (기본값: 0)
  /// [size]: 페이지 크기 (기본값: 20)
  Future<List<dynamic>> loadAllChallenges({
    List<String>? categories,
    String sortBy = 'newest',
    int page = 0,
    int size = 20,
  }) async {
    try {
      // 쿼리 파라미터 구성
      final queryParams = <String, dynamic>{
        'sortBy': sortBy,
        'page': page,
        'size': size,
      };

      if (categories != null && categories.isNotEmpty) {
        queryParams['categories'] = categories.join(',');
      }

      final response = await _apiService.get('/v0/contests');

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('전체 챌린지 조회에 실패했습니다. (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('❌ DioException 발생:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');
      print('Request Data: ${e.requestOptions.data}');
      throw Exception('전체 챌린지 조회 중 오류가 발생했습니다.');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      rethrow;
    }
  }

  // 참여 중인 챌린지 불러오기
  Future<List<dynamic>> loadIngChallenges() async {
    try {
      final response = await _apiService.get('/v0/contests/my');

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception(
          '참여 중인 챌린지 조회에 실패했습니다. (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException 발생:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');
      print('Request Data: ${e.requestOptions.data}');
      throw Exception('참여 중인 챌린지 조회 중 오류가 발생했습니다.');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      rethrow;
    }
  }

  /// ai 이미지 생성
  ///
  /// [prompt]: 이미지 생성 프롬프트
  /// [numberOfImages]: 생성할 이미지 수
  /// [size]:

  Future<Map<String, dynamic>> createImage({
    required String prompt,
    required int numberOfImages,
    required String size,
  }) async {
    try {
      // 개발 모드: 더미 데이터 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 500));

        // 게시글 작성 성공 응답 시뮬레이션
        return {
          "images": ["string"],
          "success": true,
          "errorMessage": "string",
          "prompt": "string",
        };
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: POST /v0/images/generate
      final response = await _apiService.post(
        '/v0/images/generate',
        data: {
          'prompt': prompt,
          'numberOfImages': numberOfImages,
          'size': size,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('이미지 생성에 실패했습니다. (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('❌ DioException 발생:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');
      print('Request Data: ${e.requestOptions.data}');

      if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data?.toString() ?? '잘못된 요청입니다.';
        throw Exception('잘못된 요청: $errorMsg');
      } else if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다. 로그인 후 다시 시도해주세요.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('권한이 없습니다.');
      } else if (e.response?.statusCode == 500) {
        final errorMsg = e.response?.data?.toString() ?? '서버 오류가 발생했습니다.';
        throw Exception('서버 오류: $errorMsg');
      }
      throw Exception(
        '네트워크 오류: ${e.message} (Status: ${e.response?.statusCode})',
      );
    } catch (e) {
      print('❌ Unexpected Error: $e');
      rethrow;
    }
  }

  /// 이미지 기반 AI 이미지 생성
  ///
  /// [imageUrl]: 기반이 되는 이미지 URL
  /// [prompt]: 이미지 생성 프롬프트
  /// [numberOfImages]: 생성할 이미지 수
  /// [size]: 이미지 크기
  Future<Map<String, dynamic>> createImageFromImage({
    required String imageUrl,
    required String prompt,
    required int numberOfImages,
    required String size,
  }) async {
    try {
      // 개발 모드: 더미 데이터 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 500));

        // 이미지 생성 성공 응답 시뮬레이션
        return {
          "images": ["string"],
          "success": true,
          "errorMessage": "string",
          "prompt": "string",
        };
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: POST /v0/images/generate-from-image
      final response = await _apiService.post(
        '/v0/images/generate-from-image',
        data: {
          'imageUrl': imageUrl,
          'prompt': prompt,
          'numberOfImages': numberOfImages,
          'size': size,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('이미지 생성에 실패했습니다. (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('❌ DioException 발생:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');
      print('Request Data: ${e.requestOptions.data}');

      if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data?.toString() ?? '잘못된 요청입니다.';
        throw Exception('잘못된 요청: $errorMsg');
      } else if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다. 로그인 후 다시 시도해주세요.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('권한이 없습니다.');
      } else if (e.response?.statusCode == 500) {
        final errorMsg = e.response?.data?.toString() ?? '서버 오류가 발생했습니다.';
        throw Exception('서버 오류: $errorMsg');
      }
      throw Exception(
        '네트워크 오류: ${e.message} (Status: ${e.response?.statusCode})',
      );
    } catch (e) {
      print('❌ Unexpected Error: $e');
      rethrow;
    }
  }

  /// 비트맵 이미지 업로드
  ///
  Future<Map<String, dynamic>> bitmapImageUpload({
    required String base64Image,
    required String contentType,
  }) async {
    try {
      // 개발 모드: 더미 데이터 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 500));

        // 이미지 생성 성공 응답 시뮬레이션
        return {"base64Image": base64Image, "contentType": contentType};
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: POST /v0/images/upload
      final response = await _apiService.post(
        '/v0/images/upload',
        data: {'base64Image': base64Image, 'contentType': contentType},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('이미지 생성에 실패했습니다. (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('❌ DioException 발생:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');
      print('Request Data: ${e.requestOptions.data}');

      if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data?.toString() ?? '잘못된 요청입니다.';
        throw Exception('잘못된 요청: $errorMsg');
      } else if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다. 로그인 후 다시 시도해주세요.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('권한이 없습니다.');
      } else if (e.response?.statusCode == 500) {
        final errorMsg = e.response?.data?.toString() ?? '서버 오류가 발생했습니다.';
        throw Exception('서버 오류: $errorMsg');
      }
      throw Exception(
        '네트워크 오류: ${e.message} (Status: ${e.response?.statusCode})',
      );
    } catch (e) {
      print('❌ Unexpected Error: $e');
      rethrow;
    }
  }

  /// contestId로 챌린지 상세 정보 조회
  ///
  /// [contestId]: 조회할 챌린지 ID
  Future<Map<String, dynamic>> getContestById({required int contestId}) async {
    try {
      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: GET /v0/contests/{contestId}
      final response = await _apiService.get('/v0/contests/$contestId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        print('✅ getContestById API 응답:');
        print('  - contestId: ${data['contestId']}');
        print('  - title: ${data['title']}');
        print('  - 전체 데이터: $data');
        return data;
      } else {
        throw Exception('챌린지 조회에 실패했습니다. (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('❌ DioException 발생:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');

      if (e.response?.statusCode == 404) {
        throw Exception('챌린지를 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다. 로그인 후 다시 시도해주세요.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('권한이 없습니다.');
      } else if (e.response?.statusCode == 500) {
        final errorMsg = e.response?.data?.toString() ?? '서버 오류가 발생했습니다.';
        throw Exception('서버 오류: $errorMsg');
      }
      throw Exception(
        '네트워크 오류: ${e.message} (Status: ${e.response?.statusCode})',
      );
    } catch (e) {
      print('❌ Unexpected Error: $e');
      rethrow;
    }
  }
}
