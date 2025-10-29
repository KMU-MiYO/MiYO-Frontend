import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/components/suggestion_image.dart';
import 'package:miyo/components/profile_statistics.dart';
import 'dart:typed_data';
import 'package:miyo/screens/suggestion/my_suggestion_list.dart';
import 'package:miyo/screens/suggestion/suggestion_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Uint8List? profileImageData;
  final String nickname;
  final String id;
  final String joinYear;
  final int badgeCnt;
  final int favorateCnt;
  final int commentCnt;
  final int suggestionCnt;
  final List<Map<String, dynamic>> suggestions;

  const ProfileScreen({
    super.key,
    this.profileImageData,
    required this.nickname,
    required this.id,
    required this.joinYear,
    required this.badgeCnt,
    required this.favorateCnt,
    required this.commentCnt,
    required this.suggestionCnt,
    this.suggestions = const [],
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TitleAppbar(title: '프로필', actionType: ActionType.settings),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 프로필 이미지
            Stack(
              children: [
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xffFFCCBC),
                  ),
                  child: widget.profileImageData != null
                      ? ClipOval(
                          child: Image.memory(
                            widget.profileImageData!,
                            width: 128,
                            height: 128,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 닉네임
            Text(
              widget.nickname,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // ID
            Text(
              '@${widget.id}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff61758A),
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            // 가입 날짜
            Text(
              'Joined ${widget.joinYear}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff61758A),
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 24),
            // 통계 (뱃지, 좋아요, 댓글)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ProfileStatistics(count: '${widget.badgeCnt}', label: '뱃지'),
                  const SizedBox(width: 8),
                  ProfileStatistics(
                    count: '${widget.favorateCnt}',
                    label: '좋아요',
                  ),
                  const SizedBox(width: 8),
                  ProfileStatistics(count: '${widget.commentCnt}', label: '댓글'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 나의 제안
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '나의 제안 (${widget.suggestionCnt})',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MySuggestionScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '모두 보기',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff61758A),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 갤러리 격자 (2열)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.85,
                ),
                itemCount: widget.suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = widget.suggestions[index];
                  return SuggestionImage(
                    imageData: suggestion['imageData'],
                    suggestionTitle: suggestion['title'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuggestionDetailScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
