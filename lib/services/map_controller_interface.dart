// lib/services/map_controller_interface.dart
import 'package:flutter/foundation.dart';

/// 지도 컨트롤러의 공통 인터페이스
/// 플랫폼별 지도(네이버/구글)를 추상화하여 동일한 API 제공
abstract class BaseMapController {
  /// 현재 카메라 위치 정보 가져오기
  Future<CameraPosition> getCameraPosition();

  /// 지도의 모든 오버레이(마커 등) 제거
  Future<void> clearOverlays();

  /// 마커 추가
  Future<void> addMarker(MarkerData markerData);

  /// 카메라 위치 업데이트
  Future<void> updateCamera(CameraUpdate update);
}

/// 카메라 위치 정보
class CameraPosition {
  final double latitude;
  final double longitude;
  final double zoom;

  CameraPosition({
    required this.latitude,
    required this.longitude,
    required this.zoom,
  });
}

/// 카메라 업데이트 정보
class CameraUpdate {
  final double latitude;
  final double longitude;
  final double zoom;
  final Duration duration;

  CameraUpdate({
    required this.latitude,
    required this.longitude,
    required this.zoom,
    this.duration = const Duration(milliseconds: 500),
  });
}

/// 마커 데이터
class MarkerData {
  final String id;
  final double latitude;
  final double longitude;
  final Uint8List iconBytes;
  final VoidCallback? onTap;

  MarkerData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.iconBytes,
    this.onTap,
  });
}
