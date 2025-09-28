import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex; // 현재 선택된 탭 인덱스
  final void Function(int index) onTap; // 부모에게 전달할 탭 변경 콜백

  const BottomNavbar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xff00AA5D),
      unselectedItemColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.pin_drop_outlined),
          label: '지도',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          label: '상상지도',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events_rounded),
          label: '챌린지',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_sharp),
          label: '프로필',
        ),
      ],
      onTap: onTap,
    );
  }
}