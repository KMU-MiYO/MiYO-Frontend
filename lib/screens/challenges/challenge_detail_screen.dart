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

      setState(() {
        contestData = data;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
    // 로딩 중
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const TitleAppbar(
          title: '챌린지 정보',
          leadingType: LeadingType.close,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xff00AA5D)),
        ),
      );
    }

    // 데이터 로드 실패
    if (contestData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const TitleAppbar(
          title: '챌린지 정보',
          leadingType: LeadingType.close,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '챌린지를 불러올 수 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final topPosts = (contestData!['topPosts'] as List<dynamic>?) ?? [];
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const TitleAppbar(
        title: '챌린지 정보',
        leadingType: LeadingType.close,
      ),
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
              try {
                // 챌린지 참가 API 호출
                await _challengeService.joinContest(
                  contestId: widget.contestId,
                );

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
                  _loadContestData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('챌린지 참가에 실패했습니다.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
          // padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChallengeItem(
                categoryType: _parseCategoryType(contestData!['category']),
                title: contestData!['title'] ?? '제목 없음',
                location: contestData!['host'] ?? '주최자 미상',
                contestId: widget.contestId,
                isChallengeDetailTile: true,
              ),
              const Divider(color: Color(0x3E000000), thickness: 1.0),
              const SizedBox(height: 17),

              // 챌린지 정보 섹션
              const Text(
                '챌린지 정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 13),

              Container(
                padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      '기간',
                      '${contestData!['startDate'] ?? ''} ~ ${contestData!['endDate'] ?? ''}',
                    ),
                    _buildInfoRow(
                      '설명',
                      contestData!['description'] ?? '설명이 없습니다.',
                    ),
                    _buildInfoRow(
                      '참여자 수',
                      '${contestData!['participantCount'] ?? 0}명',
                    ),
                    _buildInfoRow(
                      '제출된 글',
                      '${contestData!['submissionCount'] ?? 0}개',
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.02),

              // 보상 섹션
              const Text(
                '보상',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 13),
              Container(
                padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (contestData!['reward1st'] != null)
                      Text('1등 : ${contestData!['reward1st']}'),
                    if (contestData!['reward2nd'] != null)
                      Text('2등 : ${contestData!['reward2nd']}'),
                    if (contestData!['reward3rd'] != null)
                      Text('3등 : ${contestData!['reward3rd']}'),
                    if (contestData!['rewardDescription'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '*${contestData!['rewardDescription']}*',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: height * 0.03),

              // 제안 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '제안',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuggestionAllScreen(
                            contestId: widget.contestId,
                            isChallenge: true,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      '+ 더보기',
                      style: TextStyle(
                        color: Color.fromRGBO(97, 117, 138, 1),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.005),

              if (topPosts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: topPosts.length > 3 ? 3 : topPosts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final post = topPosts[index];
                      // 게시글 category가 null이면 챌린지 category 사용
                      final categoryToUse =
                          post['category'] ?? contestData!['category'];
                      return SuggestionTop3(
                        categoryType: _getSuggestionCategoryType(categoryToUse),
                        title: post['title'] ?? '제목 없음',
                        writer: post['userId'] ?? '익명',
                        rank: index + 1,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SuggestionDetailScreen(
                                postId: post['id'] ?? 0,
                                isChallenge: true,
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

  /// 정보 라벨 + 값
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                height: 1.4,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  /// SuggestionTop3용 카테고리 변환
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
