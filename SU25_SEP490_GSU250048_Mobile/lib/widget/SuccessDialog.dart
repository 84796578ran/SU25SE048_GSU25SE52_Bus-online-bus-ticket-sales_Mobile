import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? redirectPath;
  final Duration delay;

  const SuccessDialog({
    super.key,
    this.title = 'Chúc mừng!',
    this.message = 'Bạn đã đặt vé thành công!',
    this.redirectPath, // nếu null thì chỉ đóng dialog
    this.delay = const Duration(seconds: 3),
  });

  static void show(
      BuildContext context, {
        String? title,
        String? message,
        String? redirectPath,
        Duration? delay,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessDialog(
          title: title ?? 'Chúc mừng!',
          message: message ?? 'Bạn đã đặt vé thành công!',
          redirectPath: redirectPath,
          delay: delay ?? const Duration(seconds: 3),
        );
      },
    );
  }

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        Navigator.of(context).pop(); // đóng dialog
        if (widget.redirectPath != null) {
          context.go(widget.redirectPath!); // chỉ điều hướng khi có path
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.message,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
