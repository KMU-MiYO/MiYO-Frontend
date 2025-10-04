import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';

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
    );
  }
}
