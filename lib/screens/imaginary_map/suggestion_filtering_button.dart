import 'package:flutter/material.dart';

enum FilterType {
  popularity, // 인기순
  latest, // 최신순
  distance, // 거리순
}

class SuggestionFilteringButton extends StatelessWidget {
  final FilterType selectedFilter;
  final Function(FilterType) onFilterChanged;

  const SuggestionFilteringButton({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const Map<FilterType, String> filterNames = {
    FilterType.popularity: '인기순',
    FilterType.latest: '최신순',
    FilterType.distance: '거리순',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FilterType>(
      onSelected: onFilterChanged,
      offset: const Offset(0, 40),
      color: Colors.white, // 팝업 메뉴 배경색 하얀색
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        _buildMenuItem(FilterType.popularity),
        _buildMenuItem(FilterType.latest),
        _buildMenuItem(FilterType.distance),
      ],
      child: Container(
        // 필터링 버튼
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          // color: Color(0xffF0F2F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Row 크리를 내용물에 맞춤
          children: [
            Icon(Icons.filter_list, size: 18, color: Color(0xff61758A)),
            const SizedBox(width: 4),
            Text(
              filterNames[selectedFilter] ?? '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff61758A),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: Color(0xff61758A)),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<FilterType> _buildMenuItem(FilterType filterType) {
    final isSelected = selectedFilter == filterType;
    return PopupMenuItem<FilterType>(
      value: filterType,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 끝 정렬
        children: [
          Text(
            filterNames[filterType] ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Color(0xff00AA5D) : Color(0xff000000),
            ),
          ),
          if (isSelected) Icon(Icons.check, size: 18, color: Color(0xff00AA5D)),
        ],
      ),
    );
  }
}
