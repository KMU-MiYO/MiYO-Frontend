import 'package:flutter/material.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/components/challenge_item.dart';

class ChallengeDetailScreen extends StatefulWidget {
  const ChallengeDetailScreen({super.key});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreen();
}

class _ChallengeDetailScreen extends State<ChallengeDetailScreen> {
  // 챌린지 정보(챌린지 제목, 주관, 기간, 설명, 보상)내용 받아오기 필요

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppbar(title: '챌린지 정보', leadingType: LeadingType.close),
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () {
              // 참여하기 버튼 동작
            },
            child: const Text(
              '참여하기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ChallengeItem(
              icon: Icons.apartment_rounded,
              title: '2026 우리 동네 공원 상상하기',
              location: '서울시',
              isTitleBox: true,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Divider(color: Color(0x3E000000), thickness: 1.0),
            ),
            const Text(
              '챌린지 정보',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 17),
            Container(
              child: Column(
                children: [
                  const Text(
                    '기간',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '2025-09-24 ~ 2026-08-19',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 7),
                  const Text(
                    '설명',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '성북구 정릉로 77로에 새로 생길 공원에 대한 의견을 모집합니다.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '보상',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 13),
            Text(
              '1등 : 1000포인트',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
            Text(
              '2등 : 700포인트',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
            Text(
              '3등 : 500포인트',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 14),
            Text(
              '*모든 수상작은 공원 설계 및 시공에 반영될 수 있습니다.*',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 50),
            Row(
              children: [
                Text(
                  '제안',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {}, // 챌린지 제안 리스트 페이지로 이동
                  child: Text(
                    '+ 더보기',
                    style: TextStyle(
                      color: Color.fromRGBO(97, 117, 138, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 17),
            Row(
              children: [
                SizedBox(
                  height: 30,
                ), // 제안 글 제목 컴포넌트 넣을 곳 (1,2,3위 가로 자동 슬라이드 제공)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
