import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:miyo/screens/imaginary_map/suggestion_item.dart';
import 'package:miyo/screens/imaginary_map/suggestion_category_button.dart';
import 'package:miyo/screens/exchanges/exchange.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<NaverMapController> _mapControllerCompleter = Completer();

  // 선택된 카테고리들 (빈 Set = 전체 보기)
  Set<CategoryType> selectedCategories = {};

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xff00AA5D),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                'P',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              '500,000',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ExchangeScreen(point: '500, 000'),
                  ),
                );
              },
              icon: Icon(Icons.card_giftcard, color: Colors.white, size: 20),
              label: Text(
                '교환소',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff00AA5D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: kIsWeb
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    '지도 기능은 모바일에서만 사용 가능합니다.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                NaverMap(
                  options: const NaverMapViewOptions(
                    locationButtonEnable: true,
                    initialCameraPosition: NCameraPosition(
                      target: NLatLng(37.602, 126.977),
                      zoom: 14,
                    ),
                  ),
                  onMapReady: (controller) {
                    _mapControllerCompleter.complete(controller);
                  },
                ),
                // 카테고리 필터 버튼
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: SizedBox(
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
                ),
              ],
            ),
    );
  }
}
