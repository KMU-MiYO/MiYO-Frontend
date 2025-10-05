import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:miyo/components/imaginary_image_item.dart';

class ImaginaryMapScreen extends StatefulWidget {
  const ImaginaryMapScreen({super.key});

  @override
  State<ImaginaryMapScreen> createState() => _ImaginaryMapScreenState();
}

class _ImaginaryMapScreenState extends State<ImaginaryMapScreen> {
  final Completer<NaverMapController> _mapControllerCompleter = Completer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NaverMap(
          options: const NaverMapViewOptions(
            indoorEnable: false, //실내 맵 사용 가능 여부 설정
            locationButtonEnable: true, // 위치 버튼 표시 여부 설정
            consumeSymbolTapEvents: true, // 심볼 탭 이벤트 소비 여부 설정
            // contentPadding: safeAreaPadding, //  화면의 SafeArea에 중요 지도 요소가 들어가지 않도록 설정하는 Padding.
            initialCameraPosition: NCameraPosition(
              target: NLatLng(37.5666, 126.979),
              zoom: 14,
            ), // 추후 현재 위치 받아오는 것으로 수정할 것. 지금은 서울시청으로 설정함.
          ),
          onMapReady: (controller) async {
            _mapControllerCompleter.complete(
              controller,
            ); // Completer에 지도 컨트롤러 완료 신호 전송
            print("onMapReady");
          },
          /*onSymbolTapped: (NSymbol symbol) {
            // 심볼을 클릭했을 때 실행할 코드
          },*/
        ),
        Positioned(
          child: ImaginaryImageItem(
            imageUrl: 'assets/images/test1.png',
            favoriateCnt: 50,
          ),
        ),
      ],
    );
  }
}
