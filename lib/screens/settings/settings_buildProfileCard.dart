import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsBuildProfileCard extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? userInfo;

  const SettingsBuildProfileCard({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.userInfo,
  });

  @override
  State<SettingsBuildProfileCard> createState() =>
      _SettingsBuildProfileCardState();
}

class _SettingsBuildProfileCardState extends State<SettingsBuildProfileCard> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  /// 이미지 소스 선택 다이얼로그
  Future<void> _showImageSourceDialog() async {
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

        // TODO: 실제로는 여기서 서버에 이미지 업로드하고 URL을 받아와야 함
        // await _uploadProfileImage(image);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지를 선택하는데 실패했습니다: $e')));
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
    final imageUrl = _selectedImagePath ?? widget.userInfo!['profileImageUrl'];

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
          widget.userInfo!['name'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        SizedBox(height: height * 0.005),
        Text(
          '@${widget.userInfo!['id']}',
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
