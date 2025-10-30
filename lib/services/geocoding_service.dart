// lib/services/geocoding_service.dart
import 'package:dio/dio.dart';
import 'package:miyo/config/config.dart';

/// 주소를 좌표로 변환하는 Geocoding 서비스
class GeocodingService {
  late final Dio _dio;

  GeocodingService() {
    _dio = Dio();
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': naverClientId,
        'X-NCP-APIGW-API-KEY': naverClientSecret,
        'Accept': 'application/json',
      },
    );

    // 인터셉터 추가 (로깅)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🚀 NAVER API REQUEST => ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ NAVER API RESPONSE[${response.statusCode}]');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ NAVER API ERROR[${error.response?.statusCode}]');
          print('MESSAGE: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// 주소를 좌표로 변환
  /// 주소 입력 -> (위도, 경도) 반환
  Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    if (address.trim().isEmpty) {
      return null;
    }

    try {
      print('🔍 주소 검색: $address');

      // 네이버 Geocoding API
      final response = await _dio.get(
        'https://maps.apigw.ntruss.com/map-geocode/v2/geocode',
        queryParameters: {'query': '${address}'},
      );

      print('📡 API 응답 상태 코드: ${response.statusCode}');
      print('📡 API 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final addresses = data['addresses'] as List?;

        print('📍 addresses 필드: $addresses');

        if (addresses != null && addresses.isNotEmpty) {
          final firstResult = addresses[0];
          final lat = double.parse(firstResult['y']);
          final lng = double.parse(firstResult['x']);

          print('✅ 좌표 변환 성공: lat=$lat, lng=$lng');
          return {'latitude': lat, 'longitude': lng};
        } else {
          print('⚠️ 검색 결과 없음');
          return null;
        }
      }

      print('❌ API 호출 실패: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      print('❌ Geocoding DioException: ${e.message}');
      print('❌ 응답 데이터: ${e.response?.data}');
      print('❌ 상태 코드: ${e.response?.statusCode}');
      return null;
    } catch (e) {
      print('❌ 예상치 못한 오류: $e');
      return null;
    }
  }

  /// 좌표를 주소로 변환 (역 Geocoding)
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      // 네이버 Reverse Geocoding API
      final response = await _dio.get(
        'https://maps.apigw.ntruss.com/map-geocode/v2/geocode/gc',
        queryParameters: {
          'coords': '$lng,$lat',
          'output': 'json',
          'orders': 'roadaddr',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final results = data['results'] as List?;

        if (results != null && results.isNotEmpty) {
          final region = results[0]['region'];
          final land = results[0]['land'];

          return '${region['area1']['name']} ${region['area2']['name']} ${region['area3']['name']} ${land['name']}';
        }
      }

      return null;
    } catch (e) {
      print('❌ 역 Geocoding 오류: $e');
      return null;
    }
  }
}
