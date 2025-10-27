import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/screens/imaginary_map/imaginary_map_bottom_sheet.dart';

class ImaginaryMapScreen extends StatefulWidget {
  const ImaginaryMapScreen({super.key});

  @override
  State<ImaginaryMapScreen> createState() => _ImaginaryMapScreenState();
}

class _ImaginaryMapScreenState extends State<ImaginaryMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppbar(title: '상상지도'),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: const Center(child: Text('지도 화면')),
          ),
          ImaginaryMapBottomSheet(),
        ],
      ),
    );
  }
}
