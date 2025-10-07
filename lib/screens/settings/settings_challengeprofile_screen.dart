import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';

class SettingsChallengeProfileScreen extends StatefulWidget {
  const SettingsChallengeProfileScreen({super.key});

  @override
  State<SettingsChallengeProfileScreen> createState() =>
      _SettingsChallengeProfileScreenState();
}

class _SettingsChallengeProfileScreenState
    extends State<SettingsChallengeProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppbar(title: "챌린지 프로필 관리", leadingType: LeadingType.close),
      backgroundColor: Colors.white,
    );
  }
}
