import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miyo/data/services/user_service.dart';
import 'dart:io';

class SettingsBuildProfileCard extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? userInfo;
  final Function(Map<String, dynamic>)? onProfileImageChanged;

  const SettingsBuildProfileCard({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.userInfo,
    this.onProfileImageChanged,
  });

  @override
  State<SettingsBuildProfileCard> createState() =>
      _SettingsBuildProfileCardState();
}

class _SettingsBuildProfileCardState extends State<SettingsBuildProfileCard> {
  final ImagePicker _picker = ImagePicker();
  final UserService _userService = UserService();
  String? _selectedImagePath;
  bool _isUploading = false;

  /// 이미지 소스 선택 다이얼로그
  Future<void> _showImageSourceDialog() async {
    // 업로드 중일 때는 다이얼로그 표시 안 함
    if (_isUploading) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('갤러리에서 선택'),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('카메라로 촬영'),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 이미지 선택
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });

        // 서버에 이미지 업로드
        await _uploadProfileImage(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지를 선택하는데 실패했습니다: $e')));
    }
  }

  /// 프로필 이미지 업로드
  Future<void> _uploadProfileImage(String imagePath) async {
    setState(() {
      _isUploading = true;
    });

    try {
      // UserService를 통해 프로필 이미지 업로드
      final updatedUserInfo = await _userService.updateProfileImage(imagePath);

      // 업로드 성공 시 부모 위젯에 알림
      if (widget.onProfileImageChanged != null) {
        widget.onProfileImageChanged!(updatedUserInfo);
      }

      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 이미지가 변경되었습니다'),
            backgroundColor: Color(0xff00AA5D),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 에러 발생 시 선택된 이미지 초기화
      setState(() {
        _selectedImagePath = null;
      });

      // 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 이미지 변경에 실패했습니다'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.errorMessage != null) {
      return Center(child: Text(widget.errorMessage!));
    }

    if (widget.userInfo == null) {
      return const Center(child: Text('유저 정보가 없습니다'));
    }

    // 선택된 이미지가 있으면 그것을 사용, 없으면 userInfo의 이미지 사용
    final imageUrl = _selectedImagePath ?? widget.userInfo!['profilePicture'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 135 / 2,
              backgroundColor: Color(0xff00AA5D),
              backgroundImage: imageUrl != null
                  ? (imageUrl.startsWith('http')
                        ? NetworkImage(imageUrl)
                        : (imageUrl.startsWith('/')
                              ? FileImage(File(imageUrl))
                              : AssetImage(imageUrl)))
                  : null,
              child: imageUrl == null
                  ? Icon(Icons.person, size: 80, color: Colors.white)
                  : null,
            ),
            // 업로드 중 로딩 인디케이터
            if (_isUploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffD9D9D9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: height * 0.01),
        Text(
          widget.userInfo!['nickname'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        SizedBox(height: height * 0.005),
        Text(
          '@${widget.userInfo!['userId']}',
          style: TextStyle(fontSize: 16, color: Color(0xff61758A)),
        ),
        Text(
          'Joined ${DateTime.parse(widget.userInfo!['createdAt']).year}',
          style: TextStyle(fontSize: 16, color: Color(0xff61758A)),
        ),
      ],
    );
  }
}
