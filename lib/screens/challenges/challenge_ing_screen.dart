import 'package:flutter/material.dart';
import 'package:miyo/data/services/challenge_service.dart';
import 'package:miyo/screens/challenges/challenge_item.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/data/dummy/dummy_challenges.dart';

class ChallengeIngScreen extends StatefulWidget {
  const ChallengeIngScreen({super.key});

  @override
  State<ChallengeIngScreen> createState() => _ChallengeIngScreen();
}

class _ChallengeIngScreen extends State<ChallengeIngScreen> {
  final ChallengeService _challengeService = ChallengeService();

  List<dynamic> _ingChallenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipatingChallenges();
  }

  // 참여 중 챌린지 조회
  Future<void> _loadParticipatingChallenges() async {
    try {
      final response = await _challengeService.loadIngChallenges();

      setState(() {
        _ingChallenges = response.toList();
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  CategoryType? _parseCategoryType(String? category) {
    if (category == null) return null;

    switch (category.toUpperCase()) {
      case 'NATURE':
        return CategoryType.NaturePark;
      case 'CULTURE':
        return CategoryType.CultureArts;
      case 'TRAFFIC':
        return CategoryType.Transport;
      case 'RESIDENCE':
        return CategoryType.Life;
      case 'COMMERCIAL':
        return CategoryType.Commercial;
      case 'NIGHT':
        return CategoryType.NightLandscape;
      case 'ENVIRONMENT':
        return CategoryType.EnvironSustain;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppbar(title: '참가 중인 챌린지', leadingType: LeadingType.back),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ingChallenges.isEmpty
              ? const Center(child: Text('참가 중인 챌린지가 없습니다.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _ingChallenges.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final challenge = _ingChallenges[index];
                    return ChallengeItem(
                      categoryType: _parseCategoryType(challenge['category']),
                      title: challenge['title'] ?? '',
                      location: challenge['host'] ?? '',
                    );
                  },
                ),
    );
  }
}
