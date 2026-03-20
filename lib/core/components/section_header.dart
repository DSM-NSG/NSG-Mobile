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
        Expanded(
          child: Text(
            title,
            style: titleStyle ?? NsgTextStyle.header2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[const SizedBox(height: 10), trailing!],
      ],
    );
  }
}
