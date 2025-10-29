import 'package:flutter/material.dart';
import 'package:miyo/components/exchange_list_item.dart';
import 'package:miyo/components/title_appbar.dart';

class ExchangeScreen extends StatefulWidget {
  final String point;
  const ExchangeScreen({super.key, required this.point});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final List<Map<String, String>> exchangeItems = [
    {'localCachePrice': '120,000', 'pointPrice': '100,000'},
    {'localCachePrice': '55,000', 'pointPrice': '50,000'},
    {'localCachePrice': '33,000', 'pointPrice': '30,000'},
    {'localCachePrice': '10,000', 'pointPrice': '10,000'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TitleAppbar(title: '교환소', leadingType: LeadingType.close),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xff00AA5D),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.point,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 2, color: Color(0x40000000)),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '지역 화폐',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 3),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exchangeItems.length,
              itemBuilder: (context, index) {
                final item = exchangeItems[index];
                return Column(
                  children: [
                    ExchangeListItem(
                      localCachePrice: item['localCachePrice']!,
                      pointPrice: item['pointPrice']!,
                      onTap: () {
                        // 교환 로직
                      },
                    ),
                    const Divider(height: 1, color: Color(0xffCCCCCC)),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '주의 사항',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletText('지역 화폐는 본인이 거주하는 지자체에서 발행하는 화폐로만 교환 가능합니다.'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      '예를 들어 서울특별시 성북구 거주자는 성북사랑상품권, 경기도 파주시 거주자는 파주페이로 지급됩니다.',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: const Color(0xff757575),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletText('교환 신청 후 취소는 불가능하오니, 신중하게 교환 부탁드립니다.'),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(fontSize: 13, color: Colors.black, height: 1.5),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 13,
              color: Colors.black,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
