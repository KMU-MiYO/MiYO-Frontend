// lib/screens/imaginary_map/imaginary_map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:miyo/services/imaginary_map_controller.dart';
import 'package:miyo/screens/suggestion/suggestion_detail_screen.dart';
import 'package:miyo/screens/imaginary_map/imaginary_map_bottom_sheet.dart';

class ImaginaryMapScreen extends StatefulWidget {
  const ImaginaryMapScreen({super.key});

  @override
  State<ImaginaryMapScreen> createState() => _ImaginaryMapScreenState();
}

class _ImaginaryMapScreenState extends State<ImaginaryMapScreen> {
  final ImaginaryMapController _mapController = ImaginaryMapController();

  List<Map<String, dynamic>> _markers = [];
  bool _isLoading = true;
  NaverMapController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    await _mapController.requestLocationPermission();
    setState(() => _isLoading = false);
  }

  Future<void> _loadMarkersForCurrentView() async {
    if (_controller == null) return;

    try {
      // 컨트롤러를 사용해서 마커 데이터 가져오기
      final markers = await _mapController.fetchMarkersForCurrentView(
        _controller!,
      );

      setState(() => _markers = markers);

      // 기존 마커 삭제 후 새로운 마커 추가
      await _controller!.clearOverlays();
      await _mapController.addMarkersToMap(
        _controller!,
        _markers,
        onMarkerTap: _onMarkerTap,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('마커 로드 오류: $e')));
      }
    }
  }

  void _onMarkerTap(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SuggestionDetailScreen()),
    );
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
              _controller = controller;
              // 지도 초기 로드 시 마커 가져오기
              await _loadMarkersForCurrentView();
            },
            onCameraIdle: () {
              // 카메라 이동이 끝났을 때 마커 로드
              _loadMarkersForCurrentView();
            },
          ),
          // 검색창
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: '게시글 검색하기',
                hintStyle: TextStyle(color: Color(0xff61758A)),
                prefixIcon: const Icon(Icons.search, color: Color(0xff61758A)),
                filled: true,
                fillColor: Color(0xffF0F2F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const ImaginaryMapBottomSheet(),
        ],
      ),
    );
  }
}
