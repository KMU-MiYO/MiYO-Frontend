// lib/services/imaginary_service.dart
import 'package:miyo/data/services/api_service.dart';

class ImaginaryService {
  static final ImaginaryService _instance = ImaginaryService._internal();
  factory ImaginaryService() => _instance;
  ImaginaryService._internal();

  final ApiService _apiService = ApiService();

  // DB에서 마커 목록 가져오기
  Future<List<Map<String, dynamic>>> fetchMarkers({
    double? latitude,
    double? longitude,
    double? radius,
    String? region,
    List<String>? categories,
    String sortBy = 'empathy',
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'sortBy': sortBy,
        'page': page,
        'size': size,
      };

      // 선택적 파라미터 추가
      if (latitude != null) queryParameters['lat'] = latitude;
      if (longitude != null) queryParameters['lng'] = longitude;
      if (radius != null) queryParameters['radius'] = radius;
      if (region != null) queryParameters['region'] = region;
      if (categories != null && categories.isNotEmpty) {
        queryParameters['categories'] = categories;
      }

      final response = await _apiService.get(
        '/v0/posts/cord',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final List<dynamic> content = response.data['content'] ?? [];

        return content
            .map(
              (item) => {
                'id': item['postId'].toString(),
                'latitude': item['latitude'] ?? 0.0,
                'longitude': item['longitude'] ?? 0.0,
                'imageUrl': item['imageUrl'] ?? '',
                'favoriteCnt': item['empathyCount'] ?? 0,
                'nickname': item['nickname'] ?? '',
                'category': item['category'] ?? '',
                'title': item['title'] ?? '',
                'createdAt': item['createdAt'] ?? '',
              },
            )
            .toList();
      } else {
        throw Exception('마커 데이터를 불러오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('마커 데이터를 불러오는데 실패했습니다: $e');
    }
  }
}
