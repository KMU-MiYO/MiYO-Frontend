import 'package:dio/dio.dart';
import 'api_service.dart';
import 'token_storage_service.dart';

/// 게시글 관련 API 서비스
class PostService {
  final ApiService _apiService = ApiService();
  final TokenStorageService _tokenStorage = TokenStorageService();

  /// 게시글 작성
  ///
  /// [imagePath]: 이미지 파일 경로
  /// [latitude]: 위도 (-90 ~ 90)
  /// [longitude]: 경도 (-180 ~ 180)
  /// [category]: 카테고리 (NATURE 등)
  /// [title]: 게시글 제목
  /// [content]: 게시글 내용
  Future<Map<String, dynamic>> createPost({
    required String imagePath,
    required double latitude,
    required double longitude,
    required String category,
    required String title,
    required String content,
  }) async {
    try {
      // 개발 모드: 더미 데이터 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 500));

        // 게시글 작성 성공 응답 시뮬레이션
        return {
          'postId': 1,
          'userId': 'testuser',
          'userNickname': '테스트유저',
          'parentPostId': 0,
          'imagePath': 'https://example.com/images/1.jpg',
          'latitude': latitude,
          'longitude': longitude,
          'category': category,
          'title': title,
          'content': content,
          'createdAt': DateTime.now().toIso8601String(),
        };
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: POST /v0/posts
      final response = await _apiService.post(
        '/v0/posts',
        data: {
          'imagePath': imagePath,
          'latitude': latitude,
          'longitude': longitude,
          'category': category,
          'title': title,
          'content': content,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('게시글 작성에 실패했습니다. (Status: ${response.statusCode})');
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
      throw Exception('네트워크 오류: ${e.message} (Status: ${e.response?.statusCode})');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      rethrow;
    }
  }

  /// 내 게시글 목록 조회
  ///
  /// [categories]: 카테고리 필터 (옵션)
  /// [sortBy]: 정렬 기준 (기본값: 'empathy')
  /// [page]: 페이지 번호 (기본값: 0)
  /// [size]: 페이지 크기 (기본값: 20)
  Future<Map<String, dynamic>> getMyPosts({
    List<String>? categories,
    String sortBy = 'empathy',
    int page = 0,
    int size = 20,
  }) async {
    try {
      // 개발 모드: 더미 데이터 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 500));

        return {
          "content": [
            {
              "postId": 1,
              "nickname": "테스트유저",
              "category": "NATURE",
              "title": "테스트 게시글 1",
              "imagePath": "https://example.com/images/1.jpg",
              "empathyCount": 10,
              "createdAt": DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
              "latitude": 37.5665,
              "longitude": 126.9780
            },
            {
              "postId": 2,
              "nickname": "테스트유저",
              "category": "CULTURE",
              "title": "테스트 게시글 2",
              "imagePath": "https://example.com/images/2.jpg",
              "empathyCount": 5,
              "createdAt": DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
              "latitude": 37.5665,
              "longitude": 126.9780
            }
          ],
          "page": page,
          "size": size,
          "totalElements": 2,
          "totalPages": 1
        };
      }

      // 쿼리 파라미터 생성
      final queryParameters = <String, dynamic>{
        'sortBy': sortBy,
        'page': page,
        'size': size,
      };

      if (categories != null && categories.isNotEmpty) {
        queryParameters['categories'] = categories;
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: GET /v0/posts/my
      final response = await _apiService.get(
        '/v0/posts/my',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('게시글 조회에 실패했습니다. (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('❌ DioException 발생:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');

      if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다. 로그인 후 다시 시도해주세요.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('권한이 없습니다.');
      } else if (e.response?.statusCode == 500) {
        final errorMsg = e.response?.data?.toString() ?? '서버 오류가 발생했습니다.';
        throw Exception('서버 오류: $errorMsg');
      }
      throw Exception('네트워크 오류: ${e.message} (Status: ${e.response?.statusCode})');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      rethrow;
    }
  }

  /// 게시글 공감 추가/취소
  ///
  /// [postId]: 게시글 ID
  /// 반환값: { "isAdded": true/false, "message": "string" }
  Future<Map<String, dynamic>> toggleEmpathy({
    required int postId,
  }) async {
    try {
      // 개발 모드: 더미 데이터 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 300));

        return {
          "isAdded": true,
          "message": "공감이 추가되었습니다."
        };
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: POST /v0/empathy?postId={postId}
      final response = await _apiService.post(
        '/v0/empathy?postId=$postId',
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('공감 처리에 실패했습니다. (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('❌ DioException 발생:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');

      if (e.response?.statusCode == 404) {
        throw Exception('게시글을 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다. 로그인 후 다시 시도해주세요.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('권한이 없습니다.');
      } else if (e.response?.statusCode == 500) {
        final errorMsg = e.response?.data?.toString() ?? '서버 오류가 발생했습니다.';
        throw Exception('서버 오류: $errorMsg');
      }
      throw Exception('네트워크 오류: ${e.message} (Status: ${e.response?.statusCode})');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      rethrow;
    }
  }

  /// id 게시글 목록 조회
  ///
  /// [postId]: 조회할 게시글 ID
  Future<Map<String, dynamic>> getPostById({
    required int postId,
  }) async {
    try {
      // 개발 모드: 더미 데이터 반환
      if (ApiService.isDevelopmentMode) {
        await Future.delayed(const Duration(milliseconds: 500));

        return {
          "postId": postId,
          "nickname": "테스트유저",
          "parentPostId": 0,
          "imagePath": "https://example.com/images/1.jpg",
          "latitude": 37.5665,
          "longitude": 126.9780,
          "category": "NATURE",
          "title": "테스트 게시글",
          "content": "이것은 테스트 게시글 내용입니다.",
          "createdAt": DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          "empathyCount": 10,
          "isEmpathized": false,
          "comments": [
            {
              "postId": 101,
              "userId": "user1",
              "userNickname": "댓글유저1",
              "parentPostId": postId,
              "content": "좋은 글이네요!",
              "createdAt": DateTime.now().subtract(Duration(hours: 5)).toIso8601String(),
              "empathyCount": 3,
              "isEmpathized": false
            },
            {
              "postId": 102,
              "userId": "user2",
              "userNickname": "댓글유저2",
              "parentPostId": postId,
              "content": "동의합니다.",
              "createdAt": DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
              "empathyCount": 1,
              "isEmpathized": true
            }
          ]
        };
      }

      // 프로덕션 모드: 실제 API 호출
      // Spring Boot 엔드포인트: GET /v0/posts/id
      final response = await _apiService.get(
        '/v0/posts/id',
        queryParameters: {
          'postId': postId,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('게시글 조회에 실패했습니다. (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('❌ DioException 발생:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');

      if (e.response?.statusCode == 404) {
        throw Exception('게시글을 찾을 수 없습니다.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('인증이 필요합니다. 로그인 후 다시 시도해주세요.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('권한이 없습니다.');
      } else if (e.response?.statusCode == 500) {
        final errorMsg = e.response?.data?.toString() ?? '서버 오류가 발생했습니다.';
        throw Exception('서버 오류: $errorMsg');
      }
      throw Exception('네트워크 오류: ${e.message} (Status: ${e.response?.statusCode})');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      rethrow;
    }
  }
}