import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/features/major/presentation/providers/major_provider.dart';

class AutocompleteList extends ConsumerStatefulWidget {
  const AutocompleteList({super.key});

  @override
  ConsumerState<AutocompleteList> createState() => _AutocompleteListState();
}

class _AutocompleteListState extends ConsumerState<AutocompleteList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(majorProvider);
    final suggestions =
        ref.watch(autocompleteResultsProvider(state.searchText));

    if (suggestions.isEmpty) return const SizedBox.shrink();

    final items = [
      ...suggestions.map(
        (s) => _AutocompleteItem(
          text: s,
          query: state.searchText,
          onTap: () {
            ref.read(majorProvider.notifier).submitSearch(s);
            FocusScope.of(context).unfocus();
          }
        ),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: NsgColor.black50,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: const ScrollbarThemeData(
            thumbColor: WidgetStatePropertyAll(NsgColor.black500),
            trackColor: WidgetStatePropertyAll(Colors.transparent),
            trackBorderColor: WidgetStatePropertyAll(Colors.transparent),
          ),
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: false,
          thickness: 4,
          radius: const Radius.circular(2),
          scrollbarOrientation: ScrollbarOrientation.right,
          child: ScrollConfiguration(
          behavior: _NoGlowScrollBehavior(),
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: items,
          ),
        ),
        ),
      ),
    );
  }
}

/// 글로우 효과 제거
class _NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}

class _AutocompleteItem extends StatelessWidget {
  final String text;
  final String query;
  final VoidCallback onTap;

  const _AutocompleteItem({
    required this.text,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12).copyWith(left: 10),
        child: _buildText(),
      ),
    );
  }

  Widget _buildText() {
    final q = query.toLowerCase();
    final startsWithQuery = q.isNotEmpty && text.toLowerCase().startsWith(q);

    if (!startsWithQuery) {
      return Text(
        text,
        style: NsgTextStyle.body2.copyWith(color: NsgColor.black800),
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, q.length),
            style: NsgTextStyle.body2.copyWith(color: NsgColor.orange400),
          ),
          TextSpan(
            text: text.substring(q.length),
            style: NsgTextStyle.body2.copyWith(color: NsgColor.black800),
          ),
        ],
      ),
    );
  }
}
