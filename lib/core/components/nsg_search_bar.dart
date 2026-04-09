import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';

class NsgSearchBar extends StatefulWidget {
  final String searchText;
  final String hintText;
  final bool autoFocus;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final ValueChanged<bool> onFocusChanged;

  const NsgSearchBar({
    super.key,
    required this.searchText,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onFocusChanged,
    this.hintText = '찾고싶은 검색어로 입력해주세요.',
    this.autoFocus = false,
  });

  @override
  State<NsgSearchBar> createState() => _NsgSearchBarState();
}

class _NsgSearchBarState extends State<NsgSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchText);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      widget.onFocusChanged(_focusNode.hasFocus);
    });
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(NsgSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchText != oldWidget.searchText &&
        widget.searchText != _controller.text) {
      _controller.text = widget.searchText;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          hintText: widget.hintText,
          hintStyle: NsgTextStyle.body3.copyWith(color: NsgColor.black400),
          suffixIcon: widget.searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Symbols.close,
                    size: 18,
                    color: NsgColor.black400,
                  ),
                  onPressed: () {
                    widget.onClear();
                    _focusNode.unfocus();
                  },
                )
              : const Icon(
                  Symbols.search,
                  size: 20,
                  color: NsgColor.black400,
                ),
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
        onChanged: widget.onChanged,
        onSubmitted: (value) {
          widget.onSubmitted(value);
          _focusNode.unfocus();
        },
      ),
    );
  }
}
