import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/components/suggestion_image.dart';
import 'package:miyo/components/profile_statistics.dart';
import 'dart:typed_data';
import 'package:miyo/screens/suggestion/my_suggestion_list.dart';
import 'package:miyo/screens/suggestion/suggestion_detail_screen.dart';
import 'package:miyo/data/services/user_service.dart';
import 'package:dio/dio.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  // 로딩 상태
  bool _isLoading = true;

  // 유저 데이터
  Uint8List? _profileImageData;
  String _nickname = '';
  String _id = '';
  String _joinYear = '';

  // 통계 데이터
  int _badgeCnt = 0; // 뱃지 수
  int _empathyCnt = 0; // 좋아요한 글
  int _commentCnt = 0; // 댓글 쓴 글
  int _suggestionCnt = 0; // 내가 쓴 글

  // 제안 목록
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 유저 데이터 로드
  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      // 병렬로 모든 API 호출
      final results = await Future.wait([
        _userService.getCurrentUser(), // 0: 유저 정보
        _userService.getMyEmpathyCnt(), // 1: 좋아요한 글 개수
        _userService.getMyCommentCnt(), // 2: 댓글 쓴 글 개수
        _userService.getMyPostCnt(), // 3: 내가 쓴 글 개수
        _userService.getMyPostList(size: 6), // 4: 내가 쓴 글 목록 (최대 6개)
        _userService.getMyBadge(), // 5: 내 뱃지 정보
      ]);

      final userData = results[0] as Map<String, dynamic>;
      final empathyCnt = results[1] as int;
      final commentCnt = results[2] as int;
      final suggestionCnt = results[3] as int;
      final postListData = results[4] as Map<String, dynamic>;
      final badgeData = results[5] as Map<String, dynamic>;

      print('📦 받아온 유저 데이터: $userData');

      // 닉네임
      _nickname = userData['nickname'] ?? '사용자';

      // 아이디
      _id = userData['userId'] ?? '';

      // 가입 연도 추출 (createdAt: '2025-01-15T10:30:00' -> '2025')
      final createdAt = userData['createdAt'] as String?;
      if (createdAt != null && createdAt.length >= 4) {
        _joinYear = createdAt.substring(0, 4);
      }

      // 통계 데이터
      _badgeCnt = badgeData['totalCount'] ?? 0;
      _empathyCnt = empathyCnt;
      _commentCnt = commentCnt;
      _suggestionCnt = suggestionCnt;

      // 게시글 목록 변환 및 이미지 다운로드
      final contentList = postListData['content'] as List;
      _suggestions = [];

      for (var post in contentList) {
        Uint8List? imageData;
        final imagePath = post['imagePath'] as String?;

        // 이미지 URL이 있으면 다운로드
        if (imagePath != null && imagePath.isNotEmpty) {
          try {
            final dio = Dio();
            final response = await dio.get(
              imagePath,
              options: Options(responseType: ResponseType.bytes),
            );
            if (response.statusCode == 200) {
              imageData = Uint8List.fromList(response.data);
            }
          } catch (e) {
            print('❌ 게시글 이미지 다운로드 실패: $e');
          }
        }

        _suggestions.add({
          'postId': post['postId'],
          'title': post['title'],
          'imagePath': imagePath,
          'imageData': imageData,
          'category': post['category'],
          'empathyCount': post['empathyCount'],
          'createdAt': post['createdAt'],
        });
      }

      // 프로필 이미지 다운로드
      final profilePictureUrl = userData['profilePicture'] as String?;
      if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
        await _downloadProfileImage(profilePictureUrl);
      }

      setState(() => _isLoading = false);

      print('✅ 프로필 데이터 로드 완료');
      print('   - nickname: $_nickname, id: $_id, joinYear: $_joinYear');
      print(
        '   - 통계: 뱃지 $_badgeCnt, 좋아요 $_empathyCnt, 댓글 $_commentCnt, 제안 $_suggestionCnt',
      );
      print('   - 게시글: ${_suggestions.length}개');
    } catch (e) {
      print('❌ 프로필 데이터 로드 실패: $e');
      setState(() => _isLoading = false);

      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('프로필 정보를 불러오는데 실패했습니다: $e')));
      }
    }
  }

  /// 프로필 이미지 다운로드
  Future<void> _downloadProfileImage(String imageUrl) async {
    try {
      print('🖼️ 프로필 이미지 다운로드 시작: $imageUrl');

      final dio = Dio();
      final response = await dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        setState(() {
          _profileImageData = Uint8List.fromList(response.data);
        });
        print('✅ 프로필 이미지 다운로드 완료');
      }
    } catch (e) {
      print('❌ 프로필 이미지 다운로드 실패: $e');
      // 이미지 다운로드 실패는 치명적이지 않으므로 기본 아이콘 사용
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: TitleAppbar(title: '프로필', actionType: ActionType.settings),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 데이터 로드 완료
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
                  child: _profileImageData != null
                      ? ClipOval(
                          child: Image.memory(
                            _profileImageData!,
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
              _nickname,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // ID
            Text(
              '@$_id',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff61758A),
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            // 가입 날짜
            Text(
              'Joined $_joinYear',
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
                  ProfileStatistics(count: '$_badgeCnt', label: '뱃지'),
                  const SizedBox(width: 8),
                  ProfileStatistics(count: '$_empathyCnt', label: '좋아요'),
                  const SizedBox(width: 8),
                  ProfileStatistics(count: '$_commentCnt', label: '댓글'),
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
                    '나의 제안 ($_suggestionCnt)',
                    style: const TextStyle(
                      fontSize: 22,
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
                        fontSize: 16,
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
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
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
