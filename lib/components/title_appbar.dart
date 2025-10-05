import 'package:flutter/material.dart';

class TitleAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final LeadingType? leadingType;
  final VoidCallback? onLeadingPressed;
  final List<Widget>? actions;

  const TitleAppbar({
    super.key,
    required this.title,
    this.leadingType = LeadingType.none,
    this.onLeadingPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: _buildLeading(context),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      actions: actions,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leadingType == null) return null;

    switch (leadingType!) {
      case LeadingType.none:
        return null;

      case LeadingType.back:
        return IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: onLeadingPressed ?? () => Navigator.pop(context),
        );

      case LeadingType.close:
        return IconButton(
          icon: const Icon(Icons.close),
          onPressed: onLeadingPressed ?? () => Navigator.pop(context),
        );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

enum LeadingType {
  none, // 기본
  back, // 뒤로 가기
  close, // 닫기
}
