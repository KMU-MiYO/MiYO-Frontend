import 'package:flutter/material.dart';

class SignupCompleteScreen extends StatefulWidget {
  const SignupCompleteScreen({super.key});

  @override
  State<SignupCompleteScreen> createState() => _SignupCompleteScreenState();
}

class _SignupCompleteScreenState extends State<SignupCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('회원가입이 완료되었습니다!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: height * 0.05),
            Icon(
              Icons.check_circle, 
              size: 100, 
              color: Color(0xff00AA5D)
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
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst); 
                  // 초기 화면으로 돌아가기 회원가입 -> 로그인 절차라면. 아니면 그냥 홈화면으로 이동해도 됨
                },
                child: Text(
                  '회원가입 완료',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}