import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../../models/customer.dart';
import '../../../../models/rating.dart';
import '../../../../models/ticket.dart';
import '../../../../services/rating_service.dart';

class HistoryDetailScreen extends StatelessWidget {
  final Ticket ticket;
  final Customer customer;
  const HistoryDetailScreen({super.key, required this.ticket, required this.customer});

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
            Text('Mã vé: ${ticket.ticketId}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Text('Tên khách hàng: ${ticket.customerName}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 15),
            Text('Từ trạm: ${ticket.fromTripStation ?? '---'}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 15),
            Text('Đến trạm: ${ticket.toTripStation ?? '---'}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 15),
            Text('Ghế: ${ticket.seatId}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 15),
            Text(
              'Giá: ${ticket.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}đ',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 15),
            Text('Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(ticket.createDate)}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 15),
            Text('Trạng thái: ${_statusToString(ticket.status)}', style: const TextStyle(fontSize: 20)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  int ratingValue = 5;
                  String? comment;

                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Đánh giá chuyến đi'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Bạn thấy chuyến đi này như thế nào?'),
                            const SizedBox(height: 10),
                            RatingBar.builder(
                              initialRating: 5,
                              minRating: 0,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                              onRatingUpdate: (rating) {
                                ratingValue = rating.toInt();
                              },
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Bình luận (tuỳ chọn)',
                              ),
                              onChanged: (value) {
                                comment = value;
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context); // đóng dialog trước

                              try {
                                final success = await RatingService.submitRating(
                                  Rating(
                                    ticketId: ticket.id, // Sử dụng id là khóa chính
                                    customerId: customer.id,
                                    score: ratingValue,
                                    comment: comment,
                                  ),
                                );

                                if (success) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Cảm ơn'),
                                      content: const Text('Cảm ơn bạn đã đánh giá dịch vụ của chúng tôi!'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Đóng'),
                                        )
                                      ],
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi khi gửi đánh giá: $e')),
                                );
                              }
                            },
                            child: const Text('Gửi'),
                          ),
                        ],
                      );
                    },
                  );
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
