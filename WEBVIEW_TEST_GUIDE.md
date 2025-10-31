# MiYO 웹뷰 테스트 가이드

## 개요

이 문서는 MiYO Flutter 앱을 웹 환경에서 테스트하고, APK 파일을 빌드하는 방법을 설명합니다.

## 📱 웹뷰 테스트 환경

### 1. 웹 버전 빌드

Flutter 웹 버전을 빌드합니다:

```bash
flutter build web
```

빌드 완료 후, `build/web` 디렉토리에 웹 앱이 생성됩니다.

### 2. 웹 서버 실행

로컬 웹 서버를 실행하여 앱을 테스트합니다:

**방법 1: Flutter 내장 서버 (개발용)**
```bash
flutter run -d chrome
```

**방법 2: Python 웹 서버**
```bash
cd build/web
python -m http.server 8000
```

**방법 3: Node.js 서버 (추천)**
```bash
# 전역 설치 (한 번만 실행)
npm install -g http-server

# 서버 실행
cd build/web
http-server -p 8000
```

### 3. 웹뷰 테스트 페이지 사용

웹 서버 실행 후, 다음 URL로 접속:

```
http://localhost:8000/webview_test.html
```

#### 웹뷰 테스트 페이지 기능:

- ✅ **다양한 디바이스 프리셋**: iPhone 14, Galaxy S23, Pixel 7 등
- ✅ **화면 회전**: 세로/가로 모드 전환
- ✅ **커스텀 해상도**: 원하는 해상도로 테스트 가능
- ✅ **실시간 새로고침**: 앱 재시작 없이 새로고침

#### 테스트 시나리오:

1. 다양한 디바이스 해상도에서 UI 확인
2. 세로/가로 모드 전환 테스트
3. 터치 인터랙션 동작 확인
4. 지도, 카메라 등 권한 요청 기능 테스트

## 📦 Android APK 빌드

### 사전 요구사항

1. **Android Studio 설치**
2. **Java JDK 설치** (JDK 11 이상)
3. **Flutter SDK 설정**

### APK 빌드 명령어

#### 1. 디버그 APK (테스트용)

```bash
flutter build apk --debug
```

- 빌드 위치: `build/app/outputs/flutter-apk/app-debug.apk`
- 용도: 내부 테스트 및 개발용

#### 2. 릴리즈 APK (배포용)

```bash
flutter build apk --release
```

- 빌드 위치: `build/app/outputs/flutter-apk/app-release.apk`
- 용도: 실제 사용자 배포용
- 참고: 서명 설정 필요 (아래 참조)

#### 3. Split APK (권장)

다양한 CPU 아키텍처별로 최적화된 APK 생성:

```bash
flutter build apk --split-per-abi
```

생성되는 파일:
- `app-armeabi-v7a-release.apk` (32비트 ARM)
- `app-arm64-v8a-release.apk` (64비트 ARM - 대부분의 최신 기기)
- `app-x86_64-release.apk` (에뮬레이터용)

### APK 서명 설정 (릴리즈 빌드용)

릴리즈 APK를 배포하려면 서명이 필요합니다.

#### 1. 키스토어 생성

```bash
keytool -genkey -v -keystore ~/miyo-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias miyo
```

#### 2. `android/key.properties` 파일 생성

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=miyo
storeFile=<path to keystore>/miyo-keystore.jks
```

#### 3. `android/app/build.gradle` 수정

파일 상단에 추가:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

`buildTypes` 섹션 수정:

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

## 🍎 iOS 빌드 (참고)

iOS 앱을 빌드하려면 macOS 환경이 필요합니다.

```bash
# iOS 앱 빌드
flutter build ios --release

# 또는 Xcode로 직접 빌드
open ios/Runner.xcworkspace
```

## 🧪 빌드 전 체크리스트

- [ ] `flutter doctor` 실행하여 모든 항목 정상 확인
- [ ] `flutter pub get` 실행하여 의존성 설치
- [ ] 앱 권한 설정 확인 (`AndroidManifest.xml`)
- [ ] 앱 아이콘 및 스플래시 스크린 확인
- [ ] 네이버 지도 API 키 설정 확인
- [ ] 버전 정보 업데이트 (`pubspec.yaml`)

## 📤 제출 가이드

### 제출 파일 구성:

1. **APK 파일** (Android의 경우)
   - `app-release.apk` 또는
   - `app-arm64-v8a-release.apk` (권장)

2. **웹뷰 테스트 환경**
   - `build/web` 폴더 전체를 압축
   - 또는 웹 서버에 배포하여 URL 제공

3. **설치 및 테스트 가이드** (선택사항)
   - APK 설치 방법
   - 테스트 계정 정보 (필요시)

### 제출 예시:

```
miyo-submission/
├── miyo-app-release.apk
├── web/
│   ├── index.html
│   ├── webview_test.html
│   └── ... (기타 웹 파일들)
└── README.md (설치 가이드)
```

## 🔧 문제 해결

### 웹 빌드 오류

```bash
# 캐시 정리
flutter clean
flutter pub get
flutter build web
```

### APK 빌드 오류

```bash
# Gradle 캐시 정리
cd android
./gradlew clean

# Flutter 캐시 정리
flutter clean
flutter pub get
flutter build apk
```

### 웹뷰에서 카메라/위치 권한 오류

웹뷰 테스트 페이지의 iframe `sandbox` 속성이 필요한 권한을 허용하는지 확인하세요:

```html
<iframe
    sandbox="allow-same-origin allow-scripts allow-forms allow-popups allow-modals allow-geolocation allow-camera"
></iframe>
```

### 네이버 지도가 표시되지 않음

1. 네이버 클라우드 플랫폼에서 웹 도메인 등록 확인
2. API 키가 올바르게 설정되었는지 확인
3. 네트워크 연결 상태 확인

## 📞 지원

문제가 발생하면 다음을 확인하세요:

1. Flutter 버전: `flutter --version`
2. Android SDK 버전
3. 에러 로그: `flutter logs`

## 🔗 유용한 링크

- [Flutter 공식 문서](https://flutter.dev/docs)
- [Flutter 웹 배포 가이드](https://flutter.dev/docs/deployment/web)
- [Android 앱 번들 가이드](https://developer.android.com/guide/app-bundle)
- [네이버 지도 API 문서](https://navermaps.github.io/android-map-sdk/guide-ko/)

---

**마지막 업데이트**: 2025-10-31
**Flutter 버전**: 3.8.1+
**프로젝트**: MiYO Frontend
