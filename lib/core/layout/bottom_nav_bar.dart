import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/core/layout/nav_item_data.dart';

class NsgBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NsgBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: NsgColor.background),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(bottomNavItems.length, (index) {
              final item = bottomNavItems[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isSelected ? item.activeIcon : item.icon,
                      Text(
                        item.label,
                        style: NsgTextStyle.body3.copyWith(
                          color: isSelected
                              ? NsgColor.orange400
                              : NsgColor.black400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
