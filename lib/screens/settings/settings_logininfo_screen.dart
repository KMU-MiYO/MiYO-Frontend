import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/data/services/user_service.dart';
import 'package:miyo/screens/onboarding/initial_screen.dart';
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

  /// 계정 탈퇴 확인 다이얼로그
  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          '계정 탈퇴',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: const Text('정말 계정을 탈퇴하시겠습니까?\n탈퇴 후에는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xffE20000),
            ),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  /// 계정 탈퇴 처리
  Future<void> _deleteAccount() async {
    try {
      await _userService.deleteAccount();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('계정이 탈퇴되었습니다.')));

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const InitialScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('계정 탈퇴에 실패했습니다: $e')));
      }
    }
  }

  /// 비밀변호 변경 확인 다이얼로그
  Future<void> _showChangePwdDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          '비밀번호 변경',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: const Text('비밀번호를 변경하시겠습니까?\n가입하신 이메일로 재설정 링크를 보내드립니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xffE20000),
            ),
            child: const Text('변경'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _changepwd();
    }
  }

  /// 비밀번호 변경 요청 처리
  Future<void> _changepwd() async {
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _userService.changePwd(_userInfo!['email']);

      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('가입하신 이메일로 메일이 전송되었습니다.'),
            backgroundColor: Color(0xff00AA5D),
          ),
        );
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호 요청 변경을 실패하였습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          SettingsBuildinfo(label: '아이디', value: _userInfo!['userId'] ?? '-'),
          SettingsBuildinfo(label: '이메일', value: _userInfo!['email'] ?? '-'),
          SettingButton(
            label: '비밀번호 변경',
            showBorder: false,
            onTap: _showChangePwdDialog,
          ),
          SettingButton(
            label: '계정 탈퇴',
            textColor: Color(0xffE20000),
            showBorder: false,
            onTap: _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }
}
