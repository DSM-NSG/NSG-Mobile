import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/core/components/popular_post_card.dart';
import 'package:nsg_mobile/core/components/recent_post_card.dart';
import 'package:nsg_mobile/core/components/section_header.dart';
import 'package:nsg_mobile/features/major/presentation/providers/major_provider.dart';
import 'package:nsg_mobile/features/major/presentation/widgets/autocomplete_list.dart';
import 'package:nsg_mobile/features/major/presentation/widgets/major_search_bar.dart';
import 'package:nsg_mobile/features/major/presentation/widgets/trending_topics_card.dart';

const _spacing10 = SizedBox(height: 10);
const _spacing20 = SizedBox(height: 20);

class MajorScreen extends ConsumerWidget {
  const MajorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(majorProvider);

    return Scaffold(
      backgroundColor: NsgColor.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _spacing20,
              const MajorSearchBar(),
              _spacing10,
              Expanded(
                child: Stack(
                  children: [
                    // 메인 콘텐츠 (항상 렌더링, 자동완성에 밀리지 않음)
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.showSearchResults)
                            _SearchResultContent(query: state.submittedQuery!)
                          else
                            const _DefaultContent(),
                        ],
                      ),
                    ),
                    // 자동완성 오버레이 (고정 높이, 메인 콘텐츠 위에 덮음)
                    if (state.showAutocomplete)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 152,
                        child: AutocompleteList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultContent extends ConsumerWidget {
  const _DefaultContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentPosts = ref.watch(majorRecentPostsProvider(null));
    final preview = recentPosts.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('전공 마당', style: NsgTextStyle.header1),
          _spacing10,
          Text('현재 트렌드 토픽', style: NsgTextStyle.header3),
          _spacing10,
          const TrendingTopicsCard(),
          _spacing20,
          SectionHeader(
            title: '최신글',
            trailing: GestureDetector(
              onTap: () => context.push('/major/recent'),
              child: Text(
                '더보기',
                style: NsgTextStyle.body3.copyWith(color: NsgColor.black400),
              ),
            ),
          ),
          _spacing10,
          ...preview.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RecentPostCard(post: post),
            ),
          ),
          _spacing20,
        ],
      );
  }
}

class _SearchResultContent extends ConsumerWidget {
  final String query;

  const _SearchResultContent({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularPosts = ref.watch(majorPopularPostsProvider(query));
    final recentPosts = ref.watch(majorRecentPostsProvider(query));
    final popularPreview = popularPosts.take(5).toList();
    final recentPreview = recentPosts.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (popularPreview.isNotEmpty) ...[
            SectionHeader(
              title: '인기글',
              trailing: GestureDetector(
                onTap: () => context.push('/major/popular'),
                child: Text(
                  '더보기',
                  style: NsgTextStyle.body3.copyWith(color: NsgColor.black400),
                ),
              ),
            ),
            _spacing10,
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: popularPreview.length,
                separatorBuilder: (_, __) => _spacing10,
                itemBuilder: (_, i) => PopularPostCard(post: popularPreview[i]),
              ),
            ),
            _spacing20,
          ],
          SectionHeader(
            title: '최신글',
            trailing: GestureDetector(
              onTap: () => context.push('/major/recent'),
              child: Text(
                '더보기',
                style: NsgTextStyle.body3.copyWith(color: NsgColor.black400),
              ),
            ),
          ),
          _spacing10,
          if (recentPreview.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  '검색 결과가 없습니다.',
                  style: NsgTextStyle.body3.copyWith(color: NsgColor.black400),
                ),
              ),
            )
          else
            ...recentPreview.map(
              (post) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecentPostCard(post: post),
              ),
            ),
          _spacing20,
        ],
      );
  }
}
