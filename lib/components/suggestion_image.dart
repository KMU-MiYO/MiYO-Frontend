import 'package:flutter/material.dart';
import 'dart:typed_data';

class SuggestionImage extends StatelessWidget {
  final Uint8List? imageData;
  final String suggestionTitle;
  final VoidCallback? onTap;

  const SuggestionImage({
    super.key,
    required this.imageData,
    required this.suggestionTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 부분
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.25),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageData != null
                    ? Image.memory(imageData!, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xffF0F2F5),
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: Color(0xff9AA6B2),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 제목 부분
          Text(
            suggestionTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
