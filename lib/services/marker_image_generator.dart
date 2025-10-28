// lib/services/marker_image_generator.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:miyo/components/imaginary_marker_widget.dart';  // 추가

class MarkerImageGenerator {
  static final MarkerImageGenerator _instance =
  MarkerImageGenerator._internal();
  factory MarkerImageGenerator() => _instance;
  MarkerImageGenerator._internal();

  final ScreenshotController _screenshotController = ScreenshotController();
  final Map<String, String> _cacheFilePaths = {};
  final Map<String, Uint8List> _imageDataCache = {};

  // 배치로 여러 마커 이미지를 한번에 생성 (병렬 처리)
  Future<Map<String, String>> generateBatchMarkerImages(
      List<Map<String, dynamic>> markersData,
      ) async {
    final results = <String, String>{};

    // 1단계: 모든 이미지를 병렬로 다운로드
    final downloadFutures = <Future>[];
    for (var data in markersData) {
      final imageUrl = data['imageUrl'] as String;
      if (!_imageDataCache.containsKey(imageUrl)) {
        downloadFutures.add(
          _downloadImage(imageUrl).then((bytes) {
            _imageDataCache[imageUrl] = bytes;
          }).catchError((error) {
            print('Failed to download image $imageUrl: $error');
          }),
        );
      }
    }
    await Future.wait(downloadFutures);

    // 2단계: 모든 마커 이미지를 병렬로 생성
    final generationFutures = markersData.map((data) async {
      final id = data['id'] as String;
      final path = await generateMarkerImagePath(
        imageUrl: data['imageUrl'] as String,
        favoriteCnt: data['favoriteCnt'] as int,
      );
      results[id] = path;
    });
    await Future.wait(generationFutures);

    return results;
  }

  Future<String> generateMarkerImagePath({
    required String imageUrl,
    required int favoriteCnt,
  }) async {
    final cacheKey = '${imageUrl}_$favoriteCnt';

    // 캐시 확인
    if (_cacheFilePaths.containsKey(cacheKey)) {
      final cachedPath = _cacheFilePaths[cacheKey]!;
      // 파일이 실제로 존재하는지 확인
      if (await File(cachedPath).exists()) {
        return cachedPath;
      }
    }

    // 이미지 데이터 가져오기 (캐시 or 다운로드)
    Uint8List imageData;
    if (_imageDataCache.containsKey(imageUrl)) {
      imageData = _imageDataCache[imageUrl]!;
    } else {
      imageData = await _downloadImage(imageUrl);
      _imageDataCache[imageUrl] = imageData;
    }

    // 위젯을 이미지로 변환
    final markerImageBytes = await _screenshotController.captureFromWidget(
      Material(
        color: Colors.transparent,
        child: ImaginaryMarkerWidget(  // 컴포넌트 사용
          imageData: imageData,
          favoriteCnt: favoriteCnt,
        ),
      ),
      pixelRatio: 2.5,
      delay: const Duration(milliseconds: 20),
    );

    // 파일로 저장
    final tempDir = await getTemporaryDirectory();
    final fileName = 'marker_${cacheKey.hashCode}.png';
    final filePath = '${tempDir.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(markerImageBytes);

    _cacheFilePaths[cacheKey] = filePath;
    return filePath;
  }

  Future<Uint8List> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception('Failed to load image: ${response.statusCode}');
  }

  void clearCache() {
    _cacheFilePaths.clear();
    _imageDataCache.clear();
  }
}