import 'package:flutter/material.dart';
import 'package:miyo/screens/settings/profile_settings_screen.dart';

class TitleAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final LeadingType? leadingType;
  final VoidCallback? onLeadingPressed;
  final ActionType? actionType;
  final VoidCallback? onActionPressed;
  final List<Widget>? actions;

  const TitleAppbar({
    super.key,
    required this.title,
    this.leadingType = LeadingType.none,
    this.onLeadingPressed,
    this.actionType = ActionType.none,
    this.onActionPressed,
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
      actions: _buildActions(context),
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

  List<Widget>? _buildActions(BuildContext context) {
    // 커스텀 actions가 제공된 경우 우선 사용
    if (actions != null) return actions;

    // actionType이 없거나 none인 경우 null 반환
    if (actionType == null || actionType == ActionType.none) return null;

    switch (actionType!) {
      case ActionType.none:
        return null;

      case ActionType.settings:
        return [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed:
                onActionPressed ??
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSettingScreen(),
                  ),
                ),
          ),
        ];
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

enum ActionType {
  none, // 기본
  settings, // 설정
}
