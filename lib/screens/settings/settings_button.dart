import 'package:flutter/material.dart';

class SettingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool showTrailingIcon;
  final Color? textColor;
  final bool showBorder;

  const SettingButton({
    super.key,
    required this.label,
    this.onTap,
    this.showTrailingIcon = true,
    this.textColor,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: showBorder
            ? Border.all(color: Color(0xffDBE0E5), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.black,
                    ),
                  ),
                ),
                if (showTrailingIcon)
                  Icon(Icons.chevron_right, color: Color(0xff757575), size: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
