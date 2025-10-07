import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';

class SettingsLoginInfoScreen extends StatefulWidget {
  const SettingsLoginInfoScreen({super.key});

  @override
  State<SettingsLoginInfoScreen> createState() =>
      _SettingsLoginInfoScreenState();
}

class _SettingsLoginInfoScreenState extends State<SettingsLoginInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppbar(title: "로그인 정보", leadingType: LeadingType.close),
      backgroundColor: Colors.white,
    );
  }
}
