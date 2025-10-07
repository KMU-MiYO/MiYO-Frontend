import 'package:flutter/material.dart';
import 'package:miyo/screens/settings/settings_button.dart';

class SettingsMyactivitySection extends StatelessWidget {
  const SettingsMyactivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "내 활동",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: height * 0.01),
        SettingButton(label: "내가 쓴 글"),
        SettingButton(label: "내가 좋아요한 글"),
        SettingButton(label: "내가 쓴 댓글"),
      ],
    );
  }
}
