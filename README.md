# MiYO (Make it Your Own)

환경 보호를 위한 챌린지 및 커뮤니티 플랫폼

## 프로젝트 소개

MiYO는 사용자들이 환경 보호 챌린지에 참여하고, 자신의 활동을 공유하며, 다른 사용자들과 소통할 수 있는 Flutter 기반 모바일 애플리케이션입니다.

## 주요 기능

- 🌱 환경 보호 챌린지 참여
- 📍 지도 기반 위치 서비스 (모바일: 네이버 지도 / 웹: 구글 지도)
- 📸 사진 업로드 및 공유
- 💬 커뮤니티 댓글 시스템
- 🔐 안전한 사용자 인증
- 🌐 웹 플랫폼 지원 (멀티 플랫폼)

## 기술 스택

- **프레임워크**: Flutter 3.8.1+
- **언어**: Dart
- **상태 관리**: GetX
- **네트워크**: Dio, HTTP
- **지도**:
  - 모바일: 네이버 지도 SDK
  - 웹: Google Maps Flutter
- **보안**: Flutter Secure Storage

## 시작하기

### 사전 요구사항

- Flutter SDK (3.8.1 이상)
- Dart SDK
- Android Studio / Xcode
- 네이버 클라우드 플랫폼 API 키 (모바일용)
- Google Maps API 키 (웹용)

### 설치 방법

1. 저장소 클론
```bash
git clone https://github.com/KMU-MiYO/MiYO-Frontend.git
cd MiYO-Frontend
```

2. 의존성 설치
```bash
flutter pub get
```

3. **Google Maps API 키 설정 (웹 빌드 시 필수)**

웹 플랫폼에서 지도 기능을 사용하려면 Google Maps API 키가 필요합니다.

a. [Google Cloud Console](https://console.cloud.google.com/)에서 API 키 발급
   - Maps JavaScript API 활성화
   - API 키 생성

b. `web/index.html` 파일에서 API 키 설정
```html
<!-- Google Maps JavaScript API -->
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE"></script>
```
위 코드에서 `YOUR_API_KEY_HERE`를 실제 발급받은 API 키로 변경하세요.

**⚠️ 주의**: API 키는 공개 저장소에 커밋하지 마세요!

4. 앱 실행
```bash
# Android
flutter run

# iOS (macOS에서만 가능)
flutter run -d ios

# 웹 (Chrome)
flutter run -d chrome

# 웹 (Edge)
flutter run -d edge
```

## 🌐 웹 플랫폼 지원

MiYO는 Flutter의 멀티 플랫폼 지원을 활용하여 웹 브라우저에서도 실행할 수 있습니다.

### 플랫폼별 차이점

| 기능 | 모바일 (Android/iOS) | 웹 (Chrome/Edge) |
|------|---------------------|-----------------|
| 지도 | 네이버 지도 | 구글 지도 |
| 마커 | 커스텀 이미지 + 공감수 | 커스텀 이미지 + 공감수 |
| 위치 서비스 | Native GPS | 브라우저 Geolocation API |
| 기타 기능 | 모두 동일 | 모두 동일 |

### 웹 빌드 및 테스트

```bash
# 1. Google Maps API 키 설정 (web/index.html)
# YOUR_API_KEY_HERE를 실제 키로 변경

# 2. 웹 버전 빌드
flutter build web --release

# 3. 웹 서버 실행
cd build/web
python -m http.server 8000

# 4. 브라우저에서 접속
# http://localhost:8000
```

### 웹뷰 테스트 페이지 기능

- ✅ 다양한 모바일 디바이스 시뮬레이션 (iPhone, Galaxy, Pixel 등)
- ✅ 화면 회전 (세로/가로 모드)
- ✅ 커스텀 해상도 설정
- ✅ 실시간 앱 새로고침

자세한 내용은 [WEBVIEW_TEST_GUIDE.md](./WEBVIEW_TEST_GUIDE.md)를 참조하세요.

## 📦 APK 빌드

### 디버그 빌드 (테스트용)
```bash
flutter build apk --debug
```

### 릴리즈 빌드 (배포용)
```bash
flutter build apk --release
```

### Split APK (권장)
```bash
flutter build apk --split-per-abi
```

빌드된 APK는 `build/app/outputs/flutter-apk/` 경로에서 확인할 수 있습니다.

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
├── views/                    # UI 화면
├── controllers/              # 비즈니스 로직 (GetX)
├── services/                 # API 및 외부 서비스
└── widgets/                  # 재사용 가능한 위젯

assets/
├── images/                   # 이미지 리소스
├── icons/                    # 아이콘 리소스
└── fonts/                    # 폰트 파일

web/
├── index.html                # 웹 앱 메인 페이지
└── webview_test.html         # 웹뷰 테스트 환경
```

## 개발 가이드

### 코드 스타일

프로젝트는 Flutter의 공식 린트 규칙을 따릅니다:
```bash
flutter analyze
```

### 테스트 실행

```bash
flutter test
```

## 제출 가이드

### 모바일 앱 제출 시

1. **Android APK 파일**
   - `flutter build apk --release` 실행
   - `build/app/outputs/flutter-apk/app-release.apk` 제출

2. **웹뷰 테스트 환경**
   - `build/web` 폴더 전체를 압축하여 제출
   - 또는 웹 서버에 배포하여 URL 제공

3. **iOS 앱** (선택사항)
   - iOS로 개발한 경우 APK 파일 불필요
   - `.ipa` 파일 또는 TestFlight 링크 제공

## 문제 해결

### 빌드 오류 발생 시

```bash
flutter clean
flutter pub get
flutter build apk
```

### 웹 빌드 문제

```bash
flutter clean
flutter pub get
flutter build web
```

자세한 문제 해결 방법은 [WEBVIEW_TEST_GUIDE.md](./WEBVIEW_TEST_GUIDE.md)의 "문제 해결" 섹션을 참조하세요.

## 참고 자료

- [Flutter 공식 문서](https://flutter.dev/docs)
- [Flutter 웹 배포 가이드](https://flutter.dev/docs/deployment/web)
- [네이버 지도 API 문서](https://navermaps.github.io/android-map-sdk/guide-ko/)

## 라이선스

이 프로젝트는 교육 목적으로 개발되었습니다.

## 개발팀

- GitHub: [KMU-MiYO](https://github.com/KMU-MiYO)
- 브랜치: develop → main
