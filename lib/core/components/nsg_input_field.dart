import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';

class NsgInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;

  const NsgInputField({
    super.key,
    this.controller,
    required this.hint,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.textInputAction,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: NsgColor.black50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: minLines,
        onChanged: onChanged,
        textInputAction: textInputAction,
        keyboardType:
            keyboardType ??
            (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
        cursorColor: NsgColor.orange300,
        style: NsgTextStyle.body3.copyWith(color: NsgColor.black800),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: NsgTextStyle.body3.copyWith(color: NsgColor.black400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
