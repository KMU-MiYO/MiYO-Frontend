import 'package:flutter/material.dart';

enum ChallengeFilterType {
  newest, // 최신순
  popular, // 인기순
}

class ChallengeFilterButton extends StatelessWidget {
  final ChallengeFilterType selectedFilter;
  final Function(ChallengeFilterType) onFilterChanged;

  const ChallengeFilterButton({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const Map<ChallengeFilterType, String> filterNames = {
    ChallengeFilterType.newest: '최신순',
    ChallengeFilterType.popular: '인기순',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ChallengeFilterType>(
      onSelected: onFilterChanged,
      offset: const Offset(0, 40),
      color: Colors.white, // 팝업 메뉴 배경색 하얀색
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        _buildMenuItem(ChallengeFilterType.newest),
        _buildMenuItem(ChallengeFilterType.popular),
      ],
      child: Container(
        // 필터링 버튼
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Row 크기를 내용물에 맞춤
          children: [
            Text(
              filterNames[selectedFilter] ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff000000),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xff000000)),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<ChallengeFilterType> _buildMenuItem(ChallengeFilterType filterType) {
    final isSelected = selectedFilter == filterType;
    return PopupMenuItem<ChallengeFilterType>(
      value: filterType,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 끝 정렬
        children: [
          Text(
            filterNames[filterType] ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xff00AA5D) : const Color(0xff000000),
            ),
          ),
          if (isSelected) const Icon(Icons.check, size: 18, color: Color(0xff00AA5D)),
        ],
      ),
    );
  }
}

enum ChallengeCategoryType {
  all, // 카테고리
  nature, // 자연/공원
  culture, // 문화/예술
  traffic, // 교통/이동
  residence, // 주거/생활
  commercial, // 상권/시장
  night, // 야간/경관
  environment, // 환경/지속가능
}

class ChallengeCategoryButton extends StatelessWidget {
  final ChallengeCategoryType selectedCategory;
  final Function(ChallengeCategoryType) onCategoryChanged;

  const ChallengeCategoryButton({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  static const Map<ChallengeCategoryType, String> categoryNames = {
    ChallengeCategoryType.all: '카테고리',
    ChallengeCategoryType.nature: '자연/공원',
    ChallengeCategoryType.culture: '문화/예술',
    ChallengeCategoryType.traffic: '교통/이동',
    ChallengeCategoryType.residence: '주거/생활',
    ChallengeCategoryType.commercial: '상권/시장',
    ChallengeCategoryType.night: '야간/경관',
    ChallengeCategoryType.environment: '환경/지속가능',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ChallengeCategoryType>(
      onSelected: onCategoryChanged,
      offset: const Offset(0, 40),
      color: Colors.white, // 팝업 메뉴 배경색 하얀색
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        _buildMenuItem(ChallengeCategoryType.all),
        _buildMenuItem(ChallengeCategoryType.nature),
        _buildMenuItem(ChallengeCategoryType.culture),
        _buildMenuItem(ChallengeCategoryType.traffic),
        _buildMenuItem(ChallengeCategoryType.residence),
        _buildMenuItem(ChallengeCategoryType.commercial),
        _buildMenuItem(ChallengeCategoryType.night),
        _buildMenuItem(ChallengeCategoryType.environment),
      ],
      child: Container(
        // 필터링 버튼
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Row 크기를 내용물에 맞춤
          children: [
            Text(
              categoryNames[selectedCategory] ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff000000),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xff000000)),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<ChallengeCategoryType> _buildMenuItem(ChallengeCategoryType categoryType) {
    final isSelected = selectedCategory == categoryType;
    return PopupMenuItem<ChallengeCategoryType>(
      value: categoryType,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 끝 정렬
        children: [
          Text(
            categoryNames[categoryType] ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xff00AA5D) : const Color(0xff000000),
            ),
          ),
          if (isSelected) const Icon(Icons.check, size: 18, color: Color(0xff00AA5D)),
        ],
      ),
    );
  }
}
