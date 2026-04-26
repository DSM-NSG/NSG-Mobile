import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';

class ProfileHeader extends StatelessWidget {
  final String generation;
  final String detail;

  const ProfileHeader({
    super.key,
    required this.generation,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const CircleAvatar(radius: 24, backgroundColor: NsgColor.orange400),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(generation, style: NsgTextStyle.header3),
            const SizedBox(height: 4),
            Text(detail, style: NsgTextStyle.body3.copyWith(color: NsgColor.black400)),
          ],
        ),
      ],
    );
  }
}
