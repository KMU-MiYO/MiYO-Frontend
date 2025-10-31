// lib/services/web_map_controller.dart
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:miyo/data/services/post_service.dart';
import 'package:miyo/services/web_marker_generator.dart';
import 'package:miyo/services/geocoding_service.dart';

/// 웹 플랫폼용 지도 컨트롤러
/// Google Maps를 사용하여 지도 관련 비즈니스 로직 처리
class WebMapController {
  final PostService _postService = PostService();
  final WebMarkerGenerator _markerGenerator = WebMarkerGenerator();
  final GeocodingService _geocodingService = GeocodingService();

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Map<String, Map<String, dynamic>> _markerPostData = {};
  LatLng? _currentCenter;
  double _currentZoom = 14.0;

  /// GoogleMapController 설정
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// 내 게시글 불러오기
  Future<List<Map<String, dynamic>>> fetchMyPosts() async {
    try {
      final result = await _postService.getMyPosts();
      final posts = result['content'] as List;

      debugPrint('📦 로드된 게시글 수: ${posts.length}');

      // Map으로 변환
      return posts.map((post) => Map<String, dynamic>.from(post)).toList();
    } catch (e, stackTrace) {
      debugPrint('❌ 게시글 로드 실패: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 지도에 마커 추가
  Future<Set<Marker>> addMarkersToMap(
    List<Map<String, dynamic>> postsData, {
    Function(Map<String, dynamic>)? onMarkerTap,
  }) async {
    if (postsData.isEmpty) {
      debugPrint('⚠️ 게시글 리스트가 비어있습니다');
      return {};
    }

    try {
      debugPrint('📍 웹 마커 생성 시작: ${postsData.length}개');

      // 게시글 데이터를 마커 생성에 필요한 형식으로 변환
      final markerDataList = postsData.map((post) {
        return {
          'id': post['postId'].toString(),
          'imageUrl': post['imageUrl'] ?? '',
          'favoriteCnt': post['favoriteCnt'] ?? 0,
          'latitude': post['latitude'],
          'longitude': post['longitude'],
        };
      }).toList();

      // 배치로 모든 마커 이미지 생성
      final markerImages = await _markerGenerator.generateBatchMarkers(
        markerDataList,
      );

      debugPrint('✅ 마커 이미지 생성 완료: ${markerImages.length}개');

      final newMarkers = <Marker>{};

      for (var post in postsData) {
        try {
          final postId = post['postId'].toString();
          final latitude = post['latitude'] as double?;
          final longitude = post['longitude'] as double?;

          if (latitude == null || longitude == null) {
            debugPrint('⚠️ 위도/경도가 null입니다: postId=$postId');
            continue;
          }

          // 게시글 데이터 저장
          _markerPostData[postId] = post;

          final imageBytes = markerImages[postId];
          if (imageBytes == null) {
            debugPrint('⚠️ 마커 이미지가 없습니다: postId=$postId');

            // 기본 마커 사용
            final marker = Marker(
              markerId: MarkerId('post_$postId'),
              position: LatLng(latitude, longitude),
              onTap: onMarkerTap != null ? () => onMarkerTap(post) : null,
            );
            newMarkers.add(marker);
            continue;
          }

          final marker = Marker(
            markerId: MarkerId('post_$postId'),
            position: LatLng(latitude, longitude),
            icon: BitmapDescriptor.bytes(imageBytes),
            onTap: onMarkerTap != null ? () => onMarkerTap(post) : null,
          );

          newMarkers.add(marker);
        } catch (e) {
          debugPrint('❌ 마커 생성 실패: ${post['postId']} - $e');
        }
      }

      _markers.clear();
      _markers.addAll(newMarkers);

      debugPrint('✅ 총 ${newMarkers.length}개 마커 추가 완료');
      return _markers;
    } catch (e, stackTrace) {
      debugPrint('❌ 마커 추가 중 오류: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 카테고리 필터에 따라 마커 필터링
  Set<Marker> filterMarkersByCategories(
    Set<String> selectedCategories,
  ) {
    if (selectedCategories.isEmpty) {
      return _markers;
    }

    final filteredMarkers = <Marker>{};

    for (var marker in _markers) {
      final postId = marker.markerId.value.replaceFirst('post_', '');
      final postData = _markerPostData[postId];

      if (postData != null) {
        final category = postData['category'] as String;
        if (selectedCategories.contains(category)) {
          filteredMarkers.add(marker);
        }
      }
    }

    return filteredMarkers;
  }

  /// 현재 마커 세트 가져오기
  Set<Marker> get markers => _markers;

  /// 마커 데이터 가져오기
  Map<String, Map<String, dynamic>> get markerPostData => _markerPostData;

  /// 마커 모두 제거
  void clearMarkers() {
    _markers.clear();
    _markerPostData.clear();
  }

  /// 카메라 위치 업데이트 (내부 상태)
  void updateCameraPosition(LatLng center, double zoom) {
    _currentCenter = center;
    _currentZoom = zoom;
  }

  /// 지도 카메라를 특정 위치로 이동
  Future<void> moveCamera(
    double latitude,
    double longitude, {
    double zoom = 14,
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    if (_mapController == null) {
      debugPrint('⚠️ 지도 컨트롤러가 초기화되지 않았습니다');
      return;
    }

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: zoom,
        ),
      ),
    );

    updateCameraPosition(LatLng(latitude, longitude), zoom);
  }

  /// 주소로 검색하여 지도 이동
  Future<bool> searchAndMoveToAddress(String address) async {
    try {
      debugPrint('🔍 주소 검색 시작: $address');

      final coordinates = await _geocodingService.getCoordinatesFromAddress(
        address,
      );

      if (coordinates == null) {
        debugPrint('⚠️ 검색 결과 없음');
        return false;
      }

      final lat = coordinates['latitude']!;
      final lng = coordinates['longitude']!;

      debugPrint('📍 좌표 변환 완료: lat=$lat, lng=$lng');

      await moveCamera(lat, lng, zoom: 15);

      debugPrint('✅ 지도 이동 완료');
      return true;
    } catch (e) {
      debugPrint('❌ 주소 검색 오류: $e');
      return false;
    }
  }

  /// 웹에서 위치 권한 요청 (브라우저 Geolocation API 사용)
  Future<Position?> getCurrentPosition() async {
    try {
      // 웹에서는 geolocator가 브라우저 API를 자동으로 사용
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      debugPrint('위치 가져오기 실패: $e');
      return null;
    }
  }

  void dispose() {
    _markerGenerator.clearCache();
    _markers.clear();
    _markerPostData.clear();
  }
}
