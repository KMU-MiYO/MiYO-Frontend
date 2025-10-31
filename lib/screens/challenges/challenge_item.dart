import 'package:flutter/material.dart';
import 'package:miyo/screens/challenges/challenge_detail_screen.dart';

class ChallengeItem extends StatelessWidget {
  // final IconData icon;
  final CategoryType? categoryType;
  final String title;
  final String location;
  final int contestId;
  final VoidCallback? onTap;
  final bool isChallengeDetailTile;

  const ChallengeItem({
    super.key,
    required this.categoryType,
    required this.title,
    required this.location,
    required this.contestId,
    this.isChallengeDetailTile = false,
    this.onTap,
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
          isChallengeDetailTile
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.chevron_right, size: 37),
                  color: const Color(0xff757575),
                  onPressed:
                      onTap ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChallengeDetailScreen(contestId: contestId),
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
      case CategoryType.NATURE:
        return Image.asset(
          'assets/images/challenge_icons/NaturePark.png',
          width: 32,
          height: 32,
        );

      case CategoryType.CULTURE:
        return Image.asset(
          'assets/images/challenge_icons/CultureArts.png',
          width: 32,
          height: 32,
        );

      case CategoryType.TRAFFIC:
        return Image.asset(
          'assets/images/challenge_icons/Transport.png',
          width: 32,
          height: 32,
        );

      case CategoryType.RESIDENCE:
        return Image.asset(
          'assets/images/challenge_icons/Life.png',
          width: 32,
          height: 32,
        );

      case CategoryType.COMMERCIAL:
        return Image.asset(
          'assets/images/challenge_icons/Commercial.png',
          width: 32,
          height: 32,
        );

      case CategoryType.NIGHT:
        return Image.asset(
          'assets/images/challenge_icons/NightLandscape.png',
          width: 32,
          height: 32,
        );

      case CategoryType.ENVIRONMENT:
        return Image.asset(
          'assets/images/challenge_icons/EnvironSustain.png',
          width: 32,
          height: 32,
        );
    }
  }
}

enum CategoryType {
  NATURE, // 자연/공원
  CULTURE, // 문화/예술
  TRAFFIC, // 교통/이동
  RESIDENCE, // 주거/생활
  COMMERCIAL, // 상권/시장
  NIGHT, // 야간/경관
  ENVIRONMENT, // 환경/지속가능
}
