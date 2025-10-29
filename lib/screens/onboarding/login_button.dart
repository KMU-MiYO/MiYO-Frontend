import 'package:flutter/material.dart';
import 'package:miyo/data/services/user_service.dart';
import 'package:miyo/layout.dart';
import 'package:miyo/screens/onboarding/finding_id_pw/finding_pwid_screen.dart';
import 'package:miyo/screens/onboarding/signup_screen.dart';

class LoginButtons extends StatefulWidget {
  const LoginButtons({super.key});

  @override
  State<LoginButtons> createState() => _LoginButtonsState();
}

class _LoginButtonsState extends State<LoginButtons> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final UserService _userService = UserService();

  bool _isLoading = false;

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final id = idController.text;
    final password = passwordController.text;

    if (id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('아이디와 비밀번호를 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _userService.login(
        userId: id,
        password: password,
      );

      if (!mounted) return;

      // 로그인 성공 - 홈 화면으로 이동
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 성공!'),
          backgroundColor: Color(0xff00AA5D),
        ),
      );

      // 예시: 로그인 성공 후 홈으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Layout()),
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



  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(
          height: height * 0.06,
          width: width * 0.8,
          child: TextField(
            controller: idController,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xff757575),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 15
              ),
              hintText: '아이디',
              hintStyle: const TextStyle(
                fontSize: 15,
                color: Color(0xff757575),
              ),
              border: UnderlineInputBorder(

              ),
            ),
          ),
        ),
        SizedBox(height: height * 0.02),

        SizedBox(
          height: height * 0.06,
          width: width * 0.8,
          child: TextField(
            obscureText: true,
            controller: passwordController,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xff757575),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 15
              ),
              hintText: '비밀번호',
              hintStyle: const TextStyle(
                fontSize: 15,
                color: Color(0xff757575),
              ),
              border: UnderlineInputBorder(
              ),
            ),
          ),
        ),
        SizedBox(height: height * 0.05),

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
            onPressed: _isLoading ? null : _handleLogin,
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
                    '로그인',
                    style: TextStyle(
                      color: Color(0xffffffff),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '아직 회원이 아니신가요?',
              style: TextStyle(
                color: Color(0xffACACAC),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              }, 
              child: Text(
                '회원가입 하기',
                style: TextStyle(
                  color: Color(0xff00AA5D),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FindingPwidScreen(initialIsFindingId: true),
                  ),
                );
              },
              child: Text(
                '아이디',
                style: TextStyle(
                  color: Color(0xffACACAC),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '|',
              style: TextStyle(
                color: Color(0xffACACAC),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FindingPwidScreen(initialIsFindingId: false),
                  ),
                );
              },
              child: Text(
                '비밀번호 찾기',
                style: TextStyle(
                  color: Color(0xffACACAC),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}