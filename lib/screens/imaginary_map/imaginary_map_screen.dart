// lib/screens/imaginary_map/imaginary_map_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:miyo/services/imaginary_service.dart';
import 'package:miyo/services/marker_image_generator.dart';
import 'package:miyo/screens/imaginary_map/suggestion_detail_screen.dart'; //챌린지 작성글 페이지로 수정 필요
import 'package:miyo/screens/imaginary_map/imaginary_map_bottom_sheet.dart';

class ImaginaryMapScreen extends StatefulWidget {
  const ImaginaryMapScreen({super.key});

  @override
  State<ImaginaryMapScreen> createState() => _ImaginaryMapScreenState();
}

class _ImaginaryMapScreenState extends State<ImaginaryMapScreen> {
  final Completer<NaverMapController> _mapControllerCompleter = Completer();
  final ImaginaryService _service = ImaginaryService();
  final MarkerImageGenerator _imageGenerator = MarkerImageGenerator();

  List<Map<String, dynamic>> _markers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    try {
      setState(() => _isLoading = true);
      final markers = await _service.fetchMarkers();
      setState(() {
        _markers = markers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            options: const NaverMapViewOptions(
              locationButtonEnable: true,
              initialCameraPosition: NCameraPosition(
                target: NLatLng(37.602, 126.977),
                zoom: 14,
              ),
            ),
            onMapReady: (controller) async {
              _mapControllerCompleter.complete(controller);
              await _addMarkersToMap(controller);
            },
          ),
          const ImaginaryMapBottomSheet(),
        ],
      ),
    );
  }

  Future<void> _addMarkersToMap(NaverMapController controller) async {
    // 배치로 모든 마커 이미지를 한번에 생성 (최적화)
    final markerImagePaths = await _imageGenerator.generateBatchMarkerImages(
      _markers,
    );

    // 생성된 이미지로 마커 추가
    for (var data in _markers) {
      final imagePath = markerImagePaths[data['id']]!;

      final marker = NMarker(
        id: data['id'],
        position: NLatLng(data['latitude'], data['longitude']),
        icon: NOverlayImage.fromFile(File(imagePath)),
      );

      // 마커 클릭 시
      marker.setOnTapListener((overlay) => _onMarkerTap(data));

      controller.addOverlay(marker);
    }
  }

  void _onMarkerTap(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SuggestionDetailScreen(), // 해당 작성글 페이지 이동으로 수정 필요
      ),
    );
  }

  Future<void> _updateMarkerOnMap(
    Map<String, dynamic> data,
    int newCount,
  ) async {
    final controller = await _mapControllerCompleter.future;

    // 상태 업데이트
    final index = _markers.indexWhere((m) => m['id'] == data['id']);
    if (index != -1) {
      _markers[index]['favoriteCnt'] = newCount;
    }

    // 기존 마커 전부 삭제 후 재생성
    controller.clearOverlays();
    await _addMarkersToMap(controller);
  }

  @override
  void dispose() {
    // 앱 종료 시 캐시 정리
    // _imageGenerator.clearCache();
    super.dispose();
  }
}
