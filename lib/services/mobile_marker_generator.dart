// lib/services/mobile_marker_generator.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:miyo/components/imaginary_marker_widget.dart';

/// 모바일 플랫폼용 마커 이미지 생성기
class MobileMarkerGenerator {
  static final MobileMarkerGenerator _instance =
      MobileMarkerGenerator._internal();
  factory MobileMarkerGenerator() => _instance;
  MobileMarkerGenerator._internal();

  final ScreenshotController _screenshotController = ScreenshotController();
  final Map<String, String> _cacheFilePaths = {};
  final Map<String, Uint8List> _imageDataCache = {};
  final Dio _dio = Dio();

  // 배치로 여러 마커 이미지를 한번에 생성 (순차 처리로 변경)
  Future<Map<String, String>> generateBatchMarkerImages(
    List<Map<String, dynamic>> markersData,
  ) async {
    final results = <String, String>{};

    debugPrint('📸 마커 이미지 생성 시작: ${markersData.length}개');

    // 순차적으로 처리 (메모리/버퍼 오버플로우 방지)
    for (var data in markersData) {
      try {
        final id = data['id'] as String;
        final imageUrl = data['imageUrl'] as String; // imageUrl로 통일
        final favoriteCnt = data['favoriteCnt'] as int;

        debugPrint('📸 마커 생성 중: id=$id, url=$imageUrl, count=$favoriteCnt');

        // imageUrl이 비어있거나 null인 경우 체크
        if (imageUrl.isEmpty || imageUrl == 'null' || imageUrl == '') {
          debugPrint('⚠️ 이미지 URL이 비어있습니다: id=$id');
          continue;
        }

        // URL 형식 검증
        if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
          debugPrint('⚠️ 잘못된 URL 형식입니다: id=$id, url=$imageUrl');
          continue;
        }

        final path = await generateMarkerImagePath(
          imageUrl: imageUrl,
          favoriteCnt: favoriteCnt,
        );
        results[id] = path;
        debugPrint('✅ 마커 생성 완료: id=$id, path=$path');

        // 버퍼가 정리될 시간을 줌 (ImageReader 오버플로우 방지)
        await Future.delayed(const Duration(milliseconds: 50));
      } catch (error, stackTrace) {
        debugPrint('❌ 마커 생성 실패: ${data['id']}');
        debugPrint('에러: $error');
        debugPrint('스택: $stackTrace');
      }
    }

    debugPrint('📸 마커 이미지 생성 완료: ${results.length}/${markersData.length}개 성공');
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
      if (await File(cachedPath).exists()) {
        return cachedPath;
      }
    }

    // 이미지 데이터 가져오기 (캐시 or 다운로드)
    Uint8List imageData;
    if (_imageDataCache.containsKey(imageUrl)) {
      imageData = _imageDataCache[imageUrl]!;
      debugPrint('✅ 캐시에서 이미지 로드');
    } else {
      imageData = await _downloadImage(imageUrl);
      _imageDataCache[imageUrl] = imageData;
      debugPrint('✅ 이미지 다운로드 후 캐시 저장');
    }

    debugPrint('📸 이미지 데이터 크기: ${imageData.length} bytes');

    // 위젯을 이미지로 변환
    debugPrint('📸 스크린샷 생성 시작: favoriteCnt=$favoriteCnt');
    final markerImageBytes = await _screenshotController.captureFromWidget(
      Material(
        color: Colors.transparent,
        child: ImaginaryMarkerWidget(
          imageData: imageData,
          favoriteCnt: favoriteCnt,
        ),
      ),
      pixelRatio: 3.0,
      delay: const Duration(milliseconds: 100),
    );

    debugPrint('📸 스크린샷 생성 완료: ${markerImageBytes.length} bytes');

    // 스크린샷 데이터 검증
    if (markerImageBytes.isEmpty) {
      throw Exception('마커 이미지 생성 실패: 빈 데이터');
    }

    // 파일로 저장
    final tempDir = await getTemporaryDirectory();
    final fileName = 'marker_${cacheKey.hashCode}.png';
    final filePath = '${tempDir.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(markerImageBytes);

    debugPrint('💾 마커 이미지 파일 저장 완료: $filePath');

    // 파일 검증
    final exists = await file.exists();
    final fileSize = await file.length();
    debugPrint('✅ 파일 존재 확인: $exists, 크기: $fileSize bytes');

    if (!exists || fileSize == 0) {
      throw Exception('마커 파일 저장 실패: exists=$exists, size=$fileSize');
    }

    _cacheFilePaths[cacheKey] = filePath;
    return filePath;
  }

  Future<Uint8List> _downloadImage(String url) async {
    try {
      debugPrint('🌐 이미지 다운로드 시작: $url');

      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint('🌐 응답 코드: ${response.statusCode}');
      debugPrint('🌐 응답 데이터 타입: ${response.data.runtimeType}');

      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data!);
        debugPrint('✅ 이미지 다운로드 성공: ${bytes.length} bytes');

        // 이미지 데이터 검증
        if (bytes.isEmpty) {
          throw Exception('이미지 데이터가 비어있습니다');
        }

        return bytes;
      }
      throw Exception('Failed to load image: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('❌ 이미지 다운로드 실패 (Dio): $url');
      debugPrint('에러 타입: ${e.type}');
      debugPrint('에러 메시지: ${e.message}');
      debugPrint('응답 상태: ${e.response?.statusCode}');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('❌ 이미지 다운로드 실패: $url');
      debugPrint('에러: $e');
      debugPrint('스택: $stackTrace');
      rethrow;
    }
  }

  void clearCache() {
    _cacheFilePaths.clear();
    _imageDataCache.clear();
  }
}
