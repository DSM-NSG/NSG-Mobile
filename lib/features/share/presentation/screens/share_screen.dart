import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/features/share/data/dummy/share_dummy_data.dart';
import 'package:nsg_mobile/features/share/domain/entities/post.dart';
import 'package:nsg_mobile/core/components/popular_post_card.dart';
import 'package:nsg_mobile/core/components/recent_post_card.dart';
import 'package:nsg_mobile/core/components/section_header.dart';
import 'package:nsg_mobile/core/components/profile_header.dart';
import 'package:nsg_mobile/core/components/category_filter.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  static const spacing10 = SizedBox(height: 10);
  static const spacing20 = SizedBox(height: 20);

  String? _selectedCategory;

  List<Post> get _filteredPopular => (_selectedCategory == null
          ? dummyPopularPosts
          : dummyPopularPosts.where((p) => p.category == _selectedCategory))
      .take(5)
      .toList();

  List<Post> get _filteredRecent => (_selectedCategory == null
          ? dummyRecentPosts
          : dummyRecentPosts.where((p) => p.category == _selectedCategory))
      .take(5)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NsgColor.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProfileHeader(name: '정지윤', generation: '10기'),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    spacing20,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeader(
                        title: '꿀팁 공유',
                        titleStyle: NsgTextStyle.header1,
                        trailing: const Icon(
                          Symbols.search,
                          color: NsgColor.orange400,
                        ),
                      ),
                    ),
                    spacing20,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CategoryFilter(
                        categories: shareCategories,
                        selectedCategory: _selectedCategory,
                        onSelected: (cat) =>
                            setState(() => _selectedCategory = cat),
                        customColors: const {
                          '기타': (
                            active: NsgColor.orange400,
                            inactive: NsgColor.orange300,
                          ),
                        },
                      ),
                    ),
                    spacing20,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeader(
                        title: '인기글',
                        trailing: GestureDetector(
                          onTap: () => context.go('/share/popular'),
                          child: Text(
                            '더보기',
                            style: NsgTextStyle.body3.copyWith(
                              color: NsgColor.black500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    spacing10,
                    SizedBox(
                      height: 190,
                      child: _filteredPopular.isEmpty
                          ? Center(
                              child: Text(
                                '게시글이 없습니다.',
                                style: NsgTextStyle.body3.copyWith(
                                  color: NsgColor.orange400,
                                ),
                              ),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: _filteredPopular.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 20),
                              itemBuilder: (_, i) =>
                                  PopularPostCard(post: _filteredPopular[i]),
                            ),
                    ),
                    spacing20,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeader(
                        title: '최신글',
                        trailing: GestureDetector(
                          onTap: () => context.go('/share/recent'),
                          child: Text(
                            '더보기',
                            style: NsgTextStyle.body3.copyWith(
                              color: NsgColor.black500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    spacing10,
                    if (_filteredRecent.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: Text(
                            '게시글이 없습니다.',
                            style: NsgTextStyle.body3.copyWith(
                              color: NsgColor.orange400,
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: _filteredRecent
                              .map(
                                (p) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: RecentPostCard(post: p),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    spacing20,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
