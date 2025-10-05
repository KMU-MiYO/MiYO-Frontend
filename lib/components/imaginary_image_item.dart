import 'package:flutter/material.dart';

class ImaginaryImageItem extends StatelessWidget {
  final String imageUrl; //이미지 데이터 받아오기(서버 url  받아올지, db에서 데이터 값 받아올지 결정 필요.)
  final int favoriateCnt;

  const ImaginaryImageItem({
    super.key,
    required this.imageUrl,
    required this.favoriateCnt,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imageUrl,
            width: 76,
            height: 76,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 6,
          right: 6,
          child: Row(
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 15),
              Text(
                '$favoriateCnt',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
