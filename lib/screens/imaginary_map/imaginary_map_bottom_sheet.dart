import 'package:flutter/material.dart';
import 'package:miyo/data/dummy/dummy_suggestions.dart';
import 'package:miyo/screens/imaginary_map/suggestion_detail_screen.dart';
import 'package:miyo/screens/imaginary_map/suggestion_item.dart';
import 'package:miyo/screens/imaginary_map/suggestion_top3.dart';
import 'package:miyo/screens/imaginary_map/suggestion_category_button.dart';
import 'package:miyo/screens/imaginary_map/suggestion_filtering_button.dart';

class ImaginaryMapBottomSheet extends StatefulWidget {
  const ImaginaryMapBottomSheet({super.key});

  @override
  State<ImaginaryMapBottomSheet> createState() =>
      _ImaginaryMapBottomSheetState();
}

class _ImaginaryMapBottomSheetState extends State<ImaginaryMapBottomSheet> {
  // 선택된 카테고리들 (빈 Set = 전체 보기)
  Set<CategoryType> selectedCategories = {};

  // 선택된 필터 (기본: 인기순)
  FilterType selectedFilter = FilterType.popularity;

  // 제안 리스트
  final suggestionLists = allDummySuggestions();

  // 제안 목록 스크롤 컨트롤러
  final ScrollController _suggestionScrollController = ScrollController();

  // 모든 카테고리 리스트
  final List<CategoryType> allCategories = [
    CategoryType.NaturePark,
    CategoryType.CultureArts,
    CategoryType.Transport,
    CategoryType.Life,
    CategoryType.Commercial,
    CategoryType.NightLandscape,
    CategoryType.EnvironSustain,
  ];

  void toggleCategory(CategoryType category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  void changeFilter(FilterType newFilter) {
    setState(() {
      selectedFilter = newFilter;
      // TODO: 필터에 따라 제안 목록 정렬
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final top3Suggestions = getTop3Suggestions();

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.05,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5),
            ],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              // 드래그 핸들
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Color(0xffF0F2F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // 검색창
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '게시글 검색하기',
                    hintStyle: TextStyle(color: Color(0xff61758A)),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xff61758A),
                    ),
                    filled: true,
                    fillColor: Color(0xffF0F2F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.001),
              // Top3 제안
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  itemCount: top3Suggestions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final suggestion = top3Suggestions[index];
                    return SuggestionTop3(
                      categoryType: suggestion['categoryType'] as CategoryType,
                      title: suggestion['title'] as String,
                      writer: suggestion['writer'] as String,
                      rank: index + 1,
                      onTap: () {
                        // TODO: 제안 상세 화면으로 이동
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => SuggestionDetailScreen(
                        //       suggestionId: suggestion['id'] as int,
                        //     ),
                        //   ),
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuggestionDetailScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: height * 0.001),
              // 내 주변 제목 + 필터링 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '내 주변',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SuggestionFilteringButton(
                      selectedFilter: selectedFilter,
                      onFilterChanged: changeFilter,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 카테고리 필터 버튼
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allCategories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = allCategories[index];
                    return SuggestionCategoryButton(
                      categoryType: category,
                      isSelected: selectedCategories.contains(category),
                      onTap: () => toggleCategory(category),
                    );
                  },
                ),
              ),
              SizedBox(height: height * 0.02),
              // 제안 목록 (고정 높이 + 내부 스크롤)
              SizedBox(
                height: 300,
                child: Scrollbar(
                  controller: _suggestionScrollController,
                  thumbVisibility: true,
                  thickness: 3,
                  radius: Radius.circular(2),
                  child: ListView.separated(
                    controller: _suggestionScrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: suggestionLists.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final suggestion = suggestionLists[index];
                      return SuggestionItem(
                        categoryType:
                            suggestion['categoryType'] as CategoryType,
                        title: suggestion['title'] as String,
                        writer: suggestion['writer'] as String,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
