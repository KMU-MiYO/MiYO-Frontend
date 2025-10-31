// lib/services/web_imaginary_map_controller.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:miyo/services/imaginary_service.dart';
import 'package:miyo/services/web_marker_generator.dart';
import 'package:miyo/services/geocoding_service.dart';

/// 웹 플랫폼용 상상지도 컨트롤러
/// Google Maps를 사용하여 지도 관련 비즈니스 로직 처리
class WebImaginaryMapController {
  final ImaginaryService _service = ImaginaryService();
  final WebMarkerGenerator _markerGenerator = WebMarkerGenerator();
  final GeocodingService _geocodingService = GeocodingService();

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _currentCenter;
  double _currentZoom = 14.0;

  /// GoogleMapController 설정
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// zoom 레벨에 따라 검색 반경(미터) 계산
  double calculateRadiusFromZoom(double zoom) {
    if (zoom >= 15) return 500;
    if (zoom >= 14) return 1000;
    if (zoom >= 13) return 2000;
    if (zoom >= 12) return 4000;
    if (zoom >= 11) return 8000;
    return 10000;
  }

  /// 현재 카메라 위치 기반으로 마커 데이터 가져오기
  Future<List<Map<String, dynamic>>> fetchMarkersForCurrentView({
    List<String>? categories,
    String? region,
  }) async {
    if (_currentCenter == null) {
      debugPrint('⚠️ 현재 카메라 위치가 없습니다');
      return [];
    }

    try {
      final radius = calculateRadiusFromZoom(_currentZoom);

      debugPrint(
        '📍 마커 조회: lat=${_currentCenter!.latitude}, lng=${_currentCenter!.longitude}, zoom=$_currentZoom, radius=$radius',
      );

      final markers = await _service.fetchMarkers(
        latitude: _currentCenter!.latitude,
        longitude: _currentCenter!.longitude,
        radius: radius,
        categories: categories,
        region: region,
      );

      debugPrint('✅ API 응답: ${markers.length}개 마커 받음');
      return markers;
    } catch (e, stackTrace) {
      debugPrint('❌ 마커 로드 오류: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 지도에 마커 추가
  Future<Set<Marker>> addMarkersToMap(
    List<Map<String, dynamic>> markersData, {
    Function(Map<String, dynamic>)? onMarkerTap,
  }) async {
    if (markersData.isEmpty) {
      debugPrint('⚠️ 마커 리스트가 비어있습니다');
      return {};
    }

    try {
      debugPrint('📍 웹 마커 생성 시작: ${markersData.length}개');

      // 배치로 모든 마커 이미지 생성
      final markerImages = await _markerGenerator.generateBatchMarkers(
        markersData,
      );

      debugPrint('✅ 마커 이미지 생성 완료: ${markerImages.length}개');

      final newMarkers = <Marker>{};

      for (var data in markersData) {
        try {
          final id = data['id'].toString();
          final latitude = data['latitude'] as double?;
          final longitude = data['longitude'] as double?;

          if (latitude == null || longitude == null) {
            debugPrint('⚠️ 위도/경도가 null입니다: id=$id');
            continue;
          }

          final imageBytes = markerImages[id];
          if (imageBytes == null) {
            debugPrint('⚠️ 마커 이미지가 없습니다: id=$id');
            continue;
          }

          final marker = Marker(
            markerId: MarkerId(id),
            position: LatLng(latitude, longitude),
            icon: BitmapDescriptor.bytes(imageBytes),
            onTap: onMarkerTap != null ? () => onMarkerTap(data) : null,
          );

          newMarkers.add(marker);
        } catch (e) {
          debugPrint('❌ 마커 생성 실패: ${data['id']} - $e');
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

  /// 현재 마커 세트 가져오기
  Set<Marker> get markers => _markers;

  /// 마커 모두 제거
  void clearMarkers() {
    _markers.clear();
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
  }
}
