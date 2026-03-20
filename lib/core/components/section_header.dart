import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/text_style.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.titleStyle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: titleStyle ?? NsgTextStyle.header2),
        if (trailing != null) trailing!,
      ],
    );
  }
}
