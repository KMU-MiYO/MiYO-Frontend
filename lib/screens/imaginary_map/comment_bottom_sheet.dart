import 'package:flutter/material.dart';
import 'package:miyo/components/comment.dart';

class CommentBottomSheet extends StatefulWidget {
  const CommentBottomSheet({super.key});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final List<Map<String, dynamic>> _comments = [
    {
      'profileImageData': null,
      'nickname': '일어나라미요',
      'commentDetail':
          '진짜 너무 공감돼요... 자전거 타는 사람도 많은데 따로 만들어지면 더 안전한 공원이 될 것 같아요.',
      'createdAt': '2024/02/03',
      'empathyCount': 0,
      'isEmpathied': false,
      'replies': [
        {
          'profileImageData': null,
          'nickname': '일어나라미요',
          'commentDetail':
              '진짜 너무 공감돼요... 자전거 타는 사람도 많은데 따로 만들어지면 더 안전한 공원이 될 것 같아요.',
          'createdAt': '2024/02/03',
          'empathyCount': 0,
          'isEmpathied': false,
        },
        {
          'profileImageData': null,
          'nickname': 'halulala',
          'commentDetail': '마자요. 저도 우리 땡솜이랑 같이 다닐 때마다 자전거가 슝 같이 다녀서...더보기',
          'createdAt': '2024/02/03',
          'empathyCount': 0,
          'isEmpathied': false,
        },
      ],
    },
    {
      'profileImageData': null,
      'nickname': '산책러버',
      'commentDetail': '이 아이디어 정말 좋네요! 저도 동의합니다.',
      'createdAt': '2024/02/03',
      'empathyCount': 5,
      'isEmpathied': false,
      'replies': [],
    },
  ];

  final TextEditingController _commentInputController = TextEditingController();
  final ScrollController _commentScrollController = ScrollController();

  @override
  void dispose() {
    _commentInputController.dispose();
    super.dispose();
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

  void _submitComment() {
    if (_commentInputController.text.trim().isEmpty) return;

    setState(() {
      _comments.add({
        'profileImageData': null,
        'nickname': '나',
        'commentDetail': _commentInputController.text,
        'createdAt': '방금 전',
        'empathyCount': 0,
        'isEmpathied': false,
        'replies': [],
      });
    });

    _commentInputController.clear();
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
                        child: Scrollbar(
                          controller: _commentScrollController,
                          thumbVisibility: true,
                          thickness: 3,
                          radius: Radius.circular(2),
                          child: Expanded(
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
                                      commentDetail: comment['commentDetail'],
                                      createdAt: comment['createdAt'],
                                      empathyCount: comment['empathyCount'],
                                      isEmpathied: comment['isEmpathied'],
                                      onReplyTap: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('답글 기능은 준비 중입니다.'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      onEmpathyTap: () => _toggleEmpathy(index),
                                      onReportTap: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('신고 기능은 준비 중입니다.'),
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
                                          children: replies.asMap().entries.map(
                                            (entry) {
                                              final replyIndex = entry.key;
                                              final reply = entry.value;
                                              return CommentWidget(
                                                profileImageData:
                                                    reply['profileImageData'],
                                                nickname: reply['nickname'],
                                                commentDetail:
                                                    reply['commentDetail'],
                                                createdAt: reply['createdAt'],
                                                empathyCount:
                                                    reply['empathyCount'],
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
