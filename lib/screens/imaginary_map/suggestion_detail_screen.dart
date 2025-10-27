import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';

class SuggestionDetailScreen extends StatefulWidget {
  const SuggestionDetailScreen({super.key});

  @override
  State<SuggestionDetailScreen> createState() => _SuggestionDetailScreenState();
}

class _SuggestionDetailScreenState extends State<SuggestionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppbar(title: '제안 상세보기', leadingType: LeadingType.back),
      body: Container(color: Colors.white),
    );
  }
}
