## MiYO 🗺️

> 우리 동네를 더 나은 곳으로 만들기 위한 시민 참여형 플랫폼

MiYO는 시민들이 지역 사회의 문제를 발견하고 개선 아이디어를 제안할 수 있는 위치 기반 모바일 애플리케이션입니다. AI 이미지 생성 기술을 활용하여 상상을 현실처럼 시각화하고, 챌린지를 통해 적극적인 시민 참여를 유도합니다.

<p align="center">
  <img width="1242" height="699" alt="github" src="https://github.com/user-attachments/assets/c66610b8-d041-48c1-a092-4887b97d5781" />


</p>

## ✨ 주요 기능

### 📍 상상 지도 
- **위치 기반 제안글**: 네이버 맵 기반으로 주변의 개선 제안을 지도에서 확인
- **실시간 필터링**: 카테고리(자연, 문화, 교통, 주거, 상권, 야간, 환경)별 필터링
- **다양한 정렬**: 인기순, 최신순, 거리순으로 제안글 정렬
- **Top3 순위**: 주변에서 가장 인기 있는 제안글 3개 하이라이트


| 카테고리 | 설명 |
|:-------|:------|
| 자연 (NATURE) | 공원, 녹지, 자연 환경 |
| 문화 (CULTURE) | 문화 시설, 예술 공간 |
| 교통 (TRAFFIC) | 대중교통, 도로, 주차 |
| 주거 (RESIDENCE) | 주거 환경, 생활 편의 |
| 상권 (COMMERCIAL) | 상업 시설, 쇼핑 |
| 야간 (NIGHT) | 야간 경관, 조명 |
| 환경 (ENVIRONMENT) | 환경 개선, 지속가능성 |

### 🎨 AI 이미지 생성
- **텍스트 기반 생성**: 프롬프트를 입력하여 원하는 이미지 생성
- **이미지 기반 생성**: 기존 이미지를 바탕으로 새로운 이미지 생성
- **제안 시각화**: 개선 아이디어를 AI로 시각화하여 현실감 있게 전달

### 🏆 챌린지 시스템
- **주간 미션**: 매주 새로운 미션 제공
- **지자체 협업 챌린지** : 지자체에서 주관하는 챌린지

### 💬 소통 기능
- **게시글 작성**: 이미지와 위치 정보를 포함한 제안글 작성
- **공감 시스템**: 좋은 아이디어에 공감 표시
- **댓글**: 제안글에 대한 의견 교환

## 🛠️ 기술 스택

### Frontend
- **Framework**: Flutter 3.8.1
- **상태 관리**: GetX
- **HTTP 클라이언트**: Dio
- **지도**: flutter_naver_map
- **보안 저장소**: flutter_secure_storage
- **위치 서비스**: geolocator
- **이미지 처리**: image_picker, screenshot, cached_network_image

## 📜 전체 개발 환경 구성도
<p align = "center">
<img width="450" height="250" alt="개발 환경 구성도" src="https://github.com/user-attachments/assets/86a88df5-0968-45e5-b1c1-9785a295795c" />
</p>

## 📁 프로젝트 구조

```
lib/
├── config/              # 앱 설정 파일
├── data/
│   └── services/       # API 서비스
│       ├── api_service.dart
│       ├── post_service.dart
│       ├── challenge_service.dart
│       └── token_storage_service.dart
├── screens/
│   ├── challenges/     # 챌린지 화면
│   ├── imaginary_map/  # 상상지도 화면
│   ├── suggestion/     # 제안글 상세/작성
│   ├── exchanges/      # 교환소 기능
│   ├── settings/       # 설정
│   └── onboarding/     # 온보딩
├── components/         # 재사용 가능한 UI 컴포넌트
└── services/          # 비즈니스 로직 서비스
```

## 🚀 시작하기

### 필수 요구사항
- Flutter SDK ^3.8.1
- Dart SDK ^3.8.1
- iOS 개발: Xcode 14.0+
- Android 개발: Android Studio

### 설치 및 실행

1. **저장소 클론**
```bash
git clone https://github.com/KMU-MiYO/MiYO-Frontend.git
cd MiYO-Frontend
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **네이티브 리소스 생성**
```bash
# 앱 아이콘 생성
flutter pub run flutter_launcher_icons

# 스플래시 스크린 생성
flutter pub run flutter_native_splash:create
```

4. **앱 실행**
```bash
# 개발 모드
flutter run

# 릴리스 빌드
flutter run --release
```

## 📱 화면 구성
<img width="3607" height="2188" alt="대표이미지모음" src="https://github.com/user-attachments/assets/396b90ed-e144-4a95-b8ae-bbcea6290f3b" />

1. **홈 화면**: 제안글 추가 및 내 제안 모아보기
2. **상상지도**: 위치 기반 제안글 탐색
3. **챌린지**: 미션 및 챌린지 참여
4. **제안글 작성**: AI 이미지와 함께 아이디어 제안
5. **제안글 상세**: 공감 및 댓글
6. **설정**: 프로필 및 앱 설정

## 🔒 보안

- **토큰 관리**: flutter_secure_storage를 활용한 안전한 인증 토큰 저장
- **API 통신**: HTTPS를 통한 암호화된 통신
- **권한 관리**: permission_handler를 통한 체계적인 권한 요청
- **config 파일 관리**: 개발 중 사용되는 key 등을 별도로 관리하여 보안 유지

## 👥 프론트 팀원
| 정현주 | 한여진 | 황연주 |
|:--------:|:--------:|:--------:|
| [@jhj04](https://github.com/jhj04) |  [@hanyj0317](https://github.com/hanyj0317) |[@jooya38](https://github.com/jooya38) |
| 국민대학교<br>소프트웨어전공 | 국민대학교<br>소프트웨어전공 |국민대학교<br>소프트웨어전공 |

