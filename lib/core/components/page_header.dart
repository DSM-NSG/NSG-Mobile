import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';

class PageHeader extends StatelessWidget {
  final String? title;

  const PageHeader({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => context.pop(),
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Symbols.chevron_left,
              color: NsgColor.black800,
            ),
          ),
        ),
        if (title != null)
          Text(title!, style: NsgTextStyle.body2),
      ],
    );
  }
}
