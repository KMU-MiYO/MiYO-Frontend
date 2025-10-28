import 'package:flutter/material.dart';
import 'package:miyo/data/services/user_service.dart';
import 'package:miyo/screens/onboarding/initial_screen.dart';
import 'package:miyo/screens/settings/settings_button.dart';
import 'package:miyo/screens/settings/settings_challengeprofile_screen.dart';
import 'package:miyo/screens/settings/settings_logininfo_screen.dart';

class SettingsAccountSection extends StatelessWidget {
  const SettingsAccountSection({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // UserService의 로그아웃 기능 호출
      final userService = UserService();
      await userService.logout();

      // 로그아웃 성공 시 초기 화면으로 이동 (스택 초기화)
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const InitialScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // 에러 발생 시 사용자에게 알림
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
          onTap: () => _handleLogout(context),
        ),
      ],
    );
  }
}
