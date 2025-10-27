import 'package:flutter/material.dart';
import 'package:miyo/screens/imaginary_map/suggestion_item.dart';

class SuggestionCategoryButton extends StatelessWidget {
  final CategoryType categoryType;
  final bool isSelected;
  final VoidCallback onTap;

  // 카테고리 이름 매핑
  static const Map<CategoryType, String> categoryNames = {
    CategoryType.NaturePark: '자연/공원',
    CategoryType.CultureArts: '문화/예술',
    CategoryType.Transport: '교통/이동',
    CategoryType.Life: '주거/생활',
    CategoryType.Commercial: '상권/시장',
    CategoryType.NightLandscape: '야간/조명',
    CategoryType.EnvironSustain: '환경/지속가능',
  };

  const SuggestionCategoryButton({
    super.key,
    required this.categoryType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff00AA5D) : Color(0xffF0F2F5),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Color(0xff00AA5D), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(width: 6),
            Text(
              categoryNames[categoryType] ?? '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : Color(0xff61758A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    String iconPath;
    switch (categoryType) {
      case CategoryType.NaturePark:
        iconPath = 'assets/images/challenge_icons/NaturePark.png';
        break;
      case CategoryType.CultureArts:
        iconPath = 'assets/images/challenge_icons/CultureArts.png';
        break;
      case CategoryType.Transport:
        iconPath = 'assets/images/challenge_icons/Transport.png';
        break;
      case CategoryType.Life:
        iconPath = 'assets/images/challenge_icons/Life.png';
        break;
      case CategoryType.Commercial:
        iconPath = 'assets/images/challenge_icons/Commercial.png';
        break;
      case CategoryType.NightLandscape:
        iconPath = 'assets/images/challenge_icons/NightLandscape.png';
        break;
      case CategoryType.EnvironSustain:
        iconPath = 'assets/images/challenge_icons/EnvironSustain.png';
        break;
    }

    return Image.asset(
      iconPath,
      width: 20,
      height: 20,
      color: isSelected ? Colors.white : Color(0xff61758A),
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
