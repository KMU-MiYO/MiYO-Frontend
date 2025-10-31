import 'package:dio/dio.dart';
import 'api_service.dart';

/// 리워드 관련 API 서비스
class RewardService {
  final ApiService _apiService = ApiService();

  /// 리워드 조회
  ///
  Future<Map<String, dynamic>> getReward() async {
    try {
      final response = await _apiService.get('/v0/reward/my');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('리워드 정보를 가져오는데 실패했습니다.');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  /// 리워드 업데이트
  /// [userId]: 사용자 아이디
  /// [v]: 리워드 점수
  Future<Map<String, dynamic>> rewardUpdate({
    required String userId,
    required String v,
  }) async {
    try {
      final response = await _apiService.post(
        '/v0/reward/update/$userId',
        data: {'userId': userId, 'v': v},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        return data;
      } else {
        throw Exception('리워드 업데이트에 실패했습니다.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('요청이 올바르지 않습니다.');
      }
      print('DioException: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
