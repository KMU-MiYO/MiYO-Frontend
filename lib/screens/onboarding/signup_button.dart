import 'package:flutter/material.dart';
import 'package:miyo/screens/onboarding/login_screen.dart';

class SignupButton extends StatelessWidget {
  SignupButton({super.key});

  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController verificationCodeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordVerificationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: height * 0.06,
          width: width * 0.8,
          child: TextField(
            controller: nicknameController,
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
              hintText: '닉네임',
              hintStyle: const TextStyle(
                fontSize: 15,
                color: Color(0xff757575),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(
          width: width * 0.8,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4,),
              child: Text(
                '프로필 상의 이름을 설정해 주세요.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xffACACAC),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: height * 0.02),
            
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.06,
              width: width * 0.52,
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), 
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.02),
            SizedBox(
              height: height * 0.06,
              width: width * 0.27,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff00AA5D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  print('아이디 중복 확인');                
                }, 
                child: Text(
                  '중복 확인',
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
        SizedBox(
          width: width * 0.8,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4,),
              child: Text(
                '아이디는 영어/숫자 4자리 이상으로 설정해 주세요.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xffACACAC),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: height * 0.02),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.06,
              width: width * 0.52,
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), 
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.02),
            SizedBox(
              height: height * 0.06,
              width: width * 0.27,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff00AA5D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  print('코드 전송');                
                }, 
                child: Text(
                  '코드 전송',
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
        SizedBox(
          width: width * 0.8,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4,),
              child: Text(
                '이메일을 입력해 주세요.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xffACACAC),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: height * 0.02),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.06,
              width: width * 0.4,
              child: TextField(
                controller: verificationCodeController,
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
                  hintText: '인증 코드',
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    color: Color(0xff757575),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), 
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.02),
            SizedBox(
              height: height * 0.06,
              width: width * 0.4,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff00AA5D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  print('인증 코드 입력');                
                }, 
                child: Text(
                  '이메일 인증하기',
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
        SizedBox(
          width: width * 0.8,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4,),
              child: Text(
                '인증 코드를 입력해 주세요.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xffACACAC),
                  fontWeight: FontWeight.w600,
                ),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(
          width: width * 0.8,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4,),
              child: Text(
                '영어/숫자/특수문자 2가지 이상 조합 8자리 이상으로 설정해 주세요.',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xffACACAC),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: height * 0.02),
        SizedBox(
          height: height * 0.06,
          width: width * 0.8,
          child: TextField(
            controller: passwordVerificationController,
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
              hintText: '비밀번호 확인',
              hintStyle: const TextStyle(
                fontSize: 15,
                color: Color(0xff757575),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), 
              ),
            ),
          ),
        ),
        SizedBox(
          width: width * 0.8,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4,),
              child: Text(
                '비밀번호를 한 번 더 입력해 주세요.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xffACACAC),
                  fontWeight: FontWeight.w600,
                ),
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
              '회원가입',
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
              '이미 회원이신가요?',
              style: TextStyle(
                color: Color(0xffACACAC),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => LoginScreen()));                
              },               
            child: Text(
                '로그인 하기',
                style: TextStyle(
                  color: Color(0xff00AA5D),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}