import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miyo/screens/imaginary_map/suggestion_item.dart';

class SuggestionTop3 extends StatelessWidget {
  final CategoryType? categoryType;
  final String title;
  final String writer;
  final int rank; // 1, 2, 3
  final VoidCallback? onTap;

  const SuggestionTop3({
    super.key,
    required this.categoryType,
    required this.title,
    required this.writer,
    required this.rank,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            width: 300,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xff00AA5D), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xffF0F2F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: _buildIcon(context)),
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
                        '작성자: $writer',
                        style: TextStyle(fontSize: 14, color: Color(0xff61758A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 메달 아이콘
          Positioned(
            left: -8,
            top: -8,
            child: Image.asset(
              'assets/images/medal_$rank.png',
              width: 30,
              height: 30,
            ),
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
