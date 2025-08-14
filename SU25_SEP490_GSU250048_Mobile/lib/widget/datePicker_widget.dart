import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerRow extends StatelessWidget {
  final DateTime? date; // THAY ĐỔI TỪ DateTime SANG DateTime?
  final String label;
  final VoidCallback onSelect;

  const DatePickerRow({
    required this.date, // Vẫn required, nhưng chấp nhận null
    required this.label,
    required this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Xử lý trường hợp date là null
    final displayDate = date ?? DateTime.now(); // Hiển thị ngày hiện tại nếu date là null

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Text(
              'Ngày: ${DateFormat('dd/MM/yyyy').format(displayDate)}', // Sử dụng displayDate
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.calendar_today_outlined, size: 20),
          ],
        ),
      ),
    );
  }
}