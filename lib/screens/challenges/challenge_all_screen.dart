import 'package:flutter/material.dart';
import 'package:miyo/components/challenge_filtering_button.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/screens/challenges/challenge_item.dart';
import 'package:miyo/data/services/challenge_service.dart';

class ChallengeAllScreen extends StatefulWidget {
  const ChallengeAllScreen({super.key});

  @override
  State<ChallengeAllScreen> createState() => _ChallengeAllScreen();
}

class _ChallengeAllScreen extends State<ChallengeAllScreen> {
  final ChallengeService _challengeService = ChallengeService();
  ChallengeFilterType _sortBy = ChallengeFilterType.newest;
  ChallengeCategoryType _category = ChallengeCategoryType.all;

  List<dynamic> _allChallenges = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sortByValue = _sortBy == ChallengeFilterType.newest
          ? 'newest'
          : 'popular';
      final challenges = await _challengeService.loadAllChallenges(
        sortBy: sortByValue,
      );

      // 디버깅: 첫 번째 챌린지 데이터 구조 출력
      if (challenges.isNotEmpty) {
        print('📦 첫 번째 챌린지 데이터: ${challenges[0]}');
        print('📦 사용 가능한 키들: ${(challenges[0] as Map).keys.toList()}');
      }

      setState(() {
        _allChallenges = challenges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _topChallenges {
    return _allChallenges.take(3).toList();
  }

  List<dynamic> get _filteredChallenges {
    var challenges = _allChallenges.toList();

    // 카테고리 필터링
    final isAllCategory = _category == ChallengeCategoryType.all;
    if (!isAllCategory) {
      challenges = challenges.where((challenge) {
        final categoryType = _parseCategoryType(challenge['category']);
        if (categoryType == null) return false;

        final convertedCategory = _convertToChallengeCategoryType(categoryType);
        return convertedCategory == _category;
      }).toList();
    }

    return challenges;
  }

  CategoryType? _parseCategoryType(dynamic categoryType) {
    if (categoryType == null) return null;

    final categoryStr = categoryType.toString().toUpperCase();
    try {
      return CategoryType.values.firstWhere(
        (e) => e.toString().split('.').last == categoryStr,
        orElse: () => CategoryType.NATURE,
      );
    } catch (e) {
      return null;
    }
  }

  ChallengeCategoryType _convertToChallengeCategoryType(CategoryType type) {
    switch (type) {
      case CategoryType.NATURE:
        return ChallengeCategoryType.nature;
      case CategoryType.CULTURE:
        return ChallengeCategoryType.culture;
      case CategoryType.TRAFFIC:
        return ChallengeCategoryType.traffic;
      case CategoryType.RESIDENCE:
        return ChallengeCategoryType.residence;
      case CategoryType.COMMERCIAL:
        return ChallengeCategoryType.commercial;
      case CategoryType.NIGHT:
        return ChallengeCategoryType.night;
      case CategoryType.ENVIRONMENT:
        return ChallengeCategoryType.environment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppbar(title: '전체 챌린지', leadingType: LeadingType.back),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '챌린지를 불러오는데 실패했습니다',
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
                    onPressed: _loadChallenges,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadChallenges,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 인기 챌린지 TOP3 섹션
                  const Text(
                    '인기 챌린지 TOP3',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // TOP3 챌린지 리스트
                  if (_topChallenges.isNotEmpty)
                    ..._topChallenges.map((challenge) {
                      final categoryType = _parseCategoryType(
                        challenge['category'],
                      );
                      final hostText =
                          challenge['host']?.toString() ?? '주최자 정보 없음';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ChallengeItem(
                          categoryType: categoryType ?? CategoryType.NATURE,
                          title: challenge['title']?.toString() ?? '제목 없음',
                          location: hostText,
                          contestId: challenge['contestId'] ?? 0,
                        ),
                      );
                    })
                  else
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text('인기 챌린지가 없습니다')),
                    ),

                  const SizedBox(height: 8),

                  // 필터 드롭다운
                  Row(
                    children: [
                      // 정렬 드롭다운
                      ChallengeFilterButton(
                        selectedFilter: _sortBy,

                        onFilterChanged: (filter) {
                          setState(() {
                            _sortBy = filter;
                          });
                          _loadChallenges();
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 필터링된 챌린지 리스트
                  if (_filteredChallenges.isNotEmpty)
                    ..._filteredChallenges.map((challenge) {
                      final categoryType = _parseCategoryType(
                        challenge['category'],
                      );
                      final hostText =
                          challenge['host']?.toString() ?? '주최자 정보 없음';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ChallengeItem(
                          categoryType: categoryType ?? CategoryType.NATURE,
                          title: challenge['title']?.toString() ?? '제목 없음',
                          location: hostText,
                          contestId: challenge['contestId'] ?? 0,
                        ),
                      );
                    })
                  else
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text('챌린지가 없습니다')),
                    ),
                ],
              ),
            ),
    );
  }
}
