import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/screens/imaginary_map/suggestion_item.dart';
import 'package:miyo/screens/imaginary_map/suggestion_filtering_button.dart';
import 'package:miyo/data/services/suggestion_service.dart';

class SuggestionAllScreen extends StatefulWidget {
  final int contestId;

  const SuggestionAllScreen({super.key, required this.contestId});

  @override
  State<SuggestionAllScreen> createState() => _SuggestionAllScreenState();
}

class _SuggestionAllScreenState extends State<SuggestionAllScreen> {
  final SuggestionService _suggestionService = SuggestionService();
  FilterType _sortBy = FilterType.latest;

  List<dynamic> _allSuggestions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 정렬 기준 변환
      String? sortByValue;
      if (_sortBy == FilterType.popularity) {
        sortByValue = 'empathy'; // 인기순 (공감순)
      } else if (_sortBy == FilterType.latest) {
        sortByValue = 'createdAt'; // 최신순
      }
      // distance는 현재 API에서 지원하지 않으므로 null로 처리

      final suggestions = await _suggestionService.getContestPosts(
        contestId: widget.contestId,
        sortBy: sortByValue,
        page: 0,
        size: 20,
      );

      // 디버깅: 첫 번째 제안 글 데이터 구조 출력
      if (suggestions.isNotEmpty) {
        print('📦 첫 번째 제안글 데이터: ${suggestions[0]}');
        print('📦 사용 가능한 키들: ${(suggestions[0] as Map).keys.toList()}');
      }

      setState(() {
        _allSuggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _topSuggestions {
    // 인기 TOP3는 공감(empathy) 기준으로 정렬
    var sortedList = _allSuggestions.toList();
    sortedList.sort((a, b) {
      final empathyA = a['empathy'] ?? 0;
      final empathyB = b['empathy'] ?? 0;
      return (empathyB as int).compareTo(empathyA as int);
    });
    return sortedList.take(3).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppbar(title: '전체 제안 보기', leadingType: LeadingType.back),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '제안 글을 불러오는데 실패했습니다',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSuggestions,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSuggestions,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 인기 제안 TOP3 섹션
                  const Text(
                    '인기 제안 TOP3',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // TOP3 제안 리스트
                  if (_topSuggestions.isNotEmpty)
                    ..._topSuggestions.map((suggestion) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: SuggestionItem(
                          categoryType: _parseCategoryType(
                            suggestion['category'],
                          ),
                          title: suggestion['title']?.toString() ?? '제목 없음',
                          writer:
                              suggestion['userId']?.toString() ?? '작성자 정보 없음',
                          postId: suggestion['postId'] ?? 0,
                        ),
                      );
                    })
                  else
                    const Padding(
                      padding: EdgeInsets.all(100.0),
                      child: Center(child: Text('인기 제안이 없습니다')),
                    ),

                  const SizedBox(height: 8),

                  // 필터 드롭다운
                  Row(
                    children: [
                      // 정렬 드롭다운
                      SuggestionFilteringButton(
                        selectedFilter: _sortBy,
                        onFilterChanged: (filter) {
                          setState(() {
                            _sortBy = filter;
                          });
                          _loadSuggestions();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 전체 제안 리스트
                  if (_allSuggestions.isNotEmpty)
                    ..._allSuggestions.map((suggestion) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: SuggestionItem(
                          categoryType: _parseCategoryType(
                            suggestion['category'],
                          ),
                          title: suggestion['title']?.toString() ?? '제목 없음',
                          writer:
                              suggestion['userId']?.toString() ?? '작성자 정보 없음',
                          postId: suggestion['postId'] ?? 0,
                        ),
                      );
                    })
                  else
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text('제안이 없습니다')),
                    ),
                ],
              ),
            ),
    );
  }
}
