import 'package:miyo/screens/imaginary_map/suggestion_item.dart';

// 전체 더미 제안 데이터를 반환하는 함수
List<Map<String, dynamic>> allDummySuggestions() {
  return [
    {
      'id': 1,
      'title': '놀이터가 너무 노후됐어요.',
      'writer': 'hoho',
      'categoryType': CategoryType.NaturePark,
      'like': 500,
    },
    {
      'id': 2,
      'title': '자전거 도로가 필요해요.',
      'writer': 'ahnana',
      'categoryType': CategoryType.Transport,
      'like': 300,
    },
    {
      'id': 3,
      'title': '벤치 관리가 안되는 듯 해요.',
      'writer': 'banana',
      'categoryType': CategoryType.NaturePark,
      'like': 100,
    },
    {
      'id': 4,
      'title': '가로등을 고쳐주세요.',
      'writer': 'cherry',
      'categoryType': CategoryType.NightLandscape,
      'like': 200,
    },
    {
      'id': 5,
      'title': '쉼터가 필요해요.',
      'writer': 'orange',
      'categoryType': CategoryType.Life,
      'like': 400,
    },
    {
      'id': 6,
      'title': '문화시설을 만들어주세요.',
      'writer': 'orange',
      'categoryType': CategoryType.CultureArts,
      'like': 50,
    },
  ];
}

// 좋아요 수 상위 3개 제안 가져오기
List<Map<String, dynamic>> getTop3Suggestions() {
  final sortedList = List<Map<String, dynamic>>.from(allDummySuggestions());
  sortedList.sort((a, b) => (b['like'] as int).compareTo(a['like'] as int));
  return sortedList.take(3).toList();
}
