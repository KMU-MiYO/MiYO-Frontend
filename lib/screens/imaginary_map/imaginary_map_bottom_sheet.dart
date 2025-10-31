import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:miyo/data/services/post_service.dart';
import 'package:miyo/screens/suggestion/suggestion_detail_screen.dart';
import 'package:miyo/screens/imaginary_map/suggestion_item.dart';
import 'package:miyo/screens/imaginary_map/suggestion_top3.dart';
import 'package:miyo/screens/imaginary_map/suggestion_category_button.dart';
import 'package:miyo/screens/imaginary_map/suggestion_filtering_button.dart';

class ImaginaryMapBottomSheet extends StatefulWidget {
  final NaverMapController mapController;
  final VoidCallback? onMapMoved;
  final Function(VoidCallback)? onReloadCallback;
  final Function(double)? onSheetHeightChanged;

  const ImaginaryMapBottomSheet({
    super.key,
    required this.mapController,
    this.onMapMoved,
    this.onReloadCallback,
    this.onSheetHeightChanged,
  });

  @override
  State<ImaginaryMapBottomSheet> createState() =>
      _ImaginaryMapBottomSheetState();
}

class _ImaginaryMapBottomSheetState extends State<ImaginaryMapBottomSheet> {
  final PostService _postService = PostService();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // 선택된 카테고리들 (빈 Set = 전체 보기)
  Set<CategoryType> selectedCategories = {};

  // 선택된 필터 (기본: 인기순)
  FilterType selectedFilter = FilterType.popularity;

  // Top3 데이터
  List<dynamic> _top3Posts = [];
  bool _isLoadingTop3 = true;

  // 내 주변 게시글 데이터
  List<dynamic> _nearbyPosts = [];
  bool _isLoadingNearby = true;

  // 제안 목록 스크롤 컨트롤러
  final ScrollController _suggestionScrollController = ScrollController();

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
    // 부모에게 reload callback 등록
    widget.onReloadCallback?.call(reloadData);
    _loadTop3Posts();
    _loadNearbyPosts();

    // sheet 높이 변화 리스너 추가
    _sheetController.addListener(_onSheetHeightChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetHeightChanged);
    _sheetController.dispose();
    _suggestionScrollController.dispose();
    super.dispose();
  }

  void _onSheetHeightChanged() {
    if (_sheetController.isAttached) {
      final currentSize = _sheetController.size;
      widget.onSheetHeightChanged?.call(currentSize);
    }
  }

  /// zoom 레벨에 따라 검색 반경(미터) 계산
  double _calculateRadiusFromZoom(double zoom) {
    if (zoom >= 15) return 500;
    if (zoom >= 14) return 1000;
    if (zoom >= 13) return 2000;
    if (zoom >= 12) return 4000;
    if (zoom >= 11) return 8000;
    return 10000;
  }

  /// 현재 지도 위치 기반으로 Top3 게시글 로드
  Future<void> _loadTop3Posts() async {
    try {
      // 현재 카메라 위치 가져오기
      final cameraPosition = await widget.mapController.getCameraPosition();
      final center = cameraPosition.target;
      final zoom = cameraPosition.zoom;
      final radius = _calculateRadiusFromZoom(zoom);

      // API 호출
      final posts = await _postService.getTop3Posts(
        latitude: center.latitude,
        longitude: center.longitude,
        radius: radius,
      );

      setState(() {
        _top3Posts = posts;
        _isLoadingTop3 = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTop3 = false;
      });
    }
  }

  /// 카테고리 문자열을 CategoryType enum으로 변환
  CategoryType? _parseCategoryType(String? category) {
    if (category == null) return null;

    switch (category.toUpperCase()) {
      case 'NATURE':
        return CategoryType.NATURE;
      case 'CULTURE':
        return CategoryType.CULTURE;
      case 'TRAFFIC':
        return CategoryType.TRAFFIC;
      case 'RESIDENCE':
        return CategoryType.RESIDENCE;
      case 'COMMERCIAL':
        return CategoryType.COMMERCIAL;
      case 'NIGHT':
        return CategoryType.NIGHT;
      case 'ENVIRONMENT':
        return CategoryType.ENVIRONMENT;
      default:
        return null;
    }
  }

  /// CategoryType enum을 백엔드 카테고리 문자열로 변환
  String _categoryTypeToString(CategoryType category) {
    switch (category) {
      case CategoryType.NATURE:
        return 'NATURE';
      case CategoryType.CULTURE:
        return 'CULTURE';
      case CategoryType.TRAFFIC:
        return 'TRAFFIC';
      case CategoryType.RESIDENCE:
        return 'RESIDENCE';
      case CategoryType.COMMERCIAL:
        return 'COMMERCIAL';
      case CategoryType.NIGHT:
        return 'NIGHT';
      case CategoryType.ENVIRONMENT:
        return 'ENVIRONMENT';
    }
  }

  /// FilterType enum을 백엔드 sortBy 문자열로 변환
  String _filterTypeToSortBy(FilterType filter) {
    switch (filter) {
      case FilterType.popularity:
        return 'empathy'; // 공감순
      case FilterType.latest:
        return 'latest'; // 최신순
      case FilterType.distance:
        return 'distance'; // 거리순
    }
  }

  /// 현재 지도 위치 및 필터 기반으로 내 주변 게시글 로드
  Future<void> _loadNearbyPosts() async {
    setState(() => _isLoadingNearby = true);

    try {
      // 현재 카메라 위치 가져오기
      final cameraPosition = await widget.mapController.getCameraPosition();
      final center = cameraPosition.target;
      final zoom = cameraPosition.zoom;
      final radius = _calculateRadiusFromZoom(zoom);

      // 선택된 카테고리를 백엔드 문자열로 변환
      final categories = selectedCategories.isEmpty
          ? null
          : selectedCategories.map(_categoryTypeToString).toList();

      // FilterType을 sortBy 문자열로 변환
      final sortBy = _filterTypeToSortBy(selectedFilter);

      // API 호출
      final posts = await _postService.getNearbyPosts(
        latitude: center.latitude,
        longitude: center.longitude,
        radius: radius,
        categories: categories,
        sortBy: sortBy,
      );

      setState(() {
        _nearbyPosts = posts;
        _isLoadingNearby = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingNearby = false;
      });
    }
  }

  void toggleCategory(CategoryType category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
    // 카테고리 변경 시 내 주변 게시글 다시 로드
    _loadNearbyPosts();
  }

  void changeFilter(FilterType newFilter) {
    setState(() {
      selectedFilter = newFilter;
    });
    // 필터 변경 시 내 주변 게시글 다시 로드
    _loadNearbyPosts();
  }

  /// 외부에서 호출 가능한 reload 메서드
  void reloadData() {
    _loadTop3Posts();
    _loadNearbyPosts();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.3,
      minChildSize: 0.05,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5),
            ],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              // 드래그 핸들
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Color(0xffF0F2F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // 검색창
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '게시글 검색하기',
                    hintStyle: TextStyle(color: Color(0xff61758A)),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xff61758A),
                    ),
                    filled: true,
                    fillColor: Color(0xffF0F2F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.001),
              // Top3 제안
              SizedBox(
                height: 110,
                child: _isLoadingTop3
                    ? const Center(child: CircularProgressIndicator())
                    : _top3Posts.isEmpty
                    ? const Center(
                        child: Text(
                          '주변에 게시글이 없습니다',
                          style: TextStyle(color: Color(0xff61758A)),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: _top3Posts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final post = _top3Posts[index];
                          return SuggestionTop3(
                            categoryType:
                                _parseCategoryType(post['category']) ??
                                CategoryType.NATURE,
                            title: post['title'] ?? '',
                            writer: post['nickname'] ?? '익명',
                            rank: index + 1,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SuggestionDetailScreen(
                                    postId: post['postId'] as int,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              SizedBox(height: height * 0.001),
              // 내 주변 제목 + 필터링 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '내 주변',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SuggestionFilteringButton(
                      selectedFilter: selectedFilter,
                      onFilterChanged: changeFilter,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 카테고리 필터 버튼
              SizedBox(
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
              SizedBox(height: height * 0.02),
              // 제안 목록 (고정 높이 + 내부 스크롤)
              SizedBox(
                height: 300,
                child: _isLoadingNearby
                    ? const Center(child: CircularProgressIndicator())
                    : _nearbyPosts.isEmpty
                    ? const Center(
                        child: Text(
                          '주변에 게시글이 없습니다',
                          style: TextStyle(color: Color(0xff61758A)),
                        ),
                      )
                    : Scrollbar(
                        controller: _suggestionScrollController,
                        thumbVisibility: true,
                        thickness: 3,
                        radius: Radius.circular(2),
                        child: ListView.separated(
                          controller: _suggestionScrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          itemCount: _nearbyPosts.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final post = _nearbyPosts[index];
                            return SuggestionItem(
                              categoryType: _parseCategoryType(
                                post['category'],
                              ),
                              title: post['title'] ?? '',
                              writer: post['nickname'] ?? '익명',
                              postId: post['postId'] as int,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
