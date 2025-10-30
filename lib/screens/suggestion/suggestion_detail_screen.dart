import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/screens/imaginary_map/comment_bottom_sheet.dart';
import 'package:miyo/data/services/post_service.dart';

class SuggestionDetailScreen extends StatefulWidget {
  final int postId;

  const SuggestionDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<SuggestionDetailScreen> createState() => _SuggestionDetailScreenState();
}

class _SuggestionDetailScreenState extends State<SuggestionDetailScreen> {
  final PostService _postService = PostService();
  Map<String, dynamic>? postData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  Future<void> _loadPostData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _postService.getPostById(postId: widget.postId);
      setState(() {
        postData = data;
        isLoading = false;
      });
    } catch (e) {
      print('❌ 게시글 로드 실패: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글을 불러오는데 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void toggleEmpathy() {
    if (postData == null) return;

    setState(() {
      if (postData!['isEmpathized']) {
        postData!['isEmpathized'] = false;
        postData!['empathyCount']--;
      } else {
        postData!['isEmpathized'] = true;
        postData!['empathyCount']++;
      }
    });
  }

  String getCategoryKorean(String category) {
    switch (category) {
      case 'NATURE':
        return '자연 / 공원';
      case 'CULTURE':
        return '문화 / 예술';
      case 'TRAFFIC':
        return '교통 / 이동';
      case 'RESIDENCE':
        return '주거 / 생활';
      case 'COMMERCE':
        return '상권 / 시장';
      case 'NIGHT':
        return '야간 / 경관';
      case 'ENVIRONMENT':
        return '환경 / 지속 가능';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // 로딩 중
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: TitleAppbar(title: '상세보기', leadingType: LeadingType.back),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xff00AA5D),
          ),
        ),
      );
    }

    // 데이터 로드 실패
    if (postData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: TitleAppbar(title: '상세보기', leadingType: LeadingType.back),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '게시글을 불러올 수 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TitleAppbar(title: '상세보기', leadingType: LeadingType.back),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: toggleEmpathy,
                child: Icon(
                  postData!['isEmpathized']
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: postData!['isEmpathized']
                      ? Colors.red
                      : Color(0xff61758A),
                  size: 24,
                ),
              ),
              GestureDetector(
                onTap: toggleEmpathy,
                child: Text(
                  '${postData!['empathyCount']}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff61758A),
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.055,
                width: width * 0.75,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff00AA5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const CommentBottomSheet(),
                    );
                  },
                  child: Text(
                    '댓글 작성하기',
                    style: TextStyle(
                      color: Color(0xffffffff),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              postData!['imagePath'] != null
                  ? Image.network(
                      postData!['imagePath'],
                      width: width,
                      height: height * 0.5,
                      fit: BoxFit.fitWidth,
                      errorBuilder: (context, error, stackTrace) {
                        return Image(
                          image: AssetImage('assets/images/miyo_logo.png'),
                          width: width,
                          height: height * 0.5,
                          fit: BoxFit.fitWidth,
                        );
                      },
                    )
                  : Image(
                      image: AssetImage('assets/images/miyo_logo.png'),
                      width: width,
                      height: height * 0.5,
                      fit: BoxFit.fitWidth,
                    ),
              SizedBox(height: height * 0.02),
              // 제목
              Text(
                postData!['title'] ?? '제목 없음',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              // 작성자 및 날짜
              Row(
                children: [
                  Text(
                    postData!['nickname'] ?? '익명',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff61758A),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('•', style: TextStyle(color: Color(0xff61758A))),
                  SizedBox(width: 8),
                  Text(
                    postData!['createdAt']?.toString().substring(0, 10) ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff61758A),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),
              // 내용
              Text(
                postData!['content'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
              SizedBox(height: height * 0.03),
              Text(
                '카테고리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: height * 0.01),
              // 카테고리
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xff00AA5D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getCategoryKorean(postData!['category'] ?? 'NATURE'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
