import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';

typedef CategoryColorPair = ({Color active, Color inactive});

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onSelected;
  final Map<String, CategoryColorPair>? customColors;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
    this.customColors,
  });

  static const Map<String, CategoryColorPair> _defaultColors = {
    '카페': (active: NsgColor.cafe, inactive: NsgColor.cafeNon),
    'PC방': (active: NsgColor.pc, inactive: NsgColor.pcNon),
    '노래방': (active: NsgColor.sing, inactive: NsgColor.singNon),
    '맛집': (active: NsgColor.eat, inactive: NsgColor.eatNon),
    '기타': (active: NsgColor.etc, inactive: NsgColor.etcNon),
  };

  static const CategoryColorPair _fallback = (
    active: NsgColor.orange400,
    inactive: NsgColor.orange300,
  );

  CategoryColorPair _resolveColor(String category) {
    return customColors?[category] ?? _defaultColors[category] ?? _fallback;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          final colors = _resolveColor(category);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onSelected(isSelected ? null : category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colors.active : colors.inactive,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: NsgTextStyle.body3.copyWith(color: Colors.white),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
