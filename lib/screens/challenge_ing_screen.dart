import 'package:flutter/material.dart';
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
    );
  }
}
