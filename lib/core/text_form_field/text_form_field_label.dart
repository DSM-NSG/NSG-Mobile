import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';

class CustomTextFormFieldLabel extends StatelessWidget {
  final Widget? label;
  final String? labelText;
  final TextStyle? labelStyle;

  const CustomTextFormFieldLabel({
    super.key,
    this.label,
    this.labelText,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = NsgTextStyle.body3.copyWith(color: NsgColor.black800);
    return DefaultTextStyle(
      style: defaultTextStyle.merge(labelStyle),
      child: Row(children: [label ?? Text(labelText!)]),
    );
  }
}
