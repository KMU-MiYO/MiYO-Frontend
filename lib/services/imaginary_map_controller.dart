// lib/services/imaginary_map_controller.dart
import 'dart:io';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:miyo/services/imaginary_service.dart';
import 'package:miyo/services/marker_image_generator.dart';
import 'package:miyo/services/geocoding_service.dart';

/// 상상지도 화면의 모든 비즈니스 로직을 담당하는 컨트롤러
/// 지도 관련 작업(카메라 위치 계산, 마커 로드, 위치 권한 등)을 처리
class ImaginaryMapController {
  final ImaginaryService _service = ImaginaryService();
  final MarkerImageGenerator _imageGenerator = MarkerImageGenerator();
  final GeocodingService _geocodingService = GeocodingService();

  /// zoom 레벨에 따라 검색 반경(미터) 계산
  /// zoom이 높을수록(확대) 반경이 작아짐
  double calculateRadiusFromZoom(double zoom) {
    if (zoom >= 15) return 500;
    if (zoom >= 14) return 1000;
    if (zoom >= 13) return 2000;
    if (zoom >= 12) return 4000;
    if (zoom >= 11) return 8000;
    return 10000;
  }

  /// 현재 카메라 위치 기반으로 마커 데이터 가져오기
  Future<List<Map<String, dynamic>>> fetchMarkersForCurrentView(
    NaverMapController controller, {
    List<String>? categories,
    String? region,
  }) async {
    try {
      // 1. 현재 카메라 위치 가져오기
      print('📍 카메라 위치 가져오기 시작');
      final cameraPosition = await controller.getCameraPosition();
      final center = cameraPosition.target;
      final zoom = cameraPosition.zoom;
      final radius = calculateRadiusFromZoom(zoom);

      print(
        '✅ 카메라 위치: lat=${center.latitude}, lng=${center.longitude}, zoom=$zoom, radius=$radius',
      );

      // 2. API 호출
      print('📍 백엔드 API 호출 시작');
      final markers = await _service.fetchMarkers(
        latitude: center.latitude,
        longitude: center.longitude,
        radius: radius,
        categories: categories,
        region: region,
      );

      print('✅ API 응답: ${markers.length}개 마커 받음');
      return markers;
    } catch (e, stackTrace) {
      print('❌ 마커 로드 오류: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 지도에 마커 추가
  Future<void> addMarkersToMap(
    NaverMapController controller,
    List<Map<String, dynamic>> markers, {
    Function(Map<String, dynamic>)? onMarkerTap,
  }) async {
    if (markers.isEmpty) {
      print('⚠️ 마커 리스트가 비어있습니다');
      return;
    }

    try {
      print('📍 마커 이미지 생성 시작: ${markers.length}개');
      print('📍 받은 마커 데이터: $markers');

      // 배치로 모든 마커 이미지를 한번에 생성 (최적화)
      final markerImagePaths = await _imageGenerator.generateBatchMarkerImages(
        markers,
      );
      print('✅ 마커 이미지 생성 완료');
      print('📍 생성된 이미지 경로: $markerImagePaths');

      // 생성된 이미지로 마커 추가
      int successCount = 0;
      for (var data in markers) {
        final markerId = data['id'];
        if (markerId == null) {
          print('⚠️ 마커 ID가 null입니다: $data');
          continue;
        }

        final imagePath = markerImagePaths[markerId];
        if (imagePath == null) {
          print('⚠️ 이미지 경로가 없습니다: ID=$markerId');
          print('   사용 가능한 경로: ${markerImagePaths.keys.toList()}');
          continue;
        }

        final latitude = data['latitude'];
        final longitude = data['longitude'];
        if (latitude == null || longitude == null) {
          print('⚠️ 위도/경도가 null입니다: ID=$markerId');
          continue;
        }

        print(
          '📍 마커 추가 시도: id=$markerId, lat=$latitude, lng=$longitude, path=$imagePath',
        );

        // 파일 존재 확인
        final file = File(imagePath);
        final fileExists = await file.exists();
        if (!fileExists) {
          print('❌ 마커 파일이 존재하지 않습니다: $imagePath');
          continue;
        }

        final fileSize = await file.length();
        print('✅ 마커 파일 확인: 크기=$fileSize bytes');

        final marker = NMarker(
          id: markerId,
          position: NLatLng(latitude, longitude),
          icon: NOverlayImage.fromFile(file),
        );

        // 마커 클릭 리스너 설정
        if (onMarkerTap != null) {
          marker.setOnTapListener((overlay) => onMarkerTap(data));
        }

        await controller.addOverlay(marker);
        successCount++;
        print('✅ 마커 추가 성공: id=$markerId');
      }
      print('✅ 총 $successCount개 마커 추가 완료 (전체 ${markers.length}개 중)');
    } catch (e, stackTrace) {
      print('❌ 마커 추가 중 오류: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 마커 데이터 업데이트 (공감수 변경 등)
  Future<void> updateMarkerData(
    NaverMapController controller,
    List<Map<String, dynamic>> markers,
    String markerId,
    int newCount, {
    Function(Map<String, dynamic>)? onMarkerTap,
  }) async {
    // 상태 업데이트
    final index = markers.indexWhere((m) => m['id'] == markerId);
    if (index != -1) {
      markers[index]['favoriteCnt'] = newCount;
    }

    // 기존 마커 전부 삭제 후 재생성
    controller.clearOverlays();
    await addMarkersToMap(controller, markers, onMarkerTap: onMarkerTap);
  }

  /// 위치 권한 요청
  Future<void> requestLocationPermission() async {
    var requestStatus = await Permission.location.request();
    var status = await Permission.location.status;
    if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  /// 현재 위치 가져오기
  Future<Position?> getCurrentPosition() async {
    try {
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

      // 현재 위치 가져오기
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      print('위치 가져오기 실패: $e');
      return null;
    }
  }

  /// 마커 데이터 유효성 검증
  bool isValidMarkerData(Map<String, dynamic> data) {
    return data['id'] != null &&
        data['latitude'] != null &&
        data['longitude'] != null;
  }

  /// 주소로 검색하여 지도 이동
  Future<bool> searchAndMoveToAddress(
    NaverMapController controller,
    String address,
  ) async {
    try {
      print('🔍 주소 검색 시작: $address');

      // 주소 → 좌표 변환
      final coordinates = await _geocodingService.getCoordinatesFromAddress(
        address,
      );

      if (coordinates == null) {
        print('⚠️ 검색 결과 없음');
        return false;
      }

      final lat = coordinates['latitude']!;
      final lng = coordinates['longitude']!;

      print('📍 좌표 변환 완료: lat=$lat, lng=$lng');

      // 지도 카메라 이동
      await moveCamera(controller, lat, lng, zoom: 15);

      print('✅ 지도 이동 완료');
      return true;
    } catch (e) {
      print('❌ 주소 검색 오류: $e');
      return false;
    }
  }

  /// 지도 카메라를 특정 위치로 이동
  Future<void> moveCamera(
    NaverMapController controller,
    double latitude,
    double longitude, {
    double zoom = 14,
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    final cameraUpdate = NCameraUpdate.withParams(
      target: NLatLng(latitude, longitude),
      zoom: zoom,
    )..setAnimation(animation: NCameraAnimation.easing, duration: duration);

    await controller.updateCamera(cameraUpdate);
  }

  /// 컨트롤러 dispose (필요시 리소스 정리)
  void dispose() {
    // 필요시 캐시 정리
    _imageGenerator.clearCache();
  }
}
