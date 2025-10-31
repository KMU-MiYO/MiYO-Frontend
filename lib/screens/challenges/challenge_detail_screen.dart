import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/screens/challenges/challenge_item.dart';
import 'package:miyo/screens/imaginary_map/suggestion_top3.dart';
import 'package:miyo/screens/imaginary_map/suggestion_item.dart'
    as suggestion_lib;
import 'package:miyo/screens/suggestion/suggestion_detail_screen.dart';
import 'package:miyo/screens/suggestion/suggestion_screen.dart';
import 'package:miyo/data/services/challenge_service.dart';
import 'package:miyo/screens/suggestion/suggestion_all_screen.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final int contestId;

  const ChallengeDetailScreen({super.key, required this.contestId});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final ChallengeService _challengeService = ChallengeService();
  Map<String, dynamic>? contestData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContestData();
  }

  Future<void> _loadContestData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _challengeService.getContestById(
        contestId: widget.contestId,
      );
      print('📦 챌린지 데이터: $data');
      setState(() {
        contestData = data;
        isLoading = false;
      });
    } catch (e) {
      print('❌ 챌린지 로드 실패: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('챌린지를 불러오는데 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 카테고리 문자열을 CategoryType enum으로 변환
  CategoryType _parseCategoryType(String? category) {
    if (category == null) return CategoryType.NATURE;

    switch (category.toUpperCase()) {
      case 'NATURE':
        return CategoryType.NATURE;
      case 'CULTURE':
        return CategoryType.CULTURE;
      case 'TRAFFIC':
        return CategoryType.TRAFFIC;
      case 'RESIDENCE':
        return CategoryType.RESIDENCE;
      case 'COMMERCE':
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // 로딩 중
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: TitleAppbar(title: '챌린지 정보', leadingType: LeadingType.close),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xff00AA5D)),
        ),
      );
    }

    // 데이터 로드 실패
    if (contestData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: TitleAppbar(title: '챌린지 정보', leadingType: LeadingType.close),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '챌린지를 불러올 수 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }

    final topPosts = (contestData!['topPosts'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: TitleAppbar(title: '챌린지 정보', leadingType: LeadingType.close),
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00AA5D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () async {
              // 챌린지 참여 화면으로 이동
              final latitude = contestData?['latitude'] as double?;
              final longitude = contestData?['longitude'] as double?;

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuggestionScreen(
                    isContest: true,
                    contestId: widget.contestId,
                    latitude: latitude,
                    longitude: longitude,
                  ),
                ),
              );

              // 게시글 작성 완료 후 돌아왔을 때 데이터 새로고침
              if (result != null) {
                print('✅ 게시글 작성 완료, 챌린지 데이터 새로고침');
                _loadContestData();
              }
            },
            child: const Text(
              '참여하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ChallengeItem(
                categoryType: _parseCategoryType(contestData!['category']),
                title: contestData!['title'] ?? '제목 없음',
                location: contestData!['host'] ?? '주최자 미상',
                contestId: widget.contestId,
              ),
              SizedBox(
                width: width,
                child: Divider(color: Color(0x3E000000), thickness: 1.0),
              ),
              SizedBox(height: 17),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '챌린지 정보',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 13),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '기간',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${contestData!['startDate'] ?? ''} ~ ${contestData!['endDate'] ?? ''}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 7),
                        const Text(
                          '설명',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          contestData!['description'] ?? '설명이 없습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 7),
                        const Text(
                          '참여자 수',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${contestData!['participantCount'] ?? 0}명',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 7),
                        const Text(
                          '제출된 글',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${contestData!['submissionCount'] ?? 0}개',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  const Text(
                    '보상',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 13),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (contestData!['reward1st'] != null)
                          Text(
                            '1등 : ${contestData!['reward1st']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        if (contestData!['reward2nd'] != null)
                          Text(
                            '2등 : ${contestData!['reward2nd']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        if (contestData!['reward3rd'] != null)
                          Text(
                            '3등 : ${contestData!['reward3rd']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (contestData!['rewardDescription'] != null) ...[
                    SizedBox(height: 14),
                    Text(
                      '*${contestData!['rewardDescription']}*',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '제안',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // 챌린지 제안 리스트 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SuggestionAllScreen(contestId: widget.contestId),
                        ),
                      );
                    },
                    child: Text(
                      '+ 더보기',
                      style: TextStyle(
                        color: Color.fromRGBO(97, 117, 138, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 17),
              if (topPosts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    '아직 제안이 없습니다.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                )
              else
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    itemCount: topPosts.length > 3 ? 3 : topPosts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final post = topPosts[index];
                      return SuggestionTop3(
                        categoryType: _getSuggestionCategoryType(
                          post['category'],
                        ),
                        title: post['title'] ?? '제목 없음',
                        writer: post['userId'] ?? '익명',
                        rank: index + 1,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SuggestionDetailScreen(
                                postId: post['id'] ?? post['postId'] ?? 0,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// SuggestionTop3용 카테고리 변환 (suggestion_item.dart의 CategoryType)
  suggestion_lib.CategoryType _getSuggestionCategoryType(String? category) {
    switch (category?.toUpperCase()) {
      case 'NATURE':
        return suggestion_lib.CategoryType.NATURE;
      case 'CULTURE':
        return suggestion_lib.CategoryType.CULTURE;
      case 'TRAFFIC':
        return suggestion_lib.CategoryType.TRAFFIC;
      case 'RESIDENCE':
        return suggestion_lib.CategoryType.RESIDENCE;
      case 'COMMERCE':
      case 'COMMERCIAL':
        return suggestion_lib.CategoryType.COMMERCIAL;
      case 'NIGHT':
        return suggestion_lib.CategoryType.NIGHT;
      case 'ENVIRONMENT':
        return suggestion_lib.CategoryType.ENVIRONMENT;
      default:
        return suggestion_lib.CategoryType.NATURE;
    }
  }
}
