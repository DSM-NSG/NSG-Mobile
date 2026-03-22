import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/features/write/domain/entities/write_category.dart';

class WriteMenuCard extends StatelessWidget {
  final WriteCategory category;
  final VoidCallback? onTap;

  const WriteMenuCard({
    super.key,
    required this.category,
    this.onTap,
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
                child: Builder(
                  builder: (context) {
                    final lines = category.label.split('\n');
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              category.icon,
                              size: 20,
                              color: NsgColor.black800,
                            ),
                            const SizedBox(width: 8),
                            Text(lines[0], style: NsgTextStyle.header2),
                          ],
                        ),
                        if (lines.length > 1) ...[
                          const SizedBox(height: 2),
                          Text(lines[1], style: NsgTextStyle.header2),
                        ],
                      ],
                    );
                  },
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
                child: category.imagePath != null
                    ? Image.asset(category.imagePath!, fit: BoxFit.cover)
                    : Container(color: NsgColor.black100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
