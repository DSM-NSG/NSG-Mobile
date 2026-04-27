import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/core/components/category_filter.dart';
import 'package:nsg_mobile/features/share/data/dummy/share_dummy_data.dart';
import 'package:nsg_mobile/features/share/domain/entities/post.dart';
import 'package:nsg_mobile/core/components/page_header.dart';
import 'package:nsg_mobile/core/components/recent_post_card.dart';
import 'package:nsg_mobile/features/share/presentation/providers/share_provider.dart';

enum PostListType { popular, recent }

class PostListScreen extends ConsumerStatefulWidget {
  final PostListType type;

  const PostListScreen({super.key, required this.type});

  @override
  ConsumerState<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends ConsumerState<PostListScreen> {
  static const spacing = SizedBox(height: 10);

  String? _selectedCategory;

  List<Post> _getSource(WidgetRef ref) {
    final params = (query: null as String?, category: _selectedCategory);
    if (widget.type == PostListType.popular) {
      return ref.watch(shareFilteredPopularProvider(params));
    } else {
      return ref.watch(shareFilteredRecentProvider(params));
    }
  }

  String get _title => widget.type == PostListType.popular ? '인기글' : '최신글';

  @override
  Widget build(BuildContext context) {
    final posts = _getSource(ref);

    return Scaffold(
      backgroundColor: NsgColor.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: PageHeader(title: _title),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CategoryFilter(
                categories: shareCategories,
                selectedCategory: _selectedCategory,
                onSelected: (cat) => setState(() => _selectedCategory = cat),
                customColors: const {
                  '기타': (
                    active: NsgColor.orange400,
                    inactive: NsgColor.orange300,
                  ),
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: posts.isEmpty
                  ? const Center(
                      child: Text(
                        '게시글이 없습니다.',
                        style: TextStyle(color: NsgColor.black300),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: posts.length,
                      separatorBuilder: (_, __) => spacing,
                      itemBuilder: (_, i) => RecentPostCard(
                        post: posts[i],
                        onTap: () => context.push(
                          '/share/post/${posts[i].id}',
                        ),
                      ),
                    ),
            ),
            spacing,
          ],
        ),
      ),
    );
  }
}
