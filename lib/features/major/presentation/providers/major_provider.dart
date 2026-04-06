import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsg_mobile/features/major/data/dummy/major_dummy_data.dart';
import 'package:nsg_mobile/features/share/domain/entities/post.dart';

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

  bool get showAutocomplete => isSearchFocused && searchText.isNotEmpty;

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
    state = state.copyWith(searchText: text, clearSubmittedQuery: text.isEmpty);
  }

  void onSearchFocusChanged(bool focused) {
    state = state.copyWith(isSearchFocused: focused);
  }

  void submitSearch(String query) {
    if (query.trim().isEmpty) return;
    state = state.copyWith(
      searchText: query,
      submittedQuery: query,
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
  if (query.isEmpty) return [];
  final q = query.toLowerCase();
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

final majorPopularPostsProvider = Provider.family<List<Post>, String?>((
  ref,
  query,
) {
  if (query == null || query.isEmpty) return dummyMajorPopularPosts;
  final q = query.toLowerCase();
  return dummyMajorPopularPosts
      .where(
        (p) =>
            p.title.toLowerCase().contains(q) ||
            p.content.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q),
      )
      .toList();
});

final majorRecentPostsProvider = Provider.family<List<Post>, String?>((
  ref,
  query,
) {
  if (query == null || query.isEmpty) return dummyMajorRecentPosts;
  final q = query.toLowerCase();
  return dummyMajorRecentPosts
      .where(
        (p) =>
            p.title.toLowerCase().contains(q) ||
            p.content.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q),
      )
      .toList();
});
