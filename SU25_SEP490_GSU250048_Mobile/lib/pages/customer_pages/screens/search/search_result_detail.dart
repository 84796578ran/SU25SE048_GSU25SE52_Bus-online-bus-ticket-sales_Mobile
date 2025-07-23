import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/trip.dart';

class SearchResultDetailScreen extends StatelessWidget {
  static const path = '/customer/search-result-detail';

  const SearchResultDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)!.settings.arguments as Trip;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết chuyến xe')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🧭 Từ: ${trip.fromLocation}', style: const TextStyle(fontSize: 18)),
            Text('📍 Đến: ${trip.endLocation}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('⏰ Thời gian: ${DateFormat.yMMMd().add_Hm().format(trip.timeStart)} ➜ ${DateFormat.Hm().format(trip.timeEnd)}'),
            //Text('💺 Loại xe: ${trip.vehicleName}'),
            Text('💵 Giá: ${trip.price.toStringAsFixed(0)}₫'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // TODO: Đặt vé / hành động tiếp theo
              },
              child: const Text('Đặt vé ngay'),
            ),
          ],
        ),
      ),
    );
  }
}
