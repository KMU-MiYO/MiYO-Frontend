import 'package:flutter/material.dart';

class SettingsBuildinfo extends StatelessWidget {
  final String label;
  final String value;

  const SettingsBuildinfo({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: height * 0.003),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Color(0xffACACAC)),
          ),
        ],
      ),
    );
  }
}
