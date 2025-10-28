import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/screens/onboarding/signup_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    scrolledUnderElevation: 0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TitleAppbar(title: '회원가입', leadingType: LeadingType.back),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SignupButton()
            ],
          ),
        ),
      ),
    );
  }
}