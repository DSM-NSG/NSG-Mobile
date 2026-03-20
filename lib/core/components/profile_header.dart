import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String generation;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.generation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const CircleAvatar(radius: 24, backgroundColor: NsgColor.orange400),
        const SizedBox(width: 20),
        Text(name, style: NsgTextStyle.body2),
        const SizedBox(width: 10),
        Text(generation, style: NsgTextStyle.body2),
      ],
    );
  }
}
