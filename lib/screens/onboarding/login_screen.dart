import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/miyo_logo.png',
              width: MediaQuery.of(context).size.width * 0.3,
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.8,
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
          ],
        ),
      ),
    );
  }
}