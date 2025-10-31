import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:miyo/data/services/post_service.dart';
import 'package:miyo/data/services/challenge_service.dart';
import 'package:miyo/screens/suggestion/ai_suggestion_screen.dart';

class SuggestionScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final bool isContest;
  final int? contestId;

  const SuggestionScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.isContest = false,
    this.contestId,
  });

  @override
  State<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> {
  int? selectedIndex;
  final List<String> options = [
    '자연 / 공원',
    '문화 / 예술',
    '교통 / 이동',
    '주거 / 생활',
    '상권 / 시장',
    '야간 / 경관',
    '환경/지속 가능',
  ];
  final List<String> categoryApiValues = [
    'NATURE',
    'CULTURE',
    'TRAFFIC',
    'RESIDENCE',
    'COMMERCIAL',
    'NIGHT',
    'ENVIRONMENT',
  ];
  final List<File> _images = [];
  final List<String> _aiImageUrls = []; // AI 생성 이미지 URL 리스트
  final ImagePicker _picker = ImagePicker();
  final PostService _postService = PostService();
  final ChallengeService _challengeService = ChallengeService();

  // 텍스트 컨트롤러
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  // final TextEditingController _promptController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('사진 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Color(0xff00AA5D)),
                title: Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImagesFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _images.add(File(photo.path));
      });
    }
  }

  Future<void> _pickImagesFromGallery() async {
    final List<XFile> photos = await _picker.pickMultiImage();
    if (photos.isNotEmpty) {
      setState(() {
        _images.addAll(photos.map((photo) => File(photo.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // 갤러리 이미지를 서버에 업로드
  Future<String?> _uploadGalleryImage(File imageFile) async {
    try {
      // 이미지를 Base64로 인코딩
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 파일 확장자로 contentType 결정
      final extension = imageFile.path.split('.').last.toLowerCase();
      String contentType = 'image/jpeg';
      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        contentType = 'image/jpeg';
      }

      // 서버에 업로드
      final response = await _challengeService.bitmapImageUpload(
        base64Image: base64Image,
        contentType: contentType,
      );

      // 업로드된 이미지 URL 반환 (응답 구조에 따라 수정 필요)
      final imageUrl =
          response['imageUrl'] ?? response['url'] ?? response['imagePath'];

      return imageUrl as String?;
    } catch (e) {
      return null;
    }
  }

  // 게시글 등록
  Future<void> _submitPost() async {
    // 유효성 검사
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요.')));
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내용을 입력해주세요.')));
      return;
    }

    if (selectedIndex == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('카테고리를 선택해주세요.')));
      return;
    }

    // 일반 게시글(isContest가 false)일 때만 위치 정보 필수
    if (!widget.isContest &&
        (widget.latitude == null || widget.longitude == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('위치 정보가 없습니다.')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 이미지 선택: AI 이미지가 있으면 AI 이미지 URL, 없으면 갤러리 이미지 업로드
      String imagePath = '';

      if (_aiImageUrls.isNotEmpty) {
        // AI 생성 이미지가 있으면 첫 번째 AI 이미지 URL 사용
        imagePath = _aiImageUrls.first;
      } else if (_images.isNotEmpty) {
        // AI 이미지가 없고 갤러리 이미지가 있으면 서버에 업로드
        final uploadedUrl = await _uploadGalleryImage(_images.first);

        if (uploadedUrl == null || uploadedUrl.isEmpty) {
          throw Exception('이미지 업로드에 실패했습니다. 다시 시도해주세요.');
        }

        imagePath = uploadedUrl;
      }

      // API 호출
      final result;
      if (widget.isContest) {
        if (widget.contestId == null) {
          throw Exception('챌린지 ID가 필요합니다.');
        }
        result = await _postService.createContestPost(
          contestId: widget.contestId!,
          imagePath: imagePath,
          category: categoryApiValues[selectedIndex!],
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        );
      } else {
        result = await _postService.createPost(
          imagePath: imagePath,
          latitude: widget.latitude!,
          longitude: widget.longitude!,
          category: categoryApiValues[selectedIndex!],
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 등록되었습니다.'),
            backgroundColor: Color(0xff00AA5D),
          ),
        );

        // 등록 완료 후 이전 화면으로 돌아가기
        Navigator.pop(context, result);
      }
    } catch (e) {
      if (mounted) {
        // Exception 객체에서 메시지만 추출
        final errorMessage = e.toString().replaceFirst('Exception: ', '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TitleAppbar(title: '새로운 제안', leadingType: LeadingType.back),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xffF0F2F5),
                        hintText: '제목',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff61758A),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    TextField(
                      controller: _contentController,
                      minLines: 10,
                      maxLines: 15,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xffF0F2F5),
                        hintText: '내용',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff61758A),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '카테고리',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(height: height * 0.01),
              LayoutBuilder(
                builder: (context, constraints) {
                  // 사용 가능한 너비 = 전체 너비
                  final availableWidth = constraints.maxWidth;
                  // 버튼 간 간격
                  const spacing = 8.0;
                  // 한 줄에 4개 배치: (버튼 너비 * 4) + (간격 * 3) = 사용 가능한 너비
                  final buttonWidth = (availableWidth - (spacing * 3)) / 4;

                  return Wrap(
                    alignment: WrapAlignment.start,
                    spacing: spacing,
                    runSpacing: 8,
                    children: List.generate(
                      options.length,
                      (index) => SizedBox(
                        width: buttonWidth,
                        height: 33,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 2,
                            ),
                            backgroundColor: selectedIndex == index
                                ? Color(0xff00AA5D)
                                : Color(0xffF0F2F5),
                            foregroundColor: selectedIndex == index
                                ? Colors.white
                                : Color(0xff61758A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            options[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: height * 0.02),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '갤러리 이미지 첨부',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(height: height * 0.01),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ..._images.asMap().entries.map((entry) {
                      int index = entry.key;
                      File image = entry.value;
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              image,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Color(0xffF0F2F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_circle_outline_rounded,
                          size: 40,
                          color: Color(0xff00AA5D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '상상 이미지 추가',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // AI 생성 이미지들
                    ..._aiImageUrls.asMap().entries.map((entry) {
                      int index = entry.key;
                      String imageUrl = entry.value;
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Color(0xffF0F2F5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Color(0xffF0F2F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 32,
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _aiImageUrls.removeAt(index);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    // + 버튼
                    GestureDetector(
                      onTap: () async {
                        // AI 이미지 생성 화면으로 이동
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AiSuggestionScreen(),
                          ),
                        );

                        // AI 이미지가 생성되어 돌아왔을 때 처리
                        if (result != null && result is String) {
                          setState(() {
                            _aiImageUrls.add(result);
                          });

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('AI 이미지가 추가되었습니다.'),
                                backgroundColor: Color(0xff00AA5D),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Color(0xffF0F2F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_circle_outline_rounded,
                          size: 40,
                          color: Color(0xff00AA5D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
              SizedBox(
                height: height * 0.06,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff00AA5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submitPost,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          '등록하기',
                          style: TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }
}
