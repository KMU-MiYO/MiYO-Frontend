import 'package:flutter/material.dart';
import 'package:miyo/components/bottom_navbar.dart';
import 'package:miyo/components/top_navbar.dart';
import 'package:miyo/screens/challenges/challenge_screen.dart';
import 'package:miyo/screens/imaginary_map/imaginary_map_screen.dart';
import 'package:miyo/screens/map_screen.dart';
import 'package:miyo/screens/profile_screen.dart';

class Layout extends StatefulWidget {
  final int initialIndex; // 초기 탭 인덱스를 받을 수 있도록 추가

  const Layout({super.key, this.initialIndex = 0}); // 기본값은 0 (홈 탭)

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  late int _currentIndex; // late 키워드로 나중에 초기화
  final List<GlobalKey> _pageKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // 전달받은 초기 인덱스로 설정
  }

  // 각 탭에 해당하는 페이지들 리스트를 구성합니다.
  List<Widget> get _pages => [
    MapScreen(key: _pageKeys[0]),
    ImaginaryMapScreen(key: _pageKeys[1]),
    ChallengeScreen(key: _pageKeys[2]),
    ProfileScreen(key: _pageKeys[3]),
  ];

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
      // 탭 변경 시 해당 페이지의 키를 새로 생성하여 위젯을 재빌드
      _pageKeys[index] = GlobalKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 상단 네비게이션 바는 영속적으로 유지됩니다.
      appBar: TopNavbar(),
      // body 부분은 IndexedStack을 사용하여 선택된 페이지만 보여줍니다.
      // IndexedStack을 사용하면 각 페이지의 상태가 유지되므로 자연스러운 전환이 가능합니다.
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped, // 이 콜백을 통해 선택된 인덱스 업데이트
      ),
    );
  }
}
