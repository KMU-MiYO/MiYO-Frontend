import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';

class ChallengeDetailScreen extends StatefulWidget {
  const ChallengeDetailScreen({super.key});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreen();
}

class _ChallengeDetailScreen extends State<ChallengeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppbar(title: '챌린지 정보', leadingType: LeadingType.close),
      backgroundColor: Colors.white,
    );
  }
}
