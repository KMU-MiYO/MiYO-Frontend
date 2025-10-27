import 'package:miyo/screens/challenges/challenge_item.dart';

// 전체 챌린지 더미 데이터
final List<Map<String, dynamic>> allDummyChallenges = [
  {
    'id': 1,
    'categoryType': CategoryType.NaturePark,
    'title': '2026 우리 동네 공원 상상하기',
    'location': '서울시',
  },
  {
    'id': 2,
    'categoryType': CategoryType.Life,
    'title': '2026 성북구 편의시설 상상하기',
    'location': '성북구',
  },
  {
    'id': 3,
    'categoryType': CategoryType.EnvironSustain,
    'title': '2026 친환경 도시 상상하기',
    'location': '서울시',
  },
  {
    'id': 4,
    'categoryType': CategoryType.CultureArts,
    'title': '2026 문화예술 공간 상상하기',
    'location': '강남구',
  },
  {
    'id': 5,
    'categoryType': CategoryType.Transport,
    'title': '2026 대중교통 개선 아이디어',
    'location': '서울시',
  },
  {
    'id': 6,
    'categoryType': CategoryType.Commercial,
    'title': '2026 전통시장 활성화 프로젝트',
    'location': '마포구',
  },
  {
    'id': 7,
    'categoryType': CategoryType.NightLandscape,
    'title': '2026 야간 경관 개선 프로젝트',
    'location': '용산구',
  },
];

// 참가중인 챌린지 ID 리스트 (현재 로그인한 사용자 기준)
final List<int> participatingChallengeIds = [1, 2, 3];

// 참가중인 챌린지만 필터링
List<Map<String, dynamic>> getParticipatingChallenges() {
  return allDummyChallenges
      .where((challenge) => participatingChallengeIds.contains(challenge['id']))
      .toList();
}
