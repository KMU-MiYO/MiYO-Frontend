import 'package:flutter/material.dart';
import 'package:miyo/components/comment.dart';
import 'package:miyo/data/services/comment_service.dart';
import 'package:miyo/data/services/user_service.dart';

class CommentBottomSheet extends StatefulWidget {
  final int postId;

  const CommentBottomSheet({
    super.key,
    required this.postId,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final CommentService _commentService = CommentService();
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  int _currentPage = 0;
  final int _pageSize = 10;

  final TextEditingController _commentInputController = TextEditingController();
  final ScrollController _commentScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentInputController.dispose();
    _commentScrollController.dispose();
    super.dispose();
  }

  /// 댓글 목록 가져오기
  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _commentService.getComments(
        parentPostId: widget.postId,
        page: _currentPage,
        size: _pageSize,
      );

      final List<dynamic> content = response['content'] ?? [];
      final List<Map<String, dynamic>> comments = [];

      // 각 댓글에 대해 프로필 이미지 가져오기
      for (var item in content) {
        // API 응답에서 userId 필드를 찾아야 합니다.
        // 현재 응답에는 nickname만 있으므로, userId가 추가되어야 합니다.
        // 임시로 nickname을 사용하거나, API 응답 구조를 확인해야 합니다.

        Map<String, dynamic>? profileData;
        // userId가 있다면 프로필 이미지를 가져옵니다
        // if (item['userId'] != null) {
        //   try {
        //     final user = await _userService.getUserById(item['userId']);
        //     profileData = user['profileImage'];
        //   } catch (e) {
        //     print('프로필 이미지 로드 실패: $e');
        //   }
        // }

        comments.add({
          'profileImageData': profileData,
          'nickname': item['nickname'] ?? 'Unknown',
          'commentDetail': item['title'] ?? '', // API에 content 필드가 없어 title 사용
          'createdAt': _formatDate(item['createdAt']),
          'empathyCount': item['empathyCount'] ?? 0,
          'isEmpathied': false, // API 응답에 없으므로 기본값
          'replies': [], // 현재 API 응답에 대댓글 정보가 없음
        });
      }

      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      print('댓글 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글을 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  /// 날짜 포맷 변환
  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _toggleEmpathy(int index) {
    setState(() {
      _comments[index]['isEmpathied'] = !_comments[index]['isEmpathied'];
      if (_comments[index]['isEmpathied']) {
        _comments[index]['empathyCount']++;
      } else {
        _comments[index]['empathyCount']--;
      }
    });
  }

  void _toggleReplyEmpathy(int commentIndex, int replyIndex) {
    setState(() {
      final reply = _comments[commentIndex]['replies'][replyIndex];
      reply['isEmpathied'] = !reply['isEmpathied'];
      if (reply['isEmpathied']) {
        reply['empathyCount']++;
      } else {
        reply['empathyCount']--;
      }
    });
  }

  Future<void> _submitComment() async {
    if (_commentInputController.text.trim().isEmpty) return;

    final content = _commentInputController.text;
    _commentInputController.clear();

    try {
      await _commentService.writeComment(
        parentPostId: widget.postId,
        content: content,
      );

      // 댓글 작성 후 목록 새로고침
      await _loadComments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 작성되었습니다.')),
        );
      }
    } catch (e) {
      print('댓글 작성 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 작성에 실패했습니다: $e')),
        );
      }
      // 실패 시 입력 내용 복원
      _commentInputController.text = content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.05,
          maxChildSize: 0.95,
          builder: (BuildContext context, ScrollController sheetController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final currentHeight = constraints.maxHeight - 30;
                  return ListView(
                    controller: sheetController,
                    children: [
                      // 핸들
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xffF0F2F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // 댓글 리스트
                      SizedBox(
                        height: currentHeight,
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xff00AA5D),
                                ),
                              )
                            : _comments.isEmpty
                                ? const Center(
                                    child: Text(
                                      '첫 번째 댓글을 작성해보세요!',
                                      style: TextStyle(
                                        color: Color(0xff61758A),
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : Scrollbar(
                                    controller: _commentScrollController,
                                    thumbVisibility: true,
                                    thickness: 3,
                                    radius: const Radius.circular(2),
                                    child: ListView.builder(
                                      controller: _commentScrollController,
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        100,
                                      ),
                                      itemCount: _comments.length,
                                      itemBuilder: (context, index) {
                                        final comment = _comments[index];
                                        final replies =
                                            comment['replies'] as List<dynamic>;

                                        return Column(
                                          children: [
                                            CommentWidget(
                                              profileImageData:
                                                  comment['profileImageData'],
                                              nickname: comment['nickname'],
                                              commentDetail:
                                                  comment['commentDetail'],
                                              createdAt: comment['createdAt'],
                                              empathyCount:
                                                  comment['empathyCount'],
                                              isEmpathied: comment['isEmpathied'],
                                              onReplyTap: () {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        '답글 기능은 준비 중입니다.'),
                                                    duration:
                                                        Duration(seconds: 1),
                                                  ),
                                                );
                                              },
                                              onEmpathyTap: () =>
                                                  _toggleEmpathy(index),
                                              onReportTap: () {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        '신고 기능은 준비 중입니다.'),
                                                    duration:
                                                        Duration(seconds: 1),
                                                  ),
                                                );
                                              },
                                            ),
                                            if (replies.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 44,
                                                ),
                                                child: Column(
                                                  children: replies
                                                      .asMap()
                                                      .entries
                                                      .map(
                                                    (entry) {
                                                      final replyIndex =
                                                          entry.key;
                                                      final reply = entry.value;
                                                      return CommentWidget(
                                                        profileImageData: reply[
                                                            'profileImageData'],
                                                        nickname:
                                                            reply['nickname'],
                                                        commentDetail: reply[
                                                            'commentDetail'],
                                                        createdAt:
                                                            reply['createdAt'],
                                                        empathyCount: reply[
                                                            'empathyCount'],
                                                        isEmpathied:
                                                            reply['isEmpathied'],
                                                        onReplyTap: () {},
                                                        onEmpathyTap: () =>
                                                            _toggleReplyEmpathy(
                                                          index,
                                                          replyIndex,
                                                        ),
                                                        onReportTap: () {},
                                                      );
                                                    },
                                                  ).toList(),
                                                ),
                                              ),
                                            if (index < _comments.length - 1)
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                ),
                                                height: 1,
                                                color: const Color(0xffE0E0E0),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),

        // ✅ 항상 고정된 입력창
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xffE0E0E0), width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentInputController,
                      decoration: InputDecoration(
                        hintText: '댓글을 작성해보세요.',
                        hintStyle: const TextStyle(color: Color(0xff61758A)),
                        filled: true,
                        fillColor: const Color(0xffF0F2F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _submitComment,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xff00AA5D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
