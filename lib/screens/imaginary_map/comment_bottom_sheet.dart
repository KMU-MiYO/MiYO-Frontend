import 'package:flutter/material.dart';
import 'package:miyo/components/comment.dart';
import 'package:miyo/data/services/comment_service.dart';
import 'package:miyo/data/services/post_service.dart';
import 'package:miyo/data/services/user_service.dart';

class CommentBottomSheet extends StatefulWidget {
  final int postId;
  final bool isChallenge;

  const CommentBottomSheet({
    super.key,
    required this.postId,
    this.isChallenge = false,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final CommentService _commentService = CommentService();
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;

  // 답글 작성 관련
  bool _isReplyMode = false;
  int? _replyToPostId;
  String? _replyToNickname;

  final TextEditingController _commentInputController = TextEditingController();
  final ScrollController _commentScrollController = ScrollController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadComments();

    // TextField 포커스 감지
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _commentInputController.dispose();
    _commentScrollController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      // TextField가 포커스될 때 시트를 최대로 확장
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_sheetController.isAttached) {
          _sheetController.animateTo(
            0.90,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// 댓글 목록 가져오기
  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> postData;

      if (widget.isChallenge) {
        postData = await _postService.getContestsPostById(
          contestId: widget.postId,
          postId: widget.postId,
        );
      } else {
        // getPostById를 사용하여 게시글과 댓글 정보를 함께 가져오기
        postData = await _postService.getPostById(postId: widget.postId);
      }

      final List<dynamic> commentsFromApi = postData['comments'] ?? [];
      final List<Map<String, dynamic>> comments = [];

      // 댓글 데이터 처리
      for (var item in commentsFromApi) {
        String? profileImageUrl;
        // userId가 있다면 프로필 이미지를 가져옵니다
        if (item['userId'] != null) {
          try {
            final user = await _userService.getUserById(item['userId']);
            // API 응답에서 profilePicture 필드를 사용
            profileImageUrl = user['profilePicture'];
          } catch (e) {
            print('프로필 이미지 로드 실패 (userId: ${item['userId']}): $e');
          }
        }

        // 대댓글 처리
        final List<Map<String, dynamic>> replies = [];
        if (item['replies'] != null && item['replies'] is List) {
          for (var reply in item['replies']) {
            String? replyProfileImageUrl;
            if (reply['userId'] != null) {
              try {
                final user = await _userService.getUserById(reply['userId']);
                // API 응답에서 profilePicture 필드를 사용
                replyProfileImageUrl = user['profilePicture'];
              } catch (e) {
                print('대댓글 프로필 이미지 로드 실패 (userId: ${reply['userId']}): $e');
              }
            }

            replies.add({
              'postId': reply['postId'],
              'profileImagePath': replyProfileImageUrl,
              'nickname': reply['userNickname'] ?? 'Unknown',
              'commentDetail': reply['content'] ?? '',
              'createdAt': _formatDate(reply['createdAt']),
              'empathyCount': reply['empathyCount'] ?? 0,
              'isEmpathied': reply['isEmpathized'] ?? false,
            });
          }
        }

        comments.add({
          'postId': item['postId'],
          'profileImagePath': profileImageUrl,
          'nickname': item['userNickname'] ?? 'Unknown',
          'commentDetail': item['content'] ?? '',
          'createdAt': _formatDate(item['createdAt']),
          'empathyCount': item['empathyCount'] ?? 0,
          'isEmpathied': item['isEmpathized'] ?? false,
          'replies': replies,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('댓글을 불러오는데 실패했습니다: $e')));
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

  /// 답글 작성 모드 시작
  void _startReplyMode(int postId, String nickname) {
    setState(() {
      _isReplyMode = true;
      _replyToPostId = postId;
      _replyToNickname = nickname;
    });
  }

  /// 답글 작성 모드 취소
  void _cancelReplyMode() {
    setState(() {
      _isReplyMode = false;
      _replyToPostId = null;
      _replyToNickname = null;
    });
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
      // 답글 모드인지 일반 댓글 모드인지 확인
      final int targetPostId = _isReplyMode && _replyToPostId != null
          ? _replyToPostId!
          : widget.postId;

      await _commentService.writeComment(
        parentPostId: targetPostId,
        content: content,
      );

      // 답글 모드 취소
      if (_isReplyMode) {
        _cancelReplyMode();
      }

      // 댓글 작성 후 목록 새로고침
      await _loadComments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isReplyMode ? '답글이 작성되었습니다.' : '댓글이 작성되었습니다.'),
          ),
        );
      }
    } catch (e) {
      print('댓글 작성 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('댓글 작성에 실패했습니다: $e')));
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
          controller: _sheetController,
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.90,
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
                                          profileImagePath:
                                              comment['profileImagePath'],
                                          nickname: comment['nickname'],
                                          commentDetail:
                                              comment['commentDetail'],
                                          createdAt: comment['createdAt'],
                                          empathyCount: comment['empathyCount'],
                                          isEmpathied: comment['isEmpathied'],
                                          onReplyTap: () {
                                            _startReplyMode(
                                              comment['postId'],
                                              comment['nickname'],
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
                                                  '신고 기능은 준비 중입니다.',
                                                ),
                                                duration: Duration(seconds: 1),
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
                                              children: replies.asMap().entries.map((
                                                entry,
                                              ) {
                                                final replyIndex = entry.key;
                                                final reply = entry.value;
                                                return CommentWidget(
                                                  profileImagePath:
                                                      reply['profileImagePath'],
                                                  nickname: reply['nickname'],
                                                  commentDetail:
                                                      reply['commentDetail'],
                                                  createdAt: reply['createdAt'],
                                                  empathyCount:
                                                      reply['empathyCount'],
                                                  isEmpathied:
                                                      reply['isEmpathied'],
                                                  onReplyTap: () {
                                                    _startReplyMode(
                                                      reply['postId'],
                                                      reply['nickname'],
                                                    );
                                                  },
                                                  onEmpathyTap: () =>
                                                      _toggleReplyEmpathy(
                                                        index,
                                                        replyIndex,
                                                      ),
                                                  onReportTap: () {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          '신고 기능은 준비 중입니다.',
                                                        ),
                                                        duration: Duration(
                                                          seconds: 1,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        if (index < _comments.length - 1)
                                          Container(
                                            margin: const EdgeInsets.symmetric(
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

        // ✅ 키보드 높이에 반응하는 입력창
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xffE0E0E0), width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 답글 모드일 때 표시되는 바
                  if (_isReplyMode && _replyToNickname != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: const Color(0xffF0F2F5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '@$_replyToNickname에게 답글을 남기는 중',
                              style: const TextStyle(
                                color: Color(0xff00AA5D),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _cancelReplyMode,
                            child: const Icon(
                              Icons.close,
                              color: Color(0x8061758A),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // 입력창
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentInputController,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: '댓글을 작성해보세요.',
                              hintStyle: const TextStyle(
                                color: Color(0xff61758A),
                              ),
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
