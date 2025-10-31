import 'package:dio/dio.dart';
import 'api_service.dart';

/// 제안 게시물 관련 API 서비스
class SuggestionService {
  final ApiService _apiService = ApiService();

  /// 특정 공모전의 제출물 목록 조회
  ///
  /// [contestId]: 공모전 ID
  /// [sortBy]: 정렬 기준 (createdAt 또는 empathy, 기본값: createdAt)
  /// [page]: 페이지 번호 (기본값: 0)
  /// [size]: 페이지 크기 (기본값: 20)
  ///
  /// 요약 정보만 반환 (title, userId, imagePath, empathy, createdAt)
  Future<List<dynamic>> getContestPosts({
    required int contestId,
    String? sortBy,
    int page = 0,
    int size = 20,
  }) async {
    try {
      // 쿼리 파라미터 구성
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
      }

      final response = await _apiService.get(
        '/v0/contests/$contestId/posts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        print('📦 API 응답 데이터 타입: ${response.data.runtimeType}');
        print('📦 API 응답 데이터: ${response.data}');

        // 응답이 Map인 경우 (페이징된 데이터)
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          // content 배열 추출 (Spring Boot 페이징 응답 구조)
          if (data.containsKey('content')) {
            return data['content'] as List<dynamic>;
          }
          // data 배열 추출
          if (data.containsKey('data')) {
            return data['data'] as List<dynamic>;
          }
          throw Exception('예상치 못한 응답 구조입니다.');
        }

        // 응답이 List인 경우
        return response.data as List<dynamic>;
      } else {
        throw Exception('제출물 목록 조회에 실패했습니다. (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('❌ DioException 발생:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Message: ${e.message}');
      print('Request Data: ${e.requestOptions.data}');
      throw Exception('제출물 목록 조회 중 오류가 발생했습니다.');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      rethrow;
    }
  }
}
