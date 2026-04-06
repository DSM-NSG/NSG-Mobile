import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/core/components/page_header.dart';
import 'package:nsg_mobile/core/components/recent_post_card.dart';
import 'package:nsg_mobile/features/major/presentation/providers/major_provider.dart';

enum MajorPostListType { popular, recent }

class MajorPostListScreen extends ConsumerWidget {
  final MajorPostListType type;
  static const spacing = SizedBox(height: 10);

  const MajorPostListScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(majorProvider);
    final query = state.submittedQuery;

    final posts = type == MajorPostListType.popular
        ? ref.watch(majorPopularPostsProvider(query))
        : ref.watch(majorRecentPostsProvider(query));

    final title = type == MajorPostListType.popular ? '인기글' : '최신글';

    return Scaffold(
      backgroundColor: NsgColor.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              PageHeader(title: title),
              spacing,
              Expanded(
                child: posts.isEmpty
                    ? Center(
                        child: Text(
                          '게시글이 없습니다.',
                          style: NsgTextStyle.body3.copyWith(
                            color: NsgColor.black400,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: posts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => RecentPostCard(post: posts[i]),
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
