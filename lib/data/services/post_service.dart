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
}