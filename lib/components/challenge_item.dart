import 'package:flutter/material.dart';
import 'package:miyo/screens/challenge_detail_screen.dart';

class ChallengeItem extends StatelessWidget {
  // final IconData icon;
  final CategoryType? categoryType;
  final String title;
  final String location;

  const ChallengeItem({
    super.key,
    required this.categoryType,
    required this.title,
    required this.location,
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
            child: _buildIcon(context),
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

  Widget? _buildIcon(BuildContext context) {
    if (categoryType == null) return null;

    switch (categoryType!) {
      case CategoryType.NaturePark:
        return Icon(Icons.park_rounded);

      case CategoryType.CultureArts:
        return Icon(Icons.color_lens);

      case CategoryType.Transport:
        return Icon(Icons.directions_bus);

      case CategoryType.Life:
        return Icon(Icons.house_rounded);

      case CategoryType.Commercial:
        return Icon(Icons.attach_money_rounded);

      case CategoryType.NightLandscape:
        return Icon(Icons.landscape_rounded);

      case CategoryType.EnvironSustain:
        return Icon(Icons.eco_rounded);
    }
  }
}

enum CategoryType {
  NaturePark, // 자연/공원
  CultureArts, // 문화/예술
  Transport, // 교통/이동
  Life, // 주거/생활
  Commercial, // 상권/시장
  NightLandscape, // 야간/경관
  EnvironSustain, // 환경/지속가능
}
