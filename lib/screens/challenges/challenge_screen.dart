import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/screens/challenges/challenge_mission.dart';
import 'package:miyo/screens/challenges/challenge_item.dart';
import 'package:miyo/screens/challenges/challenge_all_screen.dart';
import 'package:miyo/screens/challenges/challenge_ing_screen.dart';
import 'package:miyo/data/services/challenge_service.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final ChallengeService _challengeService = ChallengeService();

  List<dynamic> _allChallenges = [];
  List<dynamic> _ingChallenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
    _loadParticipatingChallenges();
  }

  // 전체 챌린지 조회
  Future<void> _loadChallenges() async {
    try {
      final response = await _challengeService.loadAllChallenges();

      setState(() {
        _allChallenges = response.take(3).toList();
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 참여 중 챌린지 조회
  Future<void> _loadParticipatingChallenges() async {
    try {
      final response = await _challengeService.loadIngChallenges();

      setState(() {
        _ingChallenges = response.take(3).toList();
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  CategoryType? _parseCategoryType(String? category) {
    if (category == null) return null;

    switch (category.toUpperCase()) {
      case 'NATURE':
        return CategoryType.NaturePark;
      case 'CULTURE':
        return CategoryType.CultureArts;
      case 'TRAFFIC':
        return CategoryType.Transport;
      case 'RESIDENCE':
        return CategoryType.Life;
      case 'COMMERCIAL':
        return CategoryType.Commercial;
      case 'NIGHT':
        return CategoryType.NightLandscape;
      case 'ENVIRONMENT':
        return CategoryType.EnvironSustain;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const TitleAppbar(title: '챌린지'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 주간 미션 섹션
              const Text(
                '주간 미션',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const ChallengeMission(title: '제안 5번 하기', progress: 1, total: 5),
              const SizedBox(height: 16),
              const ChallengeMission(title: '공감 3번 하기', progress: 2, total: 3),

              SizedBox(height: height * 0.02),

              // 참가 중인 챌린지 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '참가 중인 챌린지',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChallengeIngScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '더보기',
                      style: TextStyle(color: Color(0xff61758A), fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _ingChallenges.isEmpty
                  ? const Text('참여 중인 챌린지가 없습니다.')
                  : Column(
                      children: _ingChallenges.map((challenge) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ChallengeItem(
                            categoryType: _parseCategoryType(
                              challenge['category'],
                            ),
                            title: challenge['title'] ?? '',
                            location: challenge['host'] ?? '',
                          ),
                        );
                      }).toList(),
                    ),

              SizedBox(height: height * 0.015),

              // 전체 챌린지 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '전체 챌린지',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChallengeAllScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '더보기',
                      style: TextStyle(color: Color(0xff61758A), fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _allChallenges.isEmpty
                  ? const Text('진행 중인 챌린지가 없습니다.')
                  : Column(
                      children: _allChallenges.map((challenge) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ChallengeItem(
                            categoryType: _parseCategoryType(
                              challenge['category'],
                            ),
                            title: challenge['title'] ?? '',
                            location: challenge['host'] ?? '',
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
