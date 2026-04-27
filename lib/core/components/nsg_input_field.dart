import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';

class NsgInputField extends StatefulWidget {
  final TextEditingController? controller;
  final String hint;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;

  const NsgInputField({
    super.key,
    this.controller,
    required this.hint,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.textInputAction,
    this.keyboardType,
  });

  @override
  State<NsgInputField> createState() => _NsgInputFieldState();
}

class _NsgInputFieldState extends State<NsgInputField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _isFocused = _focusNode.hasFocus);
      });
    _charCount = widget.controller?.text.length ?? 0;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showCounter = widget.maxLength != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: NsgColor.black50,
        borderRadius: BorderRadius.circular(8),
        border: _isFocused
            ? Border.all(color: NsgColor.orange300, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            buildCounter: showCounter
                ? (_, {required currentLength, required isFocused, maxLength}) =>
                    null
                : null,
            onChanged: (v) {
              if (showCounter) setState(() => _charCount = v.length);
              widget.onChanged?.call(v);
            },
            onTap: widget.onTap,
            textInputAction: widget.textInputAction,
            keyboardType:
                widget.keyboardType ??
                (widget.maxLines == 1
                    ? TextInputType.text
                    : TextInputType.multiline),
            cursorColor: NsgColor.orange300,
            style: NsgTextStyle.body3.copyWith(color: NsgColor.black800),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: NsgTextStyle.body3.copyWith(color: NsgColor.black400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          if (showCounter)
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 8),
              child: Text(
                '$_charCount/${widget.maxLength}',
                style: NsgTextStyle.body4.copyWith(color: NsgColor.black400),
              ),
            ),
        ],
      ),
    );
  }
}
