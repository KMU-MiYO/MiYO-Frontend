// lib/services/imaginary_service.dart
class ImaginaryService {
  static final ImaginaryService _instance = ImaginaryService._internal();
  factory ImaginaryService() => _instance;
  ImaginaryService._internal();

  // DB에서 마커 목록 가져오기
  Future<List<Map<String, dynamic>>> fetchMarkers() async {
    try {
      // 실제 API 호출로 교체해야함
      await Future.delayed(const Duration(milliseconds: 500));

      return [
        {
          'id': 'm1',
          'latitude': 37.602,
          'longitude': 126.977,
          'imageUrl': 'https://picsum.photos/80?2',
          'favoriteCnt': 50,
        },
        {
          'id': 'm2',
          'latitude': 37.604,
          'longitude': 126.982,
          'imageUrl': 'https://picsum.photos/80?2',
          'favoriteCnt': 150,
        },
        {
          'id': 'm3',
          'latitude': 37.600,
          'longitude': 126.974,
          'imageUrl': 'https://picsum.photos/80?3',
          'favoriteCnt': 100,
        },
      ];
    } catch (e) {
      throw Exception('마커 데이터를 불러오는데 실패했습니다: $e');
    }
  }
}
