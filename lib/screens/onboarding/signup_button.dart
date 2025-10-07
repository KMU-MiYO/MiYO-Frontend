import 'package:flutter/material.dart';
import 'package:miyo/screens/onboarding/login_screen.dart';

class SignupButton extends StatefulWidget {
  const SignupButton({super.key});

  @override
  State<SignupButton> createState() => _SignupButtonState();
}

class _SignupButtonState extends State<SignupButton> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController verificationCodeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordVerificationController = TextEditingController();

  // text 조건 달성 여부
  bool? isIdValid; // null: 회색, true: 초록, false: 빨강
  bool? isEmailValid;
  bool? isVerificationCodeValid;
  bool? isPasswordValid;
  bool? isPasswordConfirmValid;

  @override
  void initState() {
    super.initState();

    idController.addListener(_validateId);

    emailController.addListener(_validateEmail);
    verificationCodeController.addListener(_validateVerificationCode);
    passwordController.addListener(_validatePassword);
    passwordVerificationController.addListener(_validatePasswordConfirm);
  }

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    nicknameController.dispose();
    verificationCodeController.dispose();
    emailController.dispose();
    passwordVerificationController.dispose();
    super.dispose();
  }

  void _validateId() {
    setState(() {
      final id = idController.text;
      if (id.isEmpty) {
        isIdValid = null;
      } else {
        // TODO: API 호출로 중복 확인 후 결과에 따라 isIdValid 설정
        // 임시: 영어/숫자 4자리 이상 체크
        isIdValid = RegExp(r'^[a-zA-Z0-9]{4,}$').hasMatch(id);
      }
    });
  }

  void _validateEmail() {
    setState(() {
      final email = emailController.text;
      if (email.isEmpty) {
        isEmailValid = null;
      } else {
        // TODO: API 호출로 이메일 형식 및 중복 확인 후 결과에 따라 isEmailValid 설정
        // 임시: 이메일 형식 체크
        isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      }
    });
  }

  void _validateVerificationCode() {
    setState(() {
      final code = verificationCodeController.text;
      if (code.isEmpty) {
        isVerificationCodeValid = null;
      } else {
        // TODO: API 호출로 인증 코드 확인 후 결과에 따라 isVerificationCodeValid 설정
        // 임시: 6자리 숫자 체크
        isVerificationCodeValid = RegExp(r'^\d{6}$').hasMatch(code);
      }
    });
  }

  void _validatePassword() {
    setState(() {
      final password = passwordController.text;
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
      final confirm = passwordVerificationController.text;
      if (confirm.isEmpty) {
        isPasswordConfirmValid = null;
      } else {
        isPasswordConfirmValid = confirm == passwordController.text;
      }
    });
  }

  Color _getValidationColor(bool? isValid) {
    if (isValid == null) return Color(0xff757575);
    return isValid ? Color(0xff00AA5D) : Colors.red;
  }

  bool get _isAllValid {
    return isIdValid == true &&
           isEmailValid == true &&
           isVerificationCodeValid == true &&
           isPasswordValid == true &&
           isPasswordConfirmValid == true;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: height * 0.05),
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
              width: width * 0.56,
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
              width: width * 0.22,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff00AA5D),
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
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
                  color: _getValidationColor(isIdValid),
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
              width: width * 0.56,
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
              width: width * 0.22,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff00AA5D),
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
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
                  color: _getValidationColor(isEmailValid),
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
              width: width * 0.46,
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
              width: width * 0.32,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff00AA5D),
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
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
                  color: _getValidationColor(isVerificationCodeValid),
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
                  color: _getValidationColor(isPasswordValid),
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
                  color: _getValidationColor(isPasswordConfirmValid),
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
              backgroundColor: _isAllValid ? Color(0xff00AA5D) : Color(0xff757575),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isAllValid ? () {
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginScreen()));
            } : null,
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