import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsg_mobile/core/components/nsg_search_bar.dart';
import 'package:nsg_mobile/features/major/presentation/providers/major_provider.dart';

class MajorSearchBar extends ConsumerWidget {
  const MajorSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(majorProvider);
    final notifier = ref.read(majorProvider.notifier);

    return NsgSearchBar(
      searchText: state.searchText,
      onChanged: notifier.onSearchTextChanged,
      onSubmitted: notifier.submitSearch,
      onClear: notifier.clearSearch,
      onFocusChanged: notifier.onSearchFocusChanged,
    );
  }
}
