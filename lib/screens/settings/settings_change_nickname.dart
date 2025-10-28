import 'package:flutter/material.dart';
import 'package:miyo/data/services/user_service.dart';

/// 닉네임 변경 다이얼로그 표시
///
/// [context]: BuildContext
/// [currentNickname]: 현재 닉네임
/// [onNicknameChanged]: 닉네임 변경 성공 시 콜백 (업데이트된 유저 정보)
Future<void> showNicknameChangeDialog({
  required BuildContext context,
  required String currentNickname,
  required Function(Map<String, dynamic>) onNicknameChanged,
}) async {
  final TextEditingController nicknameController = TextEditingController();
  final UserService userService = UserService();
  nicknameController.text = currentNickname;

  // 스낵바 표시를 위해 부모 context 저장
  final parentContext = context;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                final isEmpty = nicknameController.text.trim().isEmpty;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      '닉네임 변경',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '새로운 닉네임을 입력해주세요.',
                      style: TextStyle(fontSize: 14, color: Color(0xff757575)),
                    ),
                    SizedBox(height: 24),

                    // 닉네임 입력 필드
                    TextField(
                      controller: nicknameController,
                      autofocus: true,
                      onChanged: (value) {
                        setModalState(() {}); // 텍스트 변경 시 UI 업데이트
                      },
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xff757575),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 15,
                        ),
                        hintText: '닉네임',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Color(0xff757575),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xff00AA5D),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        isEmpty ? '닉네임은 공백이 될 수 없습니다.' : '프로필 상의 이름을 설정해 주세요.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isEmpty ? Colors.red : Color(0xffACACAC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // 버튼 영역
                    Row(
                      children: [
                        // 확인 버튼
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                final newNickname = nicknameController.text
                                    .trim();
                                if (newNickname.isEmpty) {
                                  return;
                                }
                                if (newNickname == currentNickname) {
                                  Navigator.pop(context);
                                  return;
                                }

                                // 다이얼로그 닫기
                                Navigator.pop(context);

                                // 닉네임 업데이트
                                try {
                                  final updatedUserInfo = await userService
                                      .updateUserNickName(newNickname);

                                  // 성공 콜백 호출
                                  onNicknameChanged(updatedUserInfo);

                                  // 성공 메시지
                                  if (parentContext.mounted) {
                                    ScaffoldMessenger.of(
                                      parentContext,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text('닉네임이 변경되었습니다.'),
                                        backgroundColor: Color(0xff00AA5D),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  // 에러 메시지
                                  if (parentContext.mounted) {
                                    ScaffoldMessenger.of(
                                      parentContext,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text('닉네임 변경에 실패했습니다'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff00AA5D),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                '변경',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        // 취소 버튼
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Color(0xffDBE0E5),
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                '취소',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff757575),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
