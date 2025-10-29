import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/data/services/user_service.dart';
import 'package:miyo/screens/onboarding/login_screen.dart';

class FindingPwidScreen extends StatefulWidget {
  final bool initialIsFindingId; // true: 아이디 찾기, false: 비밀번호 찾기

  const FindingPwidScreen({
    super.key,
    this.initialIsFindingId = true, // 기본값은 아이디 찾기
  });

  @override
  State<FindingPwidScreen> createState() => _FindingPwidScreenState();
}

class _FindingPwidScreenState extends State<FindingPwidScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();
  final UserService _userService = UserService();

  bool _isLoading = false;
  late bool _isFindingId; // true: 아이디 찾기, false: 비밀번호 찾기
  bool _isPasswordResetConfirm = false;
  bool? isPasswordValid;
  bool? isPasswordConfirmValid;

  @override
  void initState() {
    super.initState();
    _isFindingId = widget.initialIsFindingId; // 전달받은 초기값으로 설정
    emailController.addListener(() {
      setState(() {}); // 이메일 입력 변경 시 버튼 상태 업데이트
    });
    newPasswordController.addListener(_validatePassword);
    passwordConfirmController.addListener(_validatePasswordConfirm);
    tokenController.addListener(() {
      setState(() {}); // 버튼 상태 업데이트
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    tokenController.dispose();
    newPasswordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    setState(() {
      final password = newPasswordController.text;
      if (password.isEmpty) {
        isPasswordValid = null;
      } else {
        // 영어/숫자/특수문자 2가지 이상 조합 8자리 이상
        int typeCount = 0;
        if (RegExp(r'[a-zA-Z]').hasMatch(password)) typeCount++;
        if (RegExp(r'[0-9]').hasMatch(password)) typeCount++;
        if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) typeCount++;
        isPasswordValid = password.length >= 8 && typeCount >= 2;
      }
    });
  }

  void _validatePasswordConfirm() {
    setState(() {
      final confirm = passwordConfirmController.text;
      if (confirm.isEmpty) {
        isPasswordConfirmValid = null;
      } else {
        isPasswordConfirmValid = confirm == newPasswordController.text;
      }
    });
  }

  Color _getValidationColor(bool? isValid) {
    if (isValid == null) return Color(0xff757575);
    return isValid ? Color(0xff00AA5D) : Colors.red;
  }

  bool get _isPasswordResetAllValid {
    return tokenController.text.isNotEmpty &&
           isPasswordValid == true &&
           isPasswordConfirmValid == true;
  }

  Future<void> _handleFindingId() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이메일을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 이메일 형식 검증
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('올바른 이메일 형식을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _userService.findUserId(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('아이디 정보가 이메일로 전송되었습니다.'),
          backgroundColor: Color(0xff00AA5D),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleFindingPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이메일을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 이메일 형식 검증
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('올바른 이메일 형식을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _userService.passwordResetRequest(email);

      if (!mounted) return;

      // 2단계로 전환
      setState(() {
        _isPasswordResetConfirm = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('인증 토큰이 이메일로 전송되었습니다.'),
          backgroundColor: Color(0xff00AA5D),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePasswordResetConfirm() async {
    if (!_isPasswordResetAllValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _userService.passwordResetConfirm(
        token: tokenController.text.trim(),
        newPassword: newPasswordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('비밀번호가 성공적으로 변경되었습니다.'),
          backgroundColor: Color(0xff00AA5D),
        ),
      );

      // 초기 상태로 리셋
      setState(() {
        _isPasswordResetConfirm = false;
        _isFindingId = true;
        emailController.clear();
        tokenController.clear();
        newPasswordController.clear();
        passwordConfirmController.clear();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: TitleAppbar(title: '아이디/비밀번호 찾기', leadingType: LeadingType.back),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.03),
              // 토글 버튼
              Container(
                height: height * 0.04,
                decoration: BoxDecoration(
                  color: Color(0xffF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFindingId = true;
                            emailController.clear();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isFindingId ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: _isFindingId
                                ? Border.all(color: Color(0xff00AA5D), width: 1)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '아이디 찾기',
                            style: TextStyle(
                              color: _isFindingId ? Color(0xff00AA5D) : Color(0xff757575),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFindingId = false;
                            emailController.clear();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_isFindingId ?  Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: _isFindingId
                                ? null
                                : Border.all(color: Color(0xff00AA5D), width: 1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '비밀번호 찾기',
                            style: TextStyle(
                              color: !_isFindingId ?  Color(0xff00AA5D) : Color(0xff757575),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.04),
              Text('가입시 입력한 이메일을 적어주세요.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!_isFindingId) ...[
                Text(
                  '이메일로 재설정 링크를 보내드립니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff757575),
                  ),
                ),
              ],
              SizedBox(height: height * 0.03),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: '이메일',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: height * 0.03),
              SizedBox(
                height: height * 0.06,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emailController.text.isNotEmpty
                        ? Color(0xff00AA5D)
                        : Color(0xff757575),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: emailController.text.isNotEmpty && !_isLoading
                      ? (_isFindingId ? _handleFindingId : _handleFindingPassword)
                      : null,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isFindingId ? '아이디 찾기' : '이메일 전송',
                          style: TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              if (_isPasswordResetConfirm) ...[
                SizedBox(height: height * 0.03),
                Text(
                  '메일을 전송했습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: height * 0.02),
                Text(
                  '링크에 접속하여 비밀번호를 재설정 해 주세요.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff757575),
                  ),
                ),
                SizedBox(height: height * 0.03),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: MediaQuery.of(context).size.width * 0.4,
                        color: Color(0xff00AA5D),
                      ),
                      SizedBox(height: height * 0.03),
                      SizedBox(
                        height: height * 0.06,
                        width: width * 0.8,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff00AA5D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                                  '로그인 하기',
                                  style: TextStyle(
                                    color: Color(0xffffffff),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}