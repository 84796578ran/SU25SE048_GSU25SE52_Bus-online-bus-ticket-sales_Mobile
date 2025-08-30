import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final Duration delay;

  const ErrorDialog({
    super.key,
    this.title = 'Lỗi!',
    this.message = 'Đã xảy ra lỗi',
    this.delay = const Duration(seconds: 2),
  });

  static void show(BuildContext context,
      {String? title, String? message, Duration? delay}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: title ?? 'Lỗi!',
          message: message ?? 'Đã xảy ra lỗi',
          delay: delay ?? const Duration(seconds: 2),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(delay, () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 80),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
