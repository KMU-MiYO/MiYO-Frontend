import 'package:flutter/material.dart';
import 'package:miyo/screens/onboarding/login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

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
            Image.asset(
              'assets/images/miyo_logo.png',
              width: width * 0.3,
            ),
            Text(
                  'MiYO',
                  style: TextStyle(
                    color: Color(0xff00AA5D),
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 0.9,
                  ),
                ),
            Text(
              'Map it Your Own',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff00AA5D),
                fontWeight: FontWeight.w400,
                height: 0.9,
                letterSpacing: -1,
              )
            ),
            SizedBox(height: height * 0.05),
            LoginButtons(),
          ]
        ),
      ),
    );
  }
}