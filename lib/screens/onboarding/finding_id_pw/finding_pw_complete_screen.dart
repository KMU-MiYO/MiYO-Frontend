import 'package:flutter/material.dart';
import 'package:miyo/screens/onboarding/login_screen.dart';

class FindingPwCompleteScreen extends StatefulWidget {
  const FindingPwCompleteScreen({super.key});

  @override
  State<FindingPwCompleteScreen> createState() => _FindingPwCompleteScreenState();
}

class _FindingPwCompleteScreenState extends State<FindingPwCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '메일을 전송했습니다.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '링크에 접속하여 비밀번호를 재설정 해 주세요.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff757575),
                    ),
                  ),
                ],
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
      ),
    );
  }
}