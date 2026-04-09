import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsg_mobile/features/share/data/dummy/share_dummy_data.dart';
import 'package:nsg_mobile/features/share/domain/entities/post.dart';

@immutable
class ShareState {
  final String searchText;
  final String? submittedQuery;
  final bool isSearchFocused;
  final bool isSearchOpen;
  final String? selectedCategory;

  const ShareState({
    this.searchText = '',
    this.submittedQuery,
    this.isSearchFocused = false,
    this.isSearchOpen = false,
    this.selectedCategory,
  });

  bool get showAutocomplete =>
      isSearchFocused && searchText.trim().isNotEmpty;
  bool get showSearchResults =>
      submittedQuery != null && submittedQuery!.isNotEmpty;

  ShareState copyWith({
    String? searchText,
    Object? submittedQuery = _sentinel,
    bool? isSearchFocused,
    bool? isSearchOpen,
    Object? selectedCategory = _sentinel,
  }) {
    return ShareState(
      searchText: searchText ?? this.searchText,
      submittedQuery: submittedQuery == _sentinel
          ? this.submittedQuery
          : submittedQuery as String?,
      isSearchFocused: isSearchFocused ?? this.isSearchFocused,
      isSearchOpen: isSearchOpen ?? this.isSearchOpen,
      selectedCategory: selectedCategory == _sentinel
          ? this.selectedCategory
          : selectedCategory as String?,
    );
  }
}

const _sentinel = Object();

class ShareNotifier extends Notifier<ShareState> {
  @override
  ShareState build() => const ShareState();

  void openSearch() => state = state.copyWith(isSearchOpen: true);

  void closeSearch() => state = const ShareState();

  void onSearchTextChanged(String text) =>
      state = state.copyWith(searchText: text);

  void onSearchFocusChanged(bool focused) =>
      state = state.copyWith(isSearchFocused: focused);

  void submitSearch(String query) {
    if (query.trim().isEmpty) return;
    state = state.copyWith(
      submittedQuery: query.trim(),
      searchText: query.trim(),
      isSearchFocused: false,
    );
  }

  void clearSearch() {
    state = state.copyWith(
      searchText: '',
      submittedQuery: null,
      isSearchFocused: false,
    );
  }

  void selectCategory(String? category) =>
      state = state.copyWith(selectedCategory: category);
}

final shareProvider =
    NotifierProvider<ShareNotifier, ShareState>(ShareNotifier.new);

final shareAutocompleteProvider =
    Provider.family<List<String>, String>((ref, query) {
  if (query.trim().isEmpty) return [];
  final q = query.toLowerCase();
  final all = shareSearchSuggestions;
  final startsWith =
      all.where((s) => s.toLowerCase().startsWith(q)).toList();
  final contains = all
      .where((s) =>
          !s.toLowerCase().startsWith(q) && s.toLowerCase().contains(q))
      .toList();
  return [...startsWith, ...contains];
});

List<Post> _filterPosts(
    List<Post> posts, String? query, String? category) {
  var result = posts;
  if (query != null && query.isNotEmpty) {
    final q = query.toLowerCase();
    result = result
        .where((p) =>
            p.title.toLowerCase().contains(q) ||
            p.content.toLowerCase().contains(q))
        .toList();
  }
  if (category != null) {
    result = result.where((p) => p.category == category).toList();
  }
  return result;
}

final shareFilteredPopularProvider = Provider.family<List<Post>,
    ({String? query, String? category})>((ref, params) {
  return _filterPosts(dummyPopularPosts, params.query, params.category);
});

final shareFilteredRecentProvider = Provider.family<List<Post>,
    ({String? query, String? category})>((ref, params) {
  return _filterPosts(dummyRecentPosts, params.query, params.category);
});

final shareSearchResultsProvider = Provider.family<List<Post>,
    ({String? query, String? category})>((ref, params) {
  final seen = <String>{};
  final all = [...dummyPopularPosts, ...dummyRecentPosts]
      .where((p) => seen.add(p.id))
      .toList();
  return _filterPosts(all, params.query, params.category);
});
