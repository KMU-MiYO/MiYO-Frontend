import 'package:flutter/material.dart';
import 'package:miyo/screens/onboarding/login_screen.dart';

class InitialButtons extends StatelessWidget {
  const InitialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(
          height: height * 0.06,
          width: width * 0.8,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text(
              '로그인',
              style: TextStyle(
                color: Color(0xff00AA5D),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(height:  height* 0.02),
        SizedBox(
          height: height * 0.06,
          width: width * 0.8,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff00AA5D),
              side: BorderSide(
                color: Colors.white
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
            ),
            onPressed: () {}, 
            child: Text(
              '회원가입',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            ),
          ),
        ),
      ],
    );
  }
}