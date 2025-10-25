import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/data/services/user_service.dart';
import 'package:miyo/screens/settings/settings_button.dart';
import 'package:miyo/screens/settings/settings_buildProfileCard.dart';

class SettingsChallengeProfileScreen extends StatefulWidget {
  const SettingsChallengeProfileScreen({super.key});

  @override
  State<SettingsChallengeProfileScreen> createState() =>
      _SettingsChallengeProfileScreenState();
}

class _SettingsChallengeProfileScreenState
    extends State<SettingsChallengeProfileScreen> {
  final UserService _userService = UserService();

  // 유저 정보 상태
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// 유저 정보 불러오기
  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userInfo = await _userService.getCurrentUser();
      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '유저 정보를 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: TitleAppbar(title: "챌린지 프로필 관리", leadingType: LeadingType.close),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SettingsBuildProfileCard(
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                userInfo: _userInfo,
              ),
              SizedBox(height: height * 0.01),
              SettingButton(label: '닉네임 변경', showBorder: false),
            ],
          ),
        ),
      ),
    );
  }
}
