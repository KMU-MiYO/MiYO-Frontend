import 'package:flutter/material.dart';
import 'package:miyo/screens/onboarding/initial_button.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xff00AA5D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/miyo_logo.png',
              width: width * 0.4,
            ),
            Text(
              'MiYO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w900,
                height: 0.9,
              ),
            ),
            Text(
              'Map it Your Own',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w400,
                height: 0.9,
                letterSpacing: -1,
              )
            ),
            SizedBox(height: height * 0.1),
            InitialButtons(),
          ],
        ),
      ),
    );
  }
}