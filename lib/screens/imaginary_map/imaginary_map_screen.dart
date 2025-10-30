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
  final TextEditingController _searchController = TextEditingController();
  VoidCallback? _reloadBottomSheet;

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
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _onSearchSubmitted(String address) async {
    if (_controller == null || address.trim().isEmpty) return;

    try {
      final success = await _mapController.searchAndMoveToAddress(
        _controller!,
        address,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('검색 결과를 찾을 수 없습니다')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('검색 오류: $e')));
      }
    }
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
    // id가 String일 수 있으므로 int로 변환
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
              setState(() {
                _controller = controller;
              });
              // 지도 초기 로드 시 마커 가져오기
              await _loadMarkersForCurrentView();
            },
            onCameraIdle: () {
              // 카메라 이동이 끝났을 때 마커 로드
              _loadMarkersForCurrentView();
              // Bottom sheet도 reload
              _reloadBottomSheet?.call();
            },
          ),
          // 검색창
          Container(
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
          if (_controller != null)
            ImaginaryMapBottomSheet(
              mapController: _controller!,
              onReloadCallback: (callback) {
                _reloadBottomSheet = callback;
              },
            ),
        ],
      ),
    );
  }
}
