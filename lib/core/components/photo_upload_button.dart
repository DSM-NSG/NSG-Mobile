import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';

class PhotoUploadButton extends StatelessWidget {
  final VoidCallback? onTap;

  const PhotoUploadButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: NsgColor.black50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add, color: NsgColor.black400, size: 24),
      ),
    );
  }
}
