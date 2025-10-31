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
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
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
      // 네이버 Geocoding API
      final response = await _dio.get(
        'https://maps.apigw.ntruss.com/map-geocode/v2/geocode',
        queryParameters: {'query': '${address}'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final addresses = data['addresses'] as List?;

        if (addresses != null && addresses.isNotEmpty) {
          final firstResult = addresses[0];
          final lat = double.parse(firstResult['y']);
          final lng = double.parse(firstResult['x']);

          return {'latitude': lat, 'longitude': lng};
        } else {
          return null;
        }
      }
      return null;
    } on DioException catch (e) {
      return null;
    } catch (e) {
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
      return null;
    }
  }
}
