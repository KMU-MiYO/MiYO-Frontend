import 'package:flutter/material.dart';
import 'package:miyo/screens/settings/settings_button.dart';

class SettingsApplicationSection extends StatelessWidget {
  const SettingsApplicationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "어플리케이션",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: height * 0.01),
        SettingButton(label: "알림 설정"),
        SettingButton(label: "언어"),
      ],
    );
  }
}
