// lib/screens/imaginary_map/imaginary_map_screen_web.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:miyo/services/web_imaginary_map_controller.dart';
import 'package:miyo/screens/suggestion/suggestion_detail_screen.dart';
import 'package:miyo/screens/imaginary_map/imaginary_map_bottom_sheet.dart';

/// 웹 플랫폼용 상상지도 화면 (Google Maps 사용)
class ImaginaryMapScreenWeb extends StatefulWidget {
  const ImaginaryMapScreenWeb({super.key});

  @override
  State<ImaginaryMapScreenWeb> createState() => _ImaginaryMapScreenWebState();
}

class _ImaginaryMapScreenWebState extends State<ImaginaryMapScreenWeb> {
  WebImaginaryMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  VoidCallback? _reloadBottomSheet;

  List<Map<String, dynamic>> _markers = [];
  bool _isLoading = true;
  GoogleMapController? _googleMapController;
  Set<Marker> _googleMarkers = {};

  // 초기 카메라 위치 (서울)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.602, 126.977),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _mapController = WebImaginaryMapController();
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _onSearchSubmitted(String address) async {
    if (_mapController == null || address.trim().isEmpty) return;

    try {
      final success = await _mapController!.searchAndMoveToAddress(address);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('검색 결과를 찾을 수 없습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 오류: $e')),
        );
      }
    }
  }

  Future<void> _initializeLocation() async {
    // 웹에서도 위치 권한 요청 가능
    if (_mapController != null) {
      final position = await _mapController!.getCurrentPosition();
      if (position != null && _googleMapController != null) {
        await _mapController!.moveCamera(
          position.latitude,
          position.longitude,
          zoom: 14,
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadMarkersForCurrentView() async {
    if (_mapController == null) return;

    try {
      final markers = await _mapController!.fetchMarkersForCurrentView();
      setState(() => _markers = markers);

      // 마커 추가
      final newMarkers = await _mapController!.addMarkersToMap(
        _markers,
        onMarkerTap: _onMarkerTap,
      );

      setState(() => _googleMarkers = newMarkers);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('마커 로드 오류: $e')),
        );
      }
    }
  }

  void _onMarkerTap(Map<String, dynamic> data) {
    final postId = data['id'] is int
        ? data['id'] as int
        : int.tryParse(data['id']?.toString() ?? '1') ?? 1;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuggestionDetailScreen(postId: postId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Google Maps
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _googleMarkers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _googleMapController = controller;
              _mapController?.setMapController(controller);

              // 초기 위치 설정
              _mapController?.updateCameraPosition(
                _initialPosition.target,
                _initialPosition.zoom,
              );

              // 초기 마커 로드
              _loadMarkersForCurrentView();
            },
            onCameraMove: (position) {
              _mapController?.updateCameraPosition(
                position.target,
                position.zoom,
              );
            },
            onCameraIdle: () {
              // 카메라 이동이 끝났을 때 마커 로드
              _loadMarkersForCurrentView();
              _reloadBottomSheet?.call();
            },
          ),

          // 검색창
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
              child: TextField(
                controller: _searchController,
                onSubmitted: _onSearchSubmitted,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: '장소 검색하기',
                  hintStyle: const TextStyle(color: Color(0xff61758A)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xff61758A)),
                  filled: true,
                  fillColor: const Color(0xffF0F2F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Sheet (웹에서는 GoogleMapController를 전달할 수 없으므로 제거하거나 수정 필요)
          // if (_googleMapController != null)
          //   ImaginaryMapBottomSheet(
          //     mapController: _googleMapController!,
          //     onReloadCallback: (callback) {
          //       _reloadBottomSheet = callback;
          //     },
          //   ),
        ],
      ),
    );
  }
}
