// lib/services/web_marker_generator.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:miyo/data/services/api_service.dart';

/// 웹 플랫폼용 마커 이미지 생성기
/// dart:ui를 사용하여 위젯을 이미지로 렌더링
class WebMarkerGenerator {
  static final WebMarkerGenerator _instance = WebMarkerGenerator._internal();
  factory WebMarkerGenerator() => _instance;
  WebMarkerGenerator._internal();

  // Lazy initialization for web compatibility
  Dio? _dio;
  Dio get dio {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: ApiService.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    return _dio!;
  }

  ApiService get _apiService => ApiService();



  final Map<String, Uint8List> _imageCache = {};
  final Map<String, Uint8List> _markerCache = {};

  /// 마커 이미지 생성 (배치)
  Future<Map<String, Uint8List>> generateBatchMarkers(
    List<Map<String, dynamic>> markersData,
  ) async {
    final results = <String, Uint8List>{};

    for (var data in markersData) {
      try {
        final id = data['id'].toString();
        final imageUrl = data['imageUrl'] as String;
        final favoriteCnt = data['favoriteCnt'] as int;

        if (imageUrl.isEmpty || imageUrl == 'null') continue;
        if (!imageUrl.startsWith('http')) continue;

        final markerBytes = await generateMarkerImage(
          imageUrl: imageUrl,
          favoriteCnt: favoriteCnt,
        );

        results[id] = markerBytes;
      } catch (e) {
        debugPrint('❌ 웹 마커 생성 실패: ${data['id']} - $e');
      }
    }

    return results;
  }

  /// 단일 마커 이미지 생성
  Future<Uint8List> generateMarkerImage({
    required String imageUrl,
    required int favoriteCnt,
  }) async {
    final cacheKey = '${imageUrl}_$favoriteCnt';

    // 캐시 확인
    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    // 이미지 다운로드
    Uint8List imageData;
    if (_imageCache.containsKey(imageUrl)) {
      imageData = _imageCache[imageUrl]!;
    } else {
      imageData = await _downloadImage(imageUrl);
      _imageCache[imageUrl] = imageData;
    }

    // 위젯을 이미지로 렌더링
    final markerBytes = await _renderMarkerWidget(imageData, favoriteCnt);
    _markerCache[cacheKey] = markerBytes;

    return markerBytes;
  }

  /// 위젯을 이미지로 렌더링
  Future<Uint8List> _renderMarkerWidget(
    Uint8List imageData,
    int favoriteCnt,
  ) async {
    const double width = 80.0;
    const double height = 80.0;
    const double pixelRatio = 3.0;

    // PictureRecorder 생성
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 배경 (그림자 효과)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 2, width, height),
        const Radius.circular(12),
      ),
      shadowPaint,
    );

    // 이미지 디코딩
    final codec = await ui.instantiateImageCodec(
      imageData,
      targetWidth: (width * pixelRatio).toInt(),
      targetHeight: (height * pixelRatio).toInt(),
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // 둥근 모서리를 위한 클리핑
    final clipPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, width, height),
          const Radius.circular(12),
        ),
      );

    canvas.save();
    canvas.clipPath(clipPath);

    // 이미지 그리기
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      const Rect.fromLTWH(0, 0, width, height),
      Paint(),
    );

    canvas.restore();

    // 공감수 배지 그리기
    _drawFavoriteBadge(canvas, favoriteCnt, width, height);

    // Picture를 이미지로 변환
    final picture = recorder.endRecording();
    final img = await picture.toImage(
      (width * pixelRatio).toInt(),
      (height * pixelRatio).toInt(),
    );

    // PNG 바이트로 변환
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// 공감수 배지 그리기
  void _drawFavoriteBadge(Canvas canvas, int count, double width, double height) {
    const double badgeHeight = 20.0;
    const double iconSize = 13.0;
    const double padding = 6.0;

    // 텍스트 측정
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$count',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeWidth = iconSize + 2 + textPainter.width + padding * 2;
    final badgeLeft = width - badgeWidth - 6;
    final badgeTop = height - badgeHeight - 6;

    // 배지 배경
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeLeft, badgeTop, badgeWidth, badgeHeight),
      const Radius.circular(12),
    );

    canvas.drawRRect(
      badgeRect,
      Paint()..color = Colors.black.withValues(alpha: 0.54),
    );

    // 하트 아이콘 그리기 (간단한 원으로 대체)
    final iconPaint = Paint()..color = Colors.red;
    canvas.drawCircle(
      Offset(badgeLeft + padding + iconSize / 2, badgeTop + badgeHeight / 2),
      iconSize / 2,
      iconPaint,
    );

    // 텍스트 그리기
    textPainter.paint(
      canvas,
      Offset(badgeLeft + padding + iconSize + 2, badgeTop + (badgeHeight - textPainter.height) / 2),
    );
  }

  /// 이미지 다운로드 (CORS 우회 프록시 사용)
  Future<Uint8List> _downloadImage(String url) async {
    try {
      debugPrint('🌐 프록시를 통한 이미지 다운로드 시작: $url');

      final response = await _apiService.post(
        '/v0/images/download',
        data: {'imagePath': url},
        responseType: ResponseType.bytes,
      );

      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data!);
        debugPrint('✅ 이미지 다운로드 성공: ${bytes.length} bytes');
        return bytes;
      }
      throw Exception('이미지 다운로드 실패: ${response.statusCode}');
    } catch (e, stackTrace) {
      debugPrint('❌ 이미지 다운로드 오류: $url');
      debugPrint('에러: $e');
      debugPrint('스택: $stackTrace');
      rethrow;
    }
  }

  void clearCache() {
    _imageCache.clear();
    _markerCache.clear();
  }
}
