import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/core/components/page_header.dart';
import 'package:nsg_mobile/core/components/recent_post_card.dart';
import 'package:nsg_mobile/features/major/presentation/providers/major_provider.dart';
import 'package:nsg_mobile/features/share/domain/entities/post.dart';

enum MajorPostListType { popular, recent }

class MajorPostListScreen extends ConsumerWidget {
  final MajorPostListType type;

  static const spacing = SizedBox(height: 10);

  const MajorPostListScreen({super.key, required this.type});

  String get _title =>
      type == MajorPostListType.popular ? '인기글' : '최신글';

  List<Post> _sort(List<Post> posts) {
    if (type == MajorPostListType.popular) {
      return [...posts]..sort((a, b) => b.likes.compareTo(a.likes));
    }
    return posts;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(majorProvider).submittedQuery;
    final posts = type == MajorPostListType.popular
        ? ref.watch(majorPopularPostsProvider(query))
        : ref.watch(majorRecentPostsProvider(query));
    final sorted = _sort(posts);

    return Scaffold(
      backgroundColor: NsgColor.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              PageHeader(title: _title),
              spacing,
              Expanded(
                child: sorted.isEmpty
                    ? Center(
                        child: Text(
                          '게시글이 없습니다.',
                          style: NsgTextStyle.body3.copyWith(
                            color: NsgColor.black400,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: sorted.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => RecentPostCard(
                          post: sorted[i],
                          onTap: () => context.push('/share/post/${sorted[i].id}'),
                        ),
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
