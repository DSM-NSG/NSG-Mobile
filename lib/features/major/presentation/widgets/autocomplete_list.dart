import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsg_mobile/core/components/nsg_autocomplete_list.dart';
import 'package:nsg_mobile/features/major/presentation/providers/major_provider.dart';

class AutocompleteList extends ConsumerWidget {
  const AutocompleteList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(majorProvider);
    final suggestions =
        ref.watch(autocompleteResultsProvider(state.searchText));
    final notifier = ref.read(majorProvider.notifier);

    return NsgAutocompleteList(
      suggestions: suggestions,
      query: state.searchText,
      onSelect: (s) {
        notifier.submitSearch(s);
        FocusScope.of(context).unfocus();
      },
    );
  }
}
