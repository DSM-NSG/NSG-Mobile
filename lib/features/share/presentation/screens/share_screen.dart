import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/features/mypage/presentation/providers/mypage_provider.dart';
import 'package:nsg_mobile/features/share/data/dummy/share_dummy_data.dart';
import 'package:nsg_mobile/features/share/presentation/providers/share_provider.dart';
import 'package:nsg_mobile/core/components/nsg_autocomplete_list.dart';
import 'package:nsg_mobile/core/components/nsg_search_bar.dart';
import 'package:nsg_mobile/core/components/popular_post_card.dart';
import 'package:nsg_mobile/core/components/recent_post_card.dart';
import 'package:nsg_mobile/core/components/section_header.dart';
import 'package:nsg_mobile/core/components/profile_header.dart';
import 'package:nsg_mobile/core/components/category_filter.dart';

const _spacing10 = SizedBox(height: 10);
const _spacing16 = SizedBox(height: 16);
const _spacing20 = SizedBox(height: 20);

class ShareScreen extends ConsumerWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shareProvider);

    return Scaffold(
      backgroundColor: NsgColor.background,
      body: SafeArea(
        child: state.isSearchOpen
            ? const _SearchLayout()
            : const _DefaultLayout(),
      ),
    );
  }
}

class _DefaultLayout extends ConsumerWidget {
  const _DefaultLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shareProvider);
    final userAsync = ref.watch(mypageProvider);
    final popularPosts = ref
        .watch(
          shareFilteredPopularProvider((
            query: null,
            category: state.selectedCategory,
          )),
        )
        .take(5)
        .toList();
    final recentPosts = ref
        .watch(
          shareFilteredRecentProvider((
            query: null,
            category: state.selectedCategory,
          )),
        )
        .take(5)
        .toList();

    log(
      '공유 화면 로드: 인기글 ${popularPosts.length}개, 최신글 ${recentPosts.length}개',
      name: 'Share',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: userAsync.when(
            data: (user) => ProfileHeader(
              generation: user.displayName,
              detail: user.cohortLabel,
            ),
            loading: () => const ProfileHeader(generation: '-', detail: '-'),
            error: (e, _) {
              log('공유 화면 사용자 정보 로드 실패: $e', name: 'Share');
              return const ProfileHeader(generation: '-', detail: '-');
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _spacing20,
                  SectionHeader(
                    title: '꿀팁 공유',
                    titleStyle: NsgTextStyle.header1,
                    trailing: GestureDetector(
                      onTap: () =>
                          ref.read(shareProvider.notifier).openSearch(),
                      child: const Icon(
                        Symbols.search,
                        color: NsgColor.orange400,
                      ),
                    ),
                  ),
                  _spacing20,
                  CategoryFilter(
                    categories: shareCategories,
                    selectedCategory: state.selectedCategory,
                    onSelected: (cat) =>
                        ref.read(shareProvider.notifier).selectCategory(cat),
                    customColors: const {
                      '기타': (
                        active: NsgColor.orange400,
                        inactive: NsgColor.orange300,
                      ),
                    },
                  ),
                  _spacing20,
                  SectionHeader(
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
                  _spacing10,
                  SizedBox(
                    height: 190,
                    child: popularPosts.isEmpty
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
                            itemCount: popularPosts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 20),
                            itemBuilder: (_, i) => PopularPostCard(
                              post: popularPosts[i],
                              onTap: () => context.push(
                                '/share/post/${popularPosts[i].id}',
                              ),
                            ),
                          ),
                  ),
                  _spacing20,
                  SectionHeader(
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
                  _spacing10,
                  if (recentPosts.isEmpty)
                    Center(
                      child: Text(
                        '게시글이 없습니다.',
                        style: NsgTextStyle.body3.copyWith(
                          color: NsgColor.orange400,
                        ),
                      ),
                    )
                  else
                    ...recentPosts.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RecentPostCard(
                          post: p,
                          onTap: () => context.push('/share/post/${p.id}'),
                        ),
                      ),
                    ),
                  _spacing20,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchLayout extends ConsumerWidget {
  const _SearchLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shareProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => ref.read(shareProvider.notifier).closeSearch(),
                  behavior: HitTestBehavior.opaque,
                  child: const Icon(
                    Symbols.chevron_left,
                    color: NsgColor.black800,
                  ),
                ),
              ),
              Text('검색', style: NsgTextStyle.body2),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: NsgSearchBar(
            searchText: state.searchText,
            hintText: '키워드 혹은 찾고싶은 검색어로 입력해주세요.',
            autoFocus: true,
            onChanged: ref.read(shareProvider.notifier).onSearchTextChanged,
            onSubmitted: ref.read(shareProvider.notifier).submitSearch,
            onClear: ref.read(shareProvider.notifier).clearSearch,
            onFocusChanged: ref
                .read(shareProvider.notifier)
                .onSearchFocusChanged,
          ),
        ),
        _spacing16,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CategoryFilter(
            categories: shareCategories,
            selectedCategory: state.selectedCategory,
            onSelected: (cat) =>
                ref.read(shareProvider.notifier).selectCategory(cat),
            customColors: const {
              '기타': (active: NsgColor.orange400, inactive: NsgColor.orange300),
            },
          ),
        ),
        _spacing10,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(child: _SearchContent()),
                ),
                if (state.showAutocomplete)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 152,
                    child: NsgAutocompleteList(
                      suggestions: ref.watch(
                        shareAutocompleteProvider(state.searchText),
                      ),
                      query: state.searchText,
                      onSelect: (s) {
                        ref.read(shareProvider.notifier).submitSearch(s);
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shareProvider);

    if (!state.showSearchResults) return const SizedBox.shrink();

    final posts = ref.watch(
      shareSearchResultsProvider((
        query: state.submittedQuery,
        category: state.selectedCategory,
      )),
    );

    log(
      '공유 검색 결과: "${state.submittedQuery}" → ${posts.length}개',
      name: 'Share',
    );

    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            '검색 결과가 없습니다.',
            style: NsgTextStyle.body3.copyWith(color: NsgColor.black400),
          ),
        ),
      );
    }

    return Column(
      children: [
        ...posts.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RecentPostCard(
              post: p,
              onTap: () => context.push('/share/post/${p.id}'),
            ),
          ),
        ),
        _spacing20,
      ],
    );
  }
}
