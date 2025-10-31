import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:miyo/data/services/challenge_service.dart';

class AiSuggestionScreen extends StatefulWidget {
  const AiSuggestionScreen({super.key});

  @override
  State<AiSuggestionScreen> createState() => _AiSuggestionScreenState();
}

class _AiSuggestionScreenState extends State<AiSuggestionScreen> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _promptController = TextEditingController();
  final ChallengeService _challengeService = ChallengeService();

  String? _generatedImageUrl;
  bool _isGenerating = false;

  @override
  void dispose() {
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
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
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

  // AI 이미지 생성
  Future<void> _generateAiImage() async {
    // 프롬프트 유효성 검사
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('프롬프트를 입력해주세요.')));
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      Map<String, dynamic> result;

      // 이미지가 있으면 createImageFromImage, 없으면 createImage
      if (_images.isNotEmpty) {
        // 첫 번째 이미지를 base64로 변환
        final bytes = await _images.first.readAsBytes();
        final base64Image = base64Encode(bytes);

        // 이미지 업로드하여 URL 얻기
        final uploadResult = await _challengeService.bitmapImageUpload(
          base64Image: base64Image,
          contentType: 'image/jpeg',
        );

        // 업로드된 이미지 URL로 AI 이미지 생성
        final imageUrl =
            uploadResult['imageUrl'] ??
            uploadResult['url'] ??
            uploadResult['base64Image'] ??
            '';

        result = await _challengeService.createImageFromImage(
          imageUrl: imageUrl,
          prompt: _promptController.text.trim(),
          numberOfImages: 1,
          size: '1024x1024',
        );
      } else {
        // 프롬프트만으로 AI 이미지 생성
        result = await _challengeService.createImage(
          prompt: _promptController.text.trim(),
          numberOfImages: 1,
          size: '1024x1024',
        );
      }

      if (result['success'] == true && result['images'] != null) {
        final images = result['images'] as List;
        if (images.isNotEmpty) {
          setState(() {
            _generatedImageUrl = images[0];
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('AI 이미지가 생성되었습니다.'),
                backgroundColor: Color(0xff00AA5D),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
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
          _isGenerating = false;
        });
      }
    }
  }

  // 등록하기 - 생성된 이미지를 이전 화면으로 전달
  void _submitImage() {
    if (_generatedImageUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('먼저 이미지를 생성해주세요.')));
      return;
    }

    // 생성된 이미지 URL을 이전 화면으로 전달
    Navigator.pop(context, _generatedImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TitleAppbar(title: 'AI 스케치', leadingType: LeadingType.close),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                    }).toList(),
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
              SizedBox(height: height * 0.01),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '상상 이미지 생성',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                  hintText:
                      'AI 이미지 생성 프롬프트 \n* 상세한 프롬프트를 활용할수록 더 상세한 이미지가 생성됩니다.',
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
              SizedBox(
                height: height * 0.06,
                width: width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff00AA5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isGenerating ? null : _generateAiImage,
                  child: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          '이미지 생성하기',
                          style: TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              SizedBox(height: height * 0.02),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '생성된 이미지',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(height: height * 0.01),
              if (_generatedImageUrl != null)
                Container(
                  width: double.infinity,
                  height: height * 0.3,
                  decoration: BoxDecoration(
                    color: Color(0xffF0F2F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _generatedImageUrl!,
                      fit: BoxFit.fitWidth,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: height * 0.3,
                  decoration: BoxDecoration(
                    color: Color(0xffF0F2F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '이미지를 생성해주세요',
                      style: TextStyle(color: Color(0xff61758A), fontSize: 16),
                    ),
                  ),
                ),
              SizedBox(height: height * 0.02),
              SizedBox(
                height: height * 0.06,
                width: width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff00AA5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitImage,
                  child: Text(
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
