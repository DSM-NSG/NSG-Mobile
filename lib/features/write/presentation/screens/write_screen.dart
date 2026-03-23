import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/features/write/data/dummy/write_dummy_data.dart';
import 'package:nsg_mobile/features/write/presentation/widgets/write_menu_card.dart';

class WriteScreen extends StatelessWidget {
  static const spacing = SizedBox(height: 20);

  const WriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NsgColor.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              spacing,
              Text('꿀팁 작성', style: NsgTextStyle.header1),
              spacing,
              Expanded(
                child: ListView.separated(
                  itemCount: writeCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final category = writeCategories[index];
                    return WriteMenuCard(
                      category: category,
                      onTap: () => context.push(category.route),
                    );
                  },
                ),
              ),
              spacing,
            ],
          ),
        ),
      ),
    );
  }
}
