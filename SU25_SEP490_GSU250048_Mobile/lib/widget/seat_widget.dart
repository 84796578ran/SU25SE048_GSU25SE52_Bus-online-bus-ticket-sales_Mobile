import 'package:flutter/material.dart';
import 'package:mobile/models/seat.dart';
enum SeatStatus { available, booked, pending }
// class Seat {
//   final String id;
//   SeatStatus status;
//
//   Seat({required this.id, this.status = SeatStatus.available});
// }

class SeatMapWidget extends StatefulWidget {
  final List<Seat> seats;
  final Function(Seat)? onSeatSelected;

  const SeatMapWidget({
    Key? key,
    required this.seats,
    this.onSeatSelected,
  }) : super(key: key);

  @override
  State<SeatMapWidget> createState() => _SeatMapWidgetState();
}

class _SeatMapWidgetState extends State<SeatMapWidget> {

  Color _getSeatColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.available:
        return Colors.green; // Ghế còn trống
      case SeatStatus.booked:
        return Colors.red; // Ghế đã đặt
      case SeatStatus.pending:
        return Colors.orange; // Ghế đang chờ thanh toán
      default:
        return Colors.grey; // Mặc định
    }
  }

  IconData _getSeatIcon(SeatStatus status) {
    switch (status) {
      case SeatStatus.available:
        return Icons.event_seat;
      case SeatStatus.booked:
        return Icons.check_box;
      case SeatStatus.pending:
        return Icons.hourglass_empty;
      default:
        return Icons.event_seat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sơ đồ ghế:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true, // Quan trọng để GridView không chiếm hết không gian vô hạn
          physics: const NeverScrollableScrollPhysics(), // Không cho GridView cuộn
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // Số ghế trên mỗi hàng
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1.0, // Tỉ lệ khung hình của mỗi ghế (vuông)
          ),
          itemCount: widget.seats.length,
          itemBuilder: (context, index) {
            final seat = widget.seats[index];
            return GestureDetector(
              onTap: () {
                if (seat.status == SeatStatus.available) {
                  widget.onSeatSelected?.call(seat);
                  setState(() {
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ghế ${seat.id} đã ${seat.status == SeatStatus.booked ? 'được đặt' : 'đang chờ thanh toán'}.')),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _getSeatColor(seat.status),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getSeatIcon(seat.status), color: Colors.white, size: 24),
                    Text(
                      seat.id.toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        // Chú thích sơ đồ ghế
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem(Colors.green, 'Còn trống'),
            _buildLegendItem(Colors.red, 'Đã đặt'),
            _buildLegendItem(Colors.orange, 'Đang chờ'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}