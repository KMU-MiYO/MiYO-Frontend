import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/screens/challenges/challenge_mission.dart';
import 'package:miyo/screens/challenges/challenge_item.dart';
import 'package:miyo/screens/challenges/challenge_all_screen.dart';
import 'package:miyo/screens/challenges/challenge_ing_screen.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  @override
  Widget build(BuildContext context) {
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

              const SizedBox(height: 32),

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
              const SizedBox(height: 12),
              const ChallengeItem(
                categoryType: CategoryType.NaturePark,
                title: '2026 우리 동네 공원 상상하기',
                location: '서울시',
              ),

              const SizedBox(height: 50),

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
              const SizedBox(height: 12),
              const ChallengeItem(
                categoryType: CategoryType.Life,
                title: '2026 성북구 편의시설 상상하기',
                location: '성북구',
              ),
              const SizedBox(height: 12),
              const ChallengeItem(
                categoryType: CategoryType.EnvironSustain,
                title: '2026 한강변 상상하기',
                location: '서울시',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
