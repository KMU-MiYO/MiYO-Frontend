import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:miyo/screens/imaginary_map/suggestion_item.dart';
import 'package:miyo/screens/imaginary_map/suggestion_category_button.dart';
import 'package:miyo/screens/exchanges/exchange.dart';
import 'package:miyo/screens/suggestion/suggestion_screen.dart';
import 'package:miyo/screens/suggestion/suggestion_detail_screen.dart';
import 'package:miyo/data/services/post_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<NaverMapController> _mapControllerCompleter = Completer();
  final PostService _postService = PostService();

  // 선택된 카테고리들 (빈 Set = 전체 보기)
  Set<CategoryType> selectedCategories = {};

  // 생성된 마커들과 연관된 게시글 데이터 저장
  final Map<String, Map<String, dynamic>> _markerPostData = {};
  final List<NMarker> _markers = [];

  bool _isLoadingPosts = false;

  // 모든 카테고리 리스트
  final List<CategoryType> allCategories = [
    CategoryType.NATURE,
    CategoryType.CULTURE,
    CategoryType.TRAFFIC,
    CategoryType.RESIDENCE,
    CategoryType.COMMERCIAL,
    CategoryType.NIGHT,
    CategoryType.ENVIRONMENT,
  ];

  @override
  void initState() {
    super.initState();
    // 지도가 준비되면 게시글 로드
    _mapControllerCompleter.future.then((_) {
      _loadMyPosts();
    });
  }

  // 내 게시글 불러오기
  Future<void> _loadMyPosts() async {
    if (_isLoadingPosts) return;

    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final result = await _postService.getMyPosts();
      final posts = result['content'] as List;

      print('📦 로드된 게시글 수: ${posts.length}');

      // 기존 마커 제거
      final controller = await _mapControllerCompleter.future;
      for (final marker in _markers) {
        await controller.deleteOverlay(marker.info);
      }
      _markers.clear();
      _markerPostData.clear();

      // 새로운 마커 추가
      for (final post in posts) {
        final postId = post['postId'].toString();
        final latitude = post['latitude'] as double;
        final longitude = post['longitude'] as double;
        final category = post['category'] as String;

        // 게시글 데이터 저장
        _markerPostData[postId] = post;

        await _addMarkerFromPost(
          postId: postId,
          latLng: NLatLng(latitude, longitude),
          title: post['title'] ?? '제목 없음',
          category: category,
        );
      }

      print('✅ 마커 로드 완료: ${_markers.length}개');
    } catch (e) {
      print('❌ 게시글 로드 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글을 불러오는데 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
    }
  }

  // 카테고리 문자열을 CategoryType으로 변환
  CategoryType _getCategoryType(String category) {
    switch (category) {
      case 'NATURE':
        return CategoryType.NATURE;
      case 'CULTURE':
        return CategoryType.CULTURE;
      case 'TRANSPORT':
        return CategoryType.TRAFFIC;
      case 'LIFE':
        return CategoryType.RESIDENCE;
      case 'COMMERCIAL':
        return CategoryType.COMMERCIAL;
      case 'NIGHT':
        return CategoryType.NIGHT;
      case 'ENVIRONMENT':
        return CategoryType.ENVIRONMENT;
      default:
        return CategoryType.NATURE;
    }
  }

  void toggleCategory(CategoryType category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
      _updateMarkerVisibility();
    });
  }

  // 카테고리 필터에 따라 마커 가시성 업데이트
  Future<void> _updateMarkerVisibility() async {
    final controller = await _mapControllerCompleter.future;

    for (final marker in _markers) {
      final postId = marker.info.id.replaceFirst('post_', '');
      final postData = _markerPostData[postId];

      if (postData != null) {
        final categoryStr = postData['category'] as String;
        final categoryType = _getCategoryType(categoryStr);

        // 선택된 카테고리가 없으면 모두 표시
        // 선택된 카테고리가 있으면 해당 카테고리만 표시
        final shouldShow =
            selectedCategories.isEmpty ||
            selectedCategories.contains(categoryType);

        // 마커를 지도에서 추가/제거
        if (shouldShow) {
          // 이미 추가되어 있지 않으면 추가
          try {
            await controller.addOverlay(marker);
          } catch (e) {
            // 이미 추가된 경우 무시
          }
        } else {
          // 지도에서 제거
          try {
            await controller.deleteOverlay(marker.info);
          } catch (e) {
            // 이미 제거된 경우 무시
          }
        }
      }
    }
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
          postId:
              result['postId']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: result['title'] ?? '제목 없음',
        );
      }
    }
  }

  // 게시글 데이터로부터 마커 추가
  Future<void> _addMarkerFromPost({
    required String postId,
    required NLatLng latLng,
    required String title,
    required String category,
  }) async {
    final controller = await _mapControllerCompleter.future;

    // 새로운 마커 생성
    final marker = NMarker(id: 'post_$postId', position: latLng);

    // 마커 클릭 이벤트 추가 - suggestion_detail로 이동
    marker.setOnTapListener((overlay) {
      print('마커 클릭: $title (postId: $postId, category: $category)');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SuggestionDetailScreen(postId: int.parse(postId)),
        ),
      );
    });

    // 마커를 지도에 추가
    await controller.addOverlay(marker);

    setState(() {
      _markers.add(marker);
    });

    print('마커 추가 완료: $title at (${latLng.latitude}, ${latLng.longitude})');
  }

  // 마커 추가 (새 게시글 작성 후)
  Future<void> _addMarker({
    required NLatLng latLng,
    required String postId,
    required String title,
  }) async {
    final controller = await _mapControllerCompleter.future;

    // 새로운 마커 생성
    final marker = NMarker(id: 'post_$postId', position: latLng);

    // 마커 클릭 이벤트 추가 (향후 suggestion_detail로 이동)
    marker.setOnTapListener((overlay) {
      print('마커 클릭: $title (postId: $postId)');
      // TODO: suggestion_detail 화면으로 이동
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$title (상세보기 기능 준비중)')));
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
                        const ExchangeScreen(point: '500,000'),
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
