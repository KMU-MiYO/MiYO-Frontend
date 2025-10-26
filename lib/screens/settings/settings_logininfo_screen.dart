import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/data/services/user_service.dart';
import 'package:miyo/screens/settings/settings_buildInfo.dart';
import 'package:miyo/screens/settings/settings_button.dart';

class SettingsLoginInfoScreen extends StatefulWidget {
  const SettingsLoginInfoScreen({super.key});

  @override
  State<SettingsLoginInfoScreen> createState() =>
      _SettingsLoginInfoScreenState();
}

class _SettingsLoginInfoScreenState extends State<SettingsLoginInfoScreen> {
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
    return Scaffold(
      appBar: TitleAppbar(title: "로그인 정보", leadingType: LeadingType.close),
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 로딩 중
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 에러 발생
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserInfo,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 유저 정보 표시
    if (_userInfo == null) {
      return const Center(child: Text('유저 정보가 없습니다.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsBuildinfo(label: '아이디', value: _userInfo!['id'] ?? '-'),
          SettingsBuildinfo(label: '이메일', value: _userInfo!['email'] ?? '-'),
          SettingButton(label: '비밀번호 변경', showBorder: false, onTap: () {}),
          SettingButton(
            label: '계정 탈퇴',
            textColor: Color(0xffE20000),
            showBorder: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
