import 'package:flutter/material.dart';
import 'package:miyo/screens/challenges/challenge_detail_screen.dart';

class ChallengeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String location;
  final bool isTitleBox;

  const ChallengeItem({
    super.key,
    required this.icon,
    required this.title,
    required this.location,
    this.isTitleBox = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xffF0F2F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 28, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '주관: $location',
                  style: TextStyle(fontSize: 14, color: Color(0xff61758A)),
                ),
              ],
            ),
          ),
          if (!isTitleBox)
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 37),
              color: const Color(0xff757575),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChallengeDetailScreen(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
