import 'package:flutter/material.dart';
import 'package:miyo/screens/settings/settings_button.dart';
import 'package:miyo/screens/settings/settings_challengeprofile_screen.dart';
import 'package:miyo/screens/settings/settings_logininfo_screen.dart';

class SettingsAccountSection extends StatelessWidget {
  const SettingsAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '계정',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: height * 0.01),
        SettingButton(
          label: "로그인 정보",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsLoginInfoScreen(),
              ),
            );
          },
        ),
        SettingButton(
          label: "챌린지 프로필 관리",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsChallengeProfileScreen(),
              ),
            );
          },
        ),
        SettingButton(
          label: "로그아웃",
          showTrailingIcon: false,
          textColor: Color(0xffE60000),
        ),
      ],
    );
  }
}
