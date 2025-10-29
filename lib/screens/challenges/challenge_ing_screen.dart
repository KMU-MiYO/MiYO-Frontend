import 'package:flutter/material.dart';
import 'package:miyo/screens/challenges/challenge_item.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/data/dummy/dummy_challenges.dart';

class ChallengeIngScreen extends StatefulWidget {
  const ChallengeIngScreen({super.key});

  @override
  State<ChallengeIngScreen> createState() => _ChallengeIngScreen();
}

class _ChallengeIngScreen extends State<ChallengeIngScreen> {
  @override
  Widget build(BuildContext context) {
    final participatingChallenges = getParticipatingChallenges();

    return Scaffold(
      appBar: TitleAppbar(title: '참가 중인 챌린지', leadingType: LeadingType.back),
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: participatingChallenges.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final challenge = participatingChallenges[index];
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
