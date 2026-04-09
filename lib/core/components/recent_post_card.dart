import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/core/components/category_badge.dart';
import 'package:nsg_mobile/features/share/domain/entities/post.dart';

class RecentPostCard extends StatelessWidget {
  final Post post;
  final int titleMaxLines;
  final int contentMaxLines;
  static const spacing = SizedBox(height: 10);

  const RecentPostCard({
    super.key,
    required this.post,
    this.titleMaxLines = 1,
    this.contentMaxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: NsgColor.black50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NsgColor.black50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: NsgTextStyle.header3.copyWith(color: NsgColor.black800),
            maxLines: titleMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
          spacing,
          Text(
            post.content,
            style: NsgTextStyle.body3.copyWith(color: NsgColor.black400),
            maxLines: contentMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
          spacing,
          Row(
            children: [
              CategoryBadge(label: post.category),
              const Spacer(),
              const Icon(
                Symbols.favorite,
                size: 12,
                color: NsgColor.orange400,
                fill: 1,
              ),
              const SizedBox(width: 2),
              Text(
                '${post.likes}+',
                style: NsgTextStyle.body4.copyWith(color: NsgColor.orange400),
              ),
              const SizedBox(width: 6),
              const Icon(
                Symbols.chat_bubble,
                size: 12,
                color: NsgColor.orange400,
                fill: 1,
              ),
              const SizedBox(width: 2),
              Text(
                '${post.comments}+',
                style: NsgTextStyle.body4.copyWith(color: NsgColor.orange400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
