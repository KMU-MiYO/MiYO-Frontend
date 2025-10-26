import 'package:flutter/material.dart';

class ChallengeMission extends StatelessWidget {
  final String title;
  final int progress;
  final int total;

  const ChallengeMission({
    super.key,
    required this.title,
    required this.progress,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    double progressValue = progress / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Color(0xffD6D6D6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text('($progress/$total)', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Color(0xffD6D6D6),
              valueColor: const AlwaysStoppedAnimation(Color(0xff00AA5D)),
              minHeight: 13,
            ),
          ),
        ],
      ),
    );
  }
}