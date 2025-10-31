import 'package:dio/dio.dart';
import 'api_service.dart';
import 'token_storage_service.dart';

/// 댓글 관련 API 서비스
class CommentService {
  final ApiService _apiService = ApiService();
  final TokenStorageService _tokenStorage = TokenStorageService();

  /// 댓글 목록 가져오기
  ///
  Future<Map<String, dynamic>> getComments({
    required int parentPostId,
    required int page,
    required int size,
  }) async {
    try {
      final response = await _apiService.get(
        '/v0/comments',
        queryParameters: {
          'parentPostId': parentPostId,
          'page': page,
          'size': size,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('댓글 목록을 가져오는데 실패했습니다.');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  /// 댓글(그냥 제안글) 작성하기
  ///
  Future<Map<String, dynamic>> writeComment({
    required int parentPostId,
    required String content,
  }) async {
    try {
      print('📤 댓글 작성 요청: parentPostId=$parentPostId, content=$content');
      final response = await _apiService.post(
        '/v0/comments',
        data: {'parentPostId': parentPostId, 'content': content},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('댓글 작성에 실패했습니다.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('잘못된 요청입니다.');
      } else if (e.response?.statusCode == 409) {
        // 서버에서 보낸 에러 메시지가 있으면 사용, 없으면 기본 메시지
        final errorMessage = e.response?.data?.toString();
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

  /// 댓글(챌린지) 작성하기
  ///
  Future<Map<String, dynamic>> writeChallengeComment({
    required int postId,
    required String content,
  }) async {
    try {
      final response = await _apiService.post(
        '/v0/contests/posts/$postId/comments',
        data: {'content': content},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('댓글 작성에 실패했습니다.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('잘못된 요청입니다.');
      } else if (e.response?.statusCode == 409) {
        // 서버에서 보낸 에러 메시지가 있으면 사용, 없으면 기본 메시지
        final errorMessage = e.response?.data?.toString();
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 500) {
        throw Exception('서버 오류가 발생했습니다.');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
