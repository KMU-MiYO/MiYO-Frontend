import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/screens/settings/settings_account_section.dart';
import 'package:miyo/screens/settings/settings_application_section.dart';
import 'package:miyo/screens/settings/settings_myactivity_section.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: TitleAppbar(title: "앱 설정", leadingType: LeadingType.back),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 계정 섹션
              SettingsAccountSection(),
              // // 내 활동 섹션
              // SizedBox(height: height * 0.02),
              // SettingsMyactivitySection(),
              // 어플리케이션 섹션
              SizedBox(height: height * 0.02),
              SettingsApplicationSection(),
            ],
          ),
        ),
      ),
    );
  }
}
