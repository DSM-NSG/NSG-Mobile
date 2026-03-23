import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';

class NsgDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const NsgDialog({
    super.key,
    required this.title,
    required this.content,
    required this.cancelLabel,
    required this.confirmLabel,
    this.onCancel,
    this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    required String cancelLabel,
    required String confirmLabel,
    bool barrierDismissible = false,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) {
        final navigator = Navigator.of(ctx);
        return NsgDialog(
          title: title,
          content: content,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          onCancel: () {
            onCancel?.call();
            if (navigator.canPop()) navigator.pop(false);
          },
          onConfirm: () {
            onConfirm?.call();
            if (navigator.canPop()) navigator.pop(true);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: NsgColor.black50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: NsgColor.black400, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: NsgTextStyle.header2.copyWith(color: NsgColor.black800),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: NsgTextStyle.body3.copyWith(color: NsgColor.black500),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: cancelLabel,
                    backgroundColor: NsgColor.black300,
                    onTap: onCancel ?? () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DialogButton(
                    label: confirmLabel,
                    backgroundColor: NsgColor.danger,
                    onTap: onConfirm ?? () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: NsgTextStyle.header2.copyWith(color: NsgColor.black50),
        ),
      ),
    );
  }
}
