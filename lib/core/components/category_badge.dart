import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';

class CategoryBadge extends StatelessWidget {
  final String label;

  const CategoryBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: NsgColor.orange400,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: NsgTextStyle.body4.copyWith(color: Colors.white),
      ),
    );
  }
}
