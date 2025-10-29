import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:miyo/screens/imaginary_map/suggestion_item.dart';
import 'package:miyo/screens/imaginary_map/suggestion_category_button.dart';
import 'package:miyo/screens/exchanges/exchange.dart';
import 'package:miyo/screens/suggestion/suggestion_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<NaverMapController> _mapControllerCompleter = Completer();

  // 선택된 카테고리들 (빈 Set = 전체 보기)
  Set<CategoryType> selectedCategories = {};

  // 생성된 마커들 저장
  final List<NMarker> _markers = [];

  // 모든 카테고리 리스트
  final List<CategoryType> allCategories = [
    CategoryType.NaturePark,
    CategoryType.CultureArts,
    CategoryType.Transport,
    CategoryType.Life,
    CategoryType.Commercial,
    CategoryType.NightLandscape,
    CategoryType.EnvironSustain,
  ];

  void toggleCategory(CategoryType category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  // 지도 클릭 시 마커 생성 및 suggestion_screen으로 이동
  Future<void> _onMapTapped(NLatLng latLng) async {
    // suggestion_screen으로 이동하며 위도, 경도 전달
    if (mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuggestionScreen(
            latitude: latLng.latitude,
            longitude: latLng.longitude,
          ),
        ),
      );

      // 게시글이 성공적으로 등록되었으면 마커 추가
      if (result != null && result is Map<String, dynamic>) {
        await _addMarker(
          latLng: latLng,
          postId: result['postId']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: result['title'] ?? '제목 없음',
        );
      }
    }
  }

  // 마커 추가
  Future<void> _addMarker({
    required NLatLng latLng,
    required String postId,
    required String title,
  }) async {
    final controller = await _mapControllerCompleter.future;

    // 새로운 마커 생성
    final marker = NMarker(
      id: 'post_$postId',
      position: latLng,
    );

    // 마커 클릭 이벤트 추가 (향후 suggestion_detail로 이동)
    marker.setOnTapListener((overlay) {
      print('마커 클릭: $title (postId: $postId)');
      // TODO: suggestion_detail 화면으로 이동
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title (상세보기 기능 준비중)')),
      );
    });

    // 마커를 지도에 추가
    await controller.addOverlay(marker);

    setState(() {
      _markers.add(marker);
    });

    print('마커 추가 완료: $title at (${latLng.latitude}, ${latLng.longitude})');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xff00AA5D),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                'P',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              '500,000',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ExchangeScreen(point: '500, 000'),
                  ),
                );
              },
              icon: Icon(Icons.card_giftcard, color: Colors.white, size: 20),
              label: Text(
                '교환소',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff00AA5D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: kIsWeb
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    '지도 기능은 모바일에서만 사용 가능합니다.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                NaverMap(
                  options: const NaverMapViewOptions(
                    locationButtonEnable: true,
                    initialCameraPosition: NCameraPosition(
                      target: NLatLng(37.602, 126.977),
                      zoom: 14,
                    ),
                  ),
                  onMapReady: (controller) {
                    _mapControllerCompleter.complete(controller);
                  },
                  onMapTapped: (point, latLng) {
                    _onMapTapped(latLng);
                  },
                ),
                // 카테고리 필터 버튼
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: allCategories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = allCategories[index];
                        return SuggestionCategoryButton(
                          categoryType: category,
                          isSelected: selectedCategories.contains(category),
                          onTap: () => toggleCategory(category),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
