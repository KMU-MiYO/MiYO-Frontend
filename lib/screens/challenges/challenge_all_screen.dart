import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/data/dummy/dummy_challenges.dart';
import 'package:miyo/screens/challenges/challenge_item.dart';

class ChallengeAllScreen extends StatefulWidget {
  const ChallengeAllScreen({super.key});

  @override
  State<ChallengeAllScreen> createState() => _ChallengeAllScreen();
}

class _ChallengeAllScreen extends State<ChallengeAllScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppbar(title: '전체 챌린지', leadingType: LeadingType.back),
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: allDummyChallenges.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final challenge = allDummyChallenges[index];
          return ChallengeItem(
            categoryType: challenge['categoryType'] as CategoryType,
            title: challenge['title'] as String,
            location: challenge['location'] as String,
          );
        },
      ),
    );
  }
}
