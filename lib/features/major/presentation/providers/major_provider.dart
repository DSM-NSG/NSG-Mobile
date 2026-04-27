import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsg_mobile/features/major/data/dummy/major_dummy_data.dart';
import 'package:nsg_mobile/features/share/domain/entities/post.dart';
import 'package:nsg_mobile/features/share/presentation/providers/share_provider.dart';

@immutable
class MajorState {
  final String searchText;
  final String? submittedQuery;
  final bool isSearchFocused;

  const MajorState({
    this.searchText = '',
    this.submittedQuery,
    this.isSearchFocused = false,
  });

  bool get showAutocomplete => isSearchFocused && searchText.trim().isNotEmpty;

  bool get showSearchResults =>
      submittedQuery != null && submittedQuery!.isNotEmpty;

  MajorState copyWith({
    String? searchText,
    String? submittedQuery,
    bool? isSearchFocused,
    bool clearSubmittedQuery = false,
  }) {
    return MajorState(
      searchText: searchText ?? this.searchText,
      submittedQuery: clearSubmittedQuery
          ? null
          : submittedQuery ?? this.submittedQuery,
      isSearchFocused: isSearchFocused ?? this.isSearchFocused,
    );
  }
}

class MajorNotifier extends Notifier<MajorState> {
  @override
  MajorState build() => const MajorState();

  void onSearchTextChanged(String text) {
    state = state.copyWith(
      searchText: text,
      clearSubmittedQuery: text.trim().isEmpty,
    );
  }

  void onSearchFocusChanged(bool focused) {
    state = state.copyWith(isSearchFocused: focused);
  }

  void submitSearch(String query) {
    final normalized = query.trim();
    if (normalized.isEmpty) return;
    state = state.copyWith(
      searchText: normalized,
      submittedQuery: normalized,
      isSearchFocused: false,
    );
  }

  void clearSearch() {
    state = const MajorState();
  }
}

final majorProvider = NotifierProvider<MajorNotifier, MajorState>(
  MajorNotifier.new,
);

final autocompleteResultsProvider = Provider.family<List<String>, String>((
  ref,
  query,
) {
  final normalized = query.trim();
  if (normalized.isEmpty) return [];
  final q = normalized.toLowerCase();
  final starts = majorSearchSuggestions
      .where((s) => s.toLowerCase().startsWith(q))
      .toList();
  final contains = majorSearchSuggestions
      .where(
        (s) => !s.toLowerCase().startsWith(q) && s.toLowerCase().contains(q),
      )
      .toList();
  return [...starts, ...contains];
});

List<Post> _filterMajorPosts(List<Post> posts, String? query) {
  if (query == null || query.isEmpty) return posts;
  final q = query.toLowerCase();
  return posts
      .where(
        (p) =>
            p.title.toLowerCase().contains(q) ||
            p.content.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q),
      )
      .toList();
}

final majorPopularPostsProvider = Provider.family<List<Post>, String?>((
  ref,
  query,
) {
  final newPosts = ref.watch(shareNewPostsProvider);
  final deleted = ref.watch(shareDeletedIdsProvider);
  final majorPosts = newPosts
      .where((p) => p.board == PostBoard.major && !deleted.contains(p.id))
      .toList();
  return _filterMajorPosts(majorPosts, query);
});

final majorRecentPostsProvider = Provider.family<List<Post>, String?>((
  ref,
  query,
) {
  final newPosts = ref.watch(shareNewPostsProvider);
  final deleted = ref.watch(shareDeletedIdsProvider);
  final majorPosts = newPosts
      .where((p) => p.board == PostBoard.major && !deleted.contains(p.id))
      .toList();
  return _filterMajorPosts(majorPosts, query);
});
