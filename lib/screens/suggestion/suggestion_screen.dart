import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:miyo/data/services/post_service.dart';

class SuggestionScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const SuggestionScreen({
    super.key,
    this.latitude,
    this.longitude,
  });

  @override
  State<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> {
  int? selectedIndex;
  final List<String> options = ['자연 / 공원', '문화 / 예술', '교통 / 이동', '주거 / 생활', '상권 / 시장', '야간 / 경관', '환경/지속 가능'];
  final List<String> categoryApiValues = ['NATURE', 'CULTURE', 'TRANSPORT', 'LIFE', 'COMMERCIAL', 'NIGHT', 'ENVIRONMENT'];
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  final PostService _postService = PostService();

  // 텍스트 컨트롤러
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _promptController.dispose();
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
                leading: Icon(
                  Icons.camera_alt, 
                  color: Colors.blue
                  ),
                title: Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library, 
                  color: Colors.green),
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

  // 게시글 등록
  Future<void> _submitPost() async {
    // 유효성 검사
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요.')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요.')),
      );
      return;
    }

    if (selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요.')),
      );
      return;
    }

    if (widget.latitude == null || widget.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 정보가 없습니다.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 이미지 경로 (첫 번째 이미지 사용, 없으면 빈 문자열)
      final imagePath = _images.isNotEmpty ? _images.first.path : '';

      print('📝 게시글 등록 시도:');
      print('- 제목: ${_titleController.text.trim()}');
      print('- 내용: ${_contentController.text.trim()}');
      print('- 카테고리: ${categoryApiValues[selectedIndex!]}');
      print('- 위도: ${widget.latitude}');
      print('- 경도: ${widget.longitude}');
      print('- 이미지: $imagePath');

      // API 호출
      final result = await _postService.createPost(
        imagePath: imagePath,
        latitude: widget.latitude!,
        longitude: widget.longitude!,
        category: categoryApiValues[selectedIndex!],
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );

      print('✅ 게시글 등록 성공: $result');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 등록되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );

        // 등록 완료 후 이전 화면으로 돌아가기
        Navigator.pop(context, result);
      }
    } catch (e) {
      print('❌ 게시글 등록 실패: $e');

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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.01),
                Transform.translate(
                  offset: Offset(-8, 0),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: width * 0.02,
                    children: List.generate(
                    options.length,
                    (index) => ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(
                          85, 
                          27,
                          ),
                        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
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
                ),
                SizedBox(height: height * 0.02),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '갤러리 이미지 첨부',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
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
                    '상상 이미지 생성',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                TextField(
                  controller: _promptController,
                  minLines: 10,
                  maxLines: 15,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xffF0F2F5),
                    hintText: 'AI 이미지 생성 프롬프트 \n* 상세한 프롬프트를 활용할수록 더 상세한 이미지가 생성됩니다.',
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
                SizedBox(height: height * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: height * 0.06,
                        child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff00AA5D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Navigator.push(
                          //   context, MaterialPageRoute(builder: (context) => ()));                
                        }, 
                        child: Text(
                          '이미지 생성하기',
                          style: TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    Expanded(
                      child: SizedBox(
                        height: height * 0.06,
                        child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffF0F2F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Navigator.push(
                          //   context, MaterialPageRoute(builder: (context) => ()));                
                        }, 
                        child: Text(
                          '닫기',
                          style: TextStyle(
                            color: Color(0xff61758A),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        ),
                      ),
                    ),
                  ],
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