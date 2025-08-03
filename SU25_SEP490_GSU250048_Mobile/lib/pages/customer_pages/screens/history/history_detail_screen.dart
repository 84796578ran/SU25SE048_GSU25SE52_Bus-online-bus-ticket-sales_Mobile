import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/ticket.dart';

class HistoryDetailScreen extends StatelessWidget {
  final Ticket ticket;

  const HistoryDetailScreen({super.key, required this.ticket});

  String _statusToString(int? status) {
    switch (status) {
      case 1:
        return 'Chờ thanh toán';
      case 2:
        return 'Đã thanh toán';
      case 3:
        return 'Đã hủy';
      case 4:
        return 'Hoàn tất';
      default:
        return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết vé')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã vé: ${ticket.ticketId}', style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Text('Tên khách hàng: ${ticket.customerName}',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 15),
            Text('Từ trạm: ${ticket.fromTripStation ?? '---'}',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 15),
            Text('Đến trạm: ${ticket.toTripStation ?? '---'}',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 15),
            Text('Ghế: ${ticket.seatId}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 15),
            Text(
                'Giá: ${ticket.price.toStringAsFixed(0).replaceAllMapped(
                    RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}đ',
                style: const TextStyle(fontSize: 20)
            ),
            const SizedBox(height: 15),
            Text('Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(
                ticket.createDate)}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 15),
            Text('Trạng thái: ${_statusToString(ticket.status)}',
                style: const TextStyle(fontSize: 20)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  print("Chuyển đến trang đánh giá chuyến đi cho vé ${ticket
                      .ticketId}");
                },
                icon: const Icon(Icons.star_rate_rounded),
                label: const Text('Đánh giá chuyến đi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}