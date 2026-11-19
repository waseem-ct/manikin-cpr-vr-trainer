import 'package:flutter/material.dart';

/// Simple yes/no dialog. Pops `true` when confirmed, `false` when cancelled.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({super.key, required this.title, required this.message, this.confirmLabel = 'Confirm', this.cancelLabel = 'Cancel'});

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(cancelLabel)),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(confirmLabel)),
      ],
    );
  }
}
