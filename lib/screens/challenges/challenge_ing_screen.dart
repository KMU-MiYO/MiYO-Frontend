import 'package:flutter/material.dart';
import 'package:miyo/screens/challenges/challenge_item.dart';
import 'package:miyo/components/title_appbar.dart';

class ChallengeIngScreen extends StatefulWidget {
  const ChallengeIngScreen({super.key});

  @override
  State<ChallengeIngScreen> createState() => _ChallengeIngScreen();
}

class _ChallengeIngScreen extends State<ChallengeIngScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppbar(title: '참가 중인 챌린지', leadingType: LeadingType.close),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ChallengeItem(
                categoryType: CategoryType.NaturePark,
                title: "2026 우리 동네 공원 상상하기",
                location: "서울시",
              ),
              const SizedBox(height: 16),
              const ChallengeItem(
                categoryType: CategoryType.Life,
                title: "2026 성북구 편의시설 상상하기",
                location: "성북구",
              ),
              const SizedBox(height: 16),
              const ChallengeItem(
                categoryType: CategoryType.EnvironSustain,
                title: "2026 한강변 상상하기",
                location: "서울시",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
