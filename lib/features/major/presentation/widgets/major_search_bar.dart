import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/features/major/presentation/providers/major_provider.dart';

class MajorSearchBar extends ConsumerStatefulWidget {
  const MajorSearchBar({super.key});

  @override
  ConsumerState<MajorSearchBar> createState() => _MajorSearchBarState();
}

class _MajorSearchBarState extends ConsumerState<MajorSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      ref
          .read(majorProvider.notifier)
          .onSearchFocusChanged(_focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(majorProvider);

    ref.listen(majorProvider, (prev, next) {
      if (prev?.searchText != next.searchText && next.searchText.isEmpty) {
        _controller.clear();
      }
      if (next.searchText != _controller.text) {
        _controller.text = next.searchText;
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
      }
    });

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: NsgColor.black50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: NsgTextStyle.body3.copyWith(color: NsgColor.black800),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: '찾고싶은 검색어로 입력해주세요.',
          hintStyle: NsgTextStyle.body3.copyWith(color: NsgColor.black400),
          suffixIcon: state.searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Symbols.close,
                    size: 18,
                    color: NsgColor.black400,
                  ),
                  onPressed: () {
                    ref.read(majorProvider.notifier).clearSearch();
                    _focusNode.unfocus();
                  },
                )
              : const Icon(Symbols.search, size: 20, color: NsgColor.black400),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          isDense: true,
        ),
        cursorColor: NsgColor.orange300,
        onChanged: (value) {
          ref.read(majorProvider.notifier).onSearchTextChanged(value);
        },
        onSubmitted: (value) {
          ref.read(majorProvider.notifier).submitSearch(value);
          _focusNode.unfocus();
        },
      ),
    );
  }
}
