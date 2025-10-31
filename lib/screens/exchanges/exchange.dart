import 'package:flutter/material.dart';
import 'package:miyo/components/exchange_list_item.dart';
import 'package:miyo/components/title_appbar.dart';
import 'package:miyo/data/services/exchange_service.dart';
import 'package:miyo/data/services/user_service.dart';

class ExchangeScreen extends StatefulWidget {
  final String point;
  const ExchangeScreen({super.key, required this.point});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final RewardService _rewardService = RewardService();
  final UserService _userService = UserService();
  late String currentPoint;
  bool _isExchanging = false;

  final List<Map<String, dynamic>> exchangeItems = [
    {
      'localCachePrice': '100,000',
      'pointPrice': '120,000',
      'pointValue': 120000,
    },
    {'localCachePrice': '50,000', 'pointPrice': '53,000', 'pointValue': 55000},
    {'localCachePrice': '30,000', 'pointPrice': '35,000', 'pointValue': 33000},
    {'localCachePrice': '10,000', 'pointPrice': '10,000', 'pointValue': 10000},
  ];

  @override
  void initState() {
    super.initState();
    currentPoint = widget.point;
  }

  /// 교환 처리
  Future<void> _handleExchange(int pointValue, String localCachePrice) async {
    // 포인트 부족 체크
    final currentPointValue =
        int.tryParse(currentPoint.replaceAll(',', '')) ?? 0;
    if (currentPointValue < pointValue) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('포인트가 부족합니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('교환 확인'),
        content: Text('지역 화폐 $localCachePrice원권으로 교환하시겠습니까?\n교환 후 취소는 불가능합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('교환', style: TextStyle(color: Color(0xff00AA5D))),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isExchanging = true;
    });

    try {
      // 현재 로그인한 사용자 정보 가져오기
      final user = await _userService.getCurrentUser();
      final userId = user['userId'] as String;

      // 포인트 차감 계산
      final newPointValue = currentPointValue - pointValue;

      // API 호출
      await _rewardService.rewardUpdate(
        userId: userId,
        v: '-$pointValue', // 음수로 전달하여 차감
      );

      // 포인트 업데이트 (천 단위 콤마 추가)
      setState(() {
        currentPoint = newPointValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
        _isExchanging = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('교환이 완료되었습니다.'),
            backgroundColor: Color(0xff00AA5D),
          ),
        );

        // 교환 완료 후 이전 화면으로 돌아가면서 결과 전달
        Navigator.pop(context, true);
      }

      print('✅ 교환 완료: $localCachePrice원권, 차감 포인트: $pointValue');
    } catch (e) {
      setState(() {
        _isExchanging = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('교환에 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      print('❌ 교환 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TitleAppbar(title: '교환소', leadingType: LeadingType.close),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                        currentPoint,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
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
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exchangeItems.length,
                  separatorBuilder: (context, index) {
                    return const Divider(height: 1, color: Color(0xffCCCCCC));
                  },
                  itemBuilder: (context, index) {
                    final item = exchangeItems[index];
                    return ExchangeListItem(
                      localCachePrice: item['localCachePrice']!,
                      pointPrice: item['pointPrice']!,
                      onTap: _isExchanging
                          ? null
                          : () => _handleExchange(
                              item['pointValue']!,
                              item['localCachePrice']!,
                            ),
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
                      _buildBulletText(
                        '지역 화폐는 본인이 거주하는 지자체에서 발행하는 화폐로만 교환 가능합니다.',
                      ),
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
          // 로딩 인디케이터
          if (_isExchanging)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xff00AA5D)),
              ),
            ),
        ],
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
