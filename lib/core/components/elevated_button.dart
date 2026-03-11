import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';

class NsgElevatedButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool enabled;
  final double height;
  final double width;
  final String text;

  const NsgElevatedButton({
    super.key,
    this.onTap,
    this.enabled = true,
    this.height = 52,
    this.width = double.infinity,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: enabled ? NsgColor.orange400 : NsgColor.black100,
        ),
        child: Center(child: Text(text, style: NsgTextStyle.header1)),
      ),
    );
  }
}
