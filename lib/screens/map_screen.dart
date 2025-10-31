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
import 'package:miyo/data/services/exchange_service.dart';
import 'package:miyo/services/geocoding_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<NaverMapController> _mapControllerCompleter = Completer();
  final PostService _postService = PostService();
  final RewardService _rewardService = RewardService();
  final TextEditingController _searchController = TextEditingController();
  final GeocodingService _geocodingService = GeocodingService();

  // 선택된 카테고리들 (빈 Set = 전체 보기)
  Set<CategoryType> selectedCategories = {};

  // 생성된 마커들과 연관된 게시글 데이터 저장
  final Map<String, Map<String, dynamic>> _markerPostData = {};
  final Map<String, NMarker> _markerCache = {}; // 마커 캐시

  bool _isLoadingPosts = false;
  double _currentZoom = 14.0; // 현재 줌 레벨
  static const double _minZoomForMarkers = 12.0; // 마커 표시 최소 줌 레벨

  // 리워드 포인트
  String _currentPoint = '0';
  bool _isLoadingReward = true;

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
    _loadReward();
    // 지도가 준비되면 게시글 로드
    _mapControllerCompleter.future.then((_) {
      _loadMyPosts();
    });
  }

  @override
  void dispose() {
    // 메모리 누수 방지: 캐시 및 컨트롤러 정리
    _markerCache.clear();
    _markerPostData.clear();
    _searchController.dispose();
    super.dispose();
  }

  /// 리워드 포인트 불러오기
  Future<void> _loadReward() async {
    try {
      final rewardData = await _rewardService.getReward();
      final reward = rewardData['reward'];

      setState(() {
        // 천 단위 콤마 추가
        _currentPoint = reward.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
        _isLoadingReward = false;
      });
    } catch (e) {
      setState(() {
        _currentPoint = '0';
        _isLoadingReward = false;
      });
    }
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

      final controller = await _mapControllerCompleter.future;
      final currentPostIds = <String>{};

      // 새로운 마커 추가 또는 기존 마커 재사용
      for (final post in posts) {
        final postId = post['postId'].toString();
        final latitude = post['latitude'] as double;
        final longitude = post['longitude'] as double;
        final category = post['category'] as String;

        currentPostIds.add(postId);

        // 게시글 데이터 저장
        _markerPostData[postId] = post;

        // 캐시에 마커가 있는지 확인
        if (_markerCache.containsKey(postId)) {
          // 기존 마커 재사용 - 위치가 변경되었을 수 있으므로 업데이트
          final cachedMarker = _markerCache[postId]!;
          // 위치 업데이트가 필요한 경우에만
          if (cachedMarker.position.latitude != latitude ||
              cachedMarker.position.longitude != longitude) {
            // 마커 제거 후 새 위치로 재생성
            await controller.deleteOverlay(cachedMarker.info);
            await _addMarkerFromPost(
              postId: postId,
              latLng: NLatLng(latitude, longitude),
              title: post['title'] ?? '제목 없음',
              category: category,
            );
          } else {
            // 위치가 같으면 그대로 사용
            try {
              await controller.addOverlay(cachedMarker);
            } catch (e) {
              // 이미 추가된 경우 무시
            }
          }
        } else {
          // 새로운 마커 생성
          await _addMarkerFromPost(
            postId: postId,
            latLng: NLatLng(latitude, longitude),
            title: post['title'] ?? '제목 없음',
            category: category,
          );
        }
      }

      // 더 이상 존재하지 않는 마커 제거
      final markersToRemove = <String>[];
      for (final postId in _markerCache.keys) {
        if (!currentPostIds.contains(postId)) {
          markersToRemove.add(postId);
          final marker = _markerCache[postId]!;
          await controller.deleteOverlay(marker.info);
        }
      }
      for (final postId in markersToRemove) {
        _markerCache.remove(postId);
        _markerPostData.remove(postId);
      }
    } catch (e) {
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

  // 검색 실행
  Future<void> _onSearchSubmitted(String address) async {
    if (address.trim().isEmpty) return;

    try {
      final controller = await _mapControllerCompleter.future;

      // 주소 → 좌표 변환
      final coordinates = await _geocodingService.getCoordinatesFromAddress(
        address,
      );

      if (coordinates == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('검색 결과를 찾을 수 없습니다')));
        }
        return;
      }

      final lat = coordinates['latitude']!;
      final lng = coordinates['longitude']!;

      // 지도 카메라 이동
      final cameraUpdate =
          NCameraUpdate.withParams(target: NLatLng(lat, lng), zoom: 15)
            ..setAnimation(
              animation: NCameraAnimation.easing,
              duration: const Duration(milliseconds: 500),
            );

      await controller.updateCamera(cameraUpdate);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('검색 오류: $e')));
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

  // 줌 레벨에 따라 마커 표시 업데이트 (클러스터링 효과)
  Future<void> _updateMarkersByZoom() async {
    if (_currentZoom < _minZoomForMarkers) {
      // 줌 아웃 시 모든 마커 숨김 (성능 최적화)
      final controller = await _mapControllerCompleter.future;
      for (final marker in _markerCache.values) {
        try {
          await controller.deleteOverlay(marker.info);
        } catch (e) {
          // 이미 제거된 경우 무시
        }
      }
      return;
    }

    // 줌 인 시 카테고리 필터에 따라 마커 표시
    await _updateMarkerVisibility();
  }

  // 카테고리 필터에 따라 마커 가시성 업데이트
  Future<void> _updateMarkerVisibility() async {
    final controller = await _mapControllerCompleter.future;

    for (final entry in _markerCache.entries) {
      final postId = entry.key;
      final marker = entry.value;
      final postData = _markerPostData[postId];

      if (postData != null) {
        final categoryStr = postData['category'] as String;
        final categoryType = _getCategoryType(categoryStr);

        // 줌 레벨 체크 + 카테고리 필터 체크
        final shouldShow =
            _currentZoom >= _minZoomForMarkers &&
            (selectedCategories.isEmpty ||
                selectedCategories.contains(categoryType));

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

    // 새로운 마커 생성 (기본 마커 사용)
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

    // 캐시에 저장
    _markerCache[postId] = marker;
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

    // 마커 클릭 이벤트 추가
    marker.setOnTapListener((overlay) {
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

    // 캐시에 저장
    _markerCache[postId] = marker;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 8.0),
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
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        actions: [],
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
                // 지도 (전체 화면)
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
                  onCameraChange: (position, reason) async {
                    // 줌 레벨 변경 감지
                    final controller = await _mapControllerCompleter.future;
                    final cameraPosition = await controller.getCameraPosition();
                    final newZoom = cameraPosition.zoom;

                    if ((newZoom - _currentZoom).abs() > 0.5) {
                      setState(() {
                        _currentZoom = newZoom;
                      });
                      _updateMarkersByZoom();
                    }
                  },
                ),
                // 포인트 표시 및 교환소 버튼 (지도 위에 오버레이)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
                    child: Row(
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
                        _isLoadingReward
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xff00AA5D),
                                ),
                              )
                            : Text(
                                _currentPoint,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        Spacer(),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ExchangeScreen(point: _currentPoint),
                              ),
                            );
                            // 교환소에서 돌아왔을 때 포인트 새로고침
                            if (result != null) {
                              _loadReward();
                            }
                          },
                          icon: Icon(
                            Icons.card_giftcard,
                            color: Colors.white,
                            size: 20,
                          ),
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 카테고리 필터 버튼
                Positioned(
                  top: 80,
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
