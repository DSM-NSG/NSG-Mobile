import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsg_mobile/features/map/data/dummy/map_dummy_data.dart';
import 'package:nsg_mobile/features/share/domain/entities/post.dart';
import 'package:nsg_mobile/features/share/presentation/providers/share_provider.dart';

@immutable
class PlaceGroup {
  final String locationName;
  final String locationAddress;
  final double latitude;
  final double longitude;
  final String subCategory;
  final List<Post> posts;

  const PlaceGroup({
    required this.locationName,
    required this.locationAddress,
    required this.latitude,
    required this.longitude,
    required this.subCategory,
    required this.posts,
  });
}

@immutable
class MapState {
  final String searchText;
  final bool isSearchFocused;
  final String? selectedCategory;

  const MapState({
    this.searchText = '',
    this.isSearchFocused = false,
    this.selectedCategory,
  });

  bool get showSuggestions => isSearchFocused && searchText.trim().isNotEmpty;

  MapState copyWith({
    String? searchText,
    bool? isSearchFocused,
    Object? selectedCategory = _sentinel,
  }) {
    return MapState(
      searchText: searchText ?? this.searchText,
      isSearchFocused: isSearchFocused ?? this.isSearchFocused,
      selectedCategory: selectedCategory == _sentinel
          ? this.selectedCategory
          : selectedCategory as String?,
    );
  }
}

const _sentinel = Object();

class MapNotifier extends Notifier<MapState> {
  @override
  MapState build() => const MapState();

  void onSearchTextChanged(String text) =>
      state = state.copyWith(searchText: text);

  void onSearchFocusChanged(bool focused) =>
      state = state.copyWith(isSearchFocused: focused);

  void clearSearch() =>
      state = state.copyWith(searchText: '', isSearchFocused: false);

  void selectCategory(String? category) =>
      state = state.copyWith(selectedCategory: category);
}

final mapProvider = NotifierProvider<MapNotifier, MapState>(MapNotifier.new);

final allPlacePostsProvider = Provider<List<Post>>((ref) {
  final newPosts = ref.watch(shareNewPostsProvider);
  final deleted = ref.watch(shareDeletedIdsProvider);
  final userPlacePosts = newPosts
      .where(
        (p) => p.category == '장소' && p.hasLocation && !deleted.contains(p.id),
      )
      .toList();
  final dummyFiltered = dummyMapPosts
      .where((p) => !deleted.contains(p.id))
      .toList();
  return [...userPlacePosts, ...dummyFiltered];
});

final placeGroupsProvider = Provider<List<PlaceGroup>>((ref) {
  final posts = ref.watch(allPlacePostsProvider);
  final state = ref.watch(mapProvider);

  final filtered = state.selectedCategory != null
      ? posts.where((p) => p.subCategory == state.selectedCategory).toList()
      : posts;

  final Map<String, List<Post>> grouped = {};
  for (final post in filtered) {
    if (post.locationName != null) {
      grouped.putIfAbsent(post.locationName!, () => []).add(post);
    }
  }

  return grouped.entries.map((entry) {
    final first = entry.value.first;
    return PlaceGroup(
      locationName: entry.key,
      locationAddress: first.locationAddress ?? '',
      latitude: first.latitude!,
      longitude: first.longitude!,
      subCategory: first.subCategory ?? '기타',
      posts: entry.value,
    );
  }).toList();
});

final mapSearchSuggestionsProvider = Provider.family<List<PlaceGroup>, String>((
  ref,
  query,
) {
  if (query.trim().isEmpty) return [];
  final groups = ref.watch(placeGroupsProvider);
  final q = query.toLowerCase();
  return groups.where((g) => g.locationName.toLowerCase().contains(q)).toList();
});
