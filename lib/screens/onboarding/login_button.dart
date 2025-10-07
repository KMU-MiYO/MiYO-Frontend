import 'package:flutter/material.dart';
import 'package:miyo/screens/onboarding/login_screen.dart';

class LoginButtons extends StatelessWidget {
  LoginButtons({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
            controller: emailController,
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
              hintText: '이메일',
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
            onPressed: () {
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginScreen()));                
            }, 
            child: Text(
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
              onPressed: () {}, 
              child: Text(
                '회원가입 하기',
                style: TextStyle(
                  color: Color(0xff00AA5D),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
              onPressed: () {},
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
              onPressed: () {},
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