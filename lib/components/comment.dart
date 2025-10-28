// lib/components/comment.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';

// 댓글 위젯
class CommentWidget extends StatelessWidget {
  final Uint8List? profileImageData; // 프로필 이미지 (nullable)
  final String nickname;
  final String commentDetail;
  final String createdAt; // 작성 시간
  final int replyCount; // 답글 개수
  final int empathyCount; // 좋아요 개수
  final bool isEmpathied; // 좋아요 눌렀는지 여부
  final VoidCallback? onReplyTap; // 답글달기 클릭 콜백
  final VoidCallback? onEmpathyTap; // 좋아요 클릭 콜백
  final VoidCallback? onReportTap; // 신고 클릭 콜백

  const CommentWidget({
    super.key,
    this.profileImageData,
    required this.nickname,
    required this.commentDetail,
    required this.createdAt,
    this.replyCount = 0,
    this.empathyCount = 0,
    this.isEmpathied = false,
    this.onReplyTap,
    this.onEmpathyTap,
    this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffE0E0E0),
                ),
                child: profileImageData != null
                    ? ClipOval(
                        child: Image.memory(
                          profileImageData!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                nickname,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEmpathyTap,
                child: Icon(
                  isEmpathied ? Icons.favorite : Icons.favorite_border,
                  color: isEmpathied ? Colors.red : Color(0xff9E9E9E),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            commentDetail,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xff686868),
              height: 1.4,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                createdAt,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xff686868),
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onReplyTap,
                child: Text(
                  '답글달기',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff686868),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '좋아요 $empathyCount',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xff686868),
                  fontWeight: FontWeight.normal,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onReportTap,
                child: Text(
                  '신고',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff686868),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
