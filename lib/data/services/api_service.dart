import 'package:dio/dio.dart';
import 'token_storage_service.dart';

/// 기본 API 서비스 클래스
/// Spring Boot 백엔드와 통신하기 위한 HTTP 클라이언트 설정
class ApiService {
  late final Dio _dio;
  final TokenStorageService _tokenStorage = TokenStorageService();

  // Spring Boot 서버 URL (나중에 실제 URL로 변경)
  // static const String baseUrl = 'http://localhost:8080/api';
  static const String baseUrl = 'http://ing-default-samplealbing-bcdf6-110164755-b48ba1cb3cc4.kr.lb.naverncp.com';

  // 개발 모드 플래그 (true일 때 더미 데이터 사용)
  static const bool isDevelopmentMode = false;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // 인터셉터 추가 (로깅, 인증 토큰 자동 추가 등)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 요청 전 로깅
          print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');

          // 저장된 JWT 토큰이 있으면 자동으로 추가
          final token = await _tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🔑 Token added to request');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 응답 로깅
          print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          // 에러 로깅
          print('❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          print('MESSAGE: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// GET 요청
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  /// POST 요청
  Future<Response> post(String path, {dynamic data, ResponseType? responseType}) async {
    return await _dio.post(
      path,
      data: data,
      options: responseType != null ? Options(responseType: responseType) : null,
    );
  }

  /// PUT 요청
  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  /// DELETE 요청
  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  /// POST 요청 (Multipart/form-data)
  Future<Response> postMultipart(String path, FormData formData) async {
    return await _dio.post(path, data: formData);
  }
}