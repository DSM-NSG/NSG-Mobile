import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/features/write/domain/entities/write_category.dart';

class WriteMenuCard extends StatelessWidget {
  final WriteCategory category;
  final VoidCallback? onTap;
  final String? imagePath;

  const WriteMenuCard({
    super.key,
    required this.category,
    this.onTap,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: NsgColor.black50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            category.icon,
                            size: 20,
                            color: NsgColor.black800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            category.label,
                            style: NsgTextStyle.body2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: SizedBox(
                width: 180,
                height: double.infinity,
                child: imagePath != null
                    ? Image.asset(imagePath!, fit: BoxFit.cover)
                    : Container(color: NsgColor.black100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
