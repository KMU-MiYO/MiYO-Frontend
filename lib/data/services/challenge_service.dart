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

  // 전체 챌린지 불러오기
  Future<List<dynamic>> loadAllChallenges() async {
    try {
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
}
