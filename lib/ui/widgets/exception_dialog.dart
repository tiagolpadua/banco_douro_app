import 'package:flutter/material.dart';
import '../styles/colors.dart';

void showExceptionDialog(
  BuildContext context, {
  required String content,
  String title = 'Ocorreu um problema',
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning, color: AppColor.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'OK',
            style: TextStyle(
              color: AppColor.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
