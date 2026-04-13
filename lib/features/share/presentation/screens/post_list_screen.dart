import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/core/components/category_filter.dart';
import 'package:nsg_mobile/features/share/data/dummy/share_dummy_data.dart';
import 'package:nsg_mobile/features/share/domain/entities/post.dart';
import 'package:nsg_mobile/core/components/page_header.dart';
import 'package:nsg_mobile/core/components/recent_post_card.dart';

enum PostListType { popular, recent }

class PostListScreen extends StatefulWidget {
  final PostListType type;

  const PostListScreen({super.key, required this.type});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  static const spacing = SizedBox(height: 10);

  String? _selectedCategory;

  List<Post> get _source =>
      widget.type == PostListType.popular ? dummyPopularPosts : dummyRecentPosts;

  List<Post> get _filteredPosts => _selectedCategory == null
      ? _source
      : _source.where((p) => p.category == _selectedCategory).toList();

  String get _title => widget.type == PostListType.popular ? '인기글' : '최신글';

  @override
  Widget build(BuildContext context) {
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
              child: _filteredPosts.isEmpty
                  ? Center(
                      child: Text(
                        '게시글이 없습니다.',
                        style: const TextStyle(color: NsgColor.black300),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredPosts.length,
                      separatorBuilder: (_, __) => spacing,
                      itemBuilder: (_, i) => RecentPostCard(
                        post: _filteredPosts[i],
                        onTap: () => context.push(
                          '/share/post/${_filteredPosts[i].id}',
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
