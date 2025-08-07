// lib/pages/customer_pages/screens/search/search_result_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/pages/customer_pages/screens/search/search_result_detail.dart';
import '../../../../../models/trip.dart';
import '../../../../models/TransferTrip.dart';
import '../../../../models/station.dart';

class SearchResultScreen extends StatelessWidget {
  static const path = '/customer/search-result';
  final List<dynamic> results;
  final Map<int, Station> stations;

  const SearchResultScreen({Key? key, required this.results, required this.stations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('DEBUG: SearchResultScreen nhận được ${results.length} kết quả.');

    List<dynamic> sortedResults = List.from(results);
    sortedResults.sort((a, b) {
      if (a is Trip && b is TransferTrip) {
        return -1;
      }
      if (a is TransferTrip && b is Trip) {
        return 1;
      }
      return 0;
    });

    if (sortedResults.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kết quả tìm kiếm')),
        body: const Center(
          child: Text('Không tìm thấy chuyến nào phù hợp.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả tìm kiếm')),
      body: ListView.builder(
        itemCount: sortedResults.length,
        itemBuilder: (context, index) {
          final item = sortedResults[index];
          if (item is Trip) {
            return InkWell(
                onTap: () {
                  context.push(SearchResultDetailScreen.path, extra: {'tripOrTransferTrip': item, 'stations': stations});
              },
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Loại chuyến: Trực tiếp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade700)),
                      const SizedBox(height: 10),
                      Text(
                        'Từ: ${item.fromLocation}                  Đến: ${item.endLocation}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 7),
                      Text('Giờ đi: ${DateFormat('HH:mm').format(item.timeStart)}', style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 7),
                      Text('Giá: ${NumberFormat('#,###').format(item.price ?? 0)} VND', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                ),
              ),
            );
          } else if (item is TransferTrip) {
            return InkWell( // Đảm bảo toàn bộ Card có thể nhấn
              onTap: () {
                context.push(SearchResultDetailScreen.path, extra: {'tripOrTransferTrip': item, 'stations': stations});
              },
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Loại chuyến: Trung chuyển', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue.shade700)),
                      const SizedBox(height: 12),
                      Text('Chuyến đi đầu tiên:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                      Text('  Từ: ${item.firstTrip.fromLocation} Đến: ${item.firstTrip.endLocation}', style: const TextStyle(fontSize: 20)),
                      Text('  Giờ đi: ${DateFormat('HH:mm').format(item.firstTrip.timeStart)}', style: const TextStyle(fontSize: 20)),

                      if (item.secondTrip != null) ...[
                        const SizedBox(height: 12),
                        Text('Chuyến đi thứ hai:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                        Text('  Từ: ${item.secondTrip!.fromLocation} Đến: ${item.secondTrip!.endLocation}', style: const TextStyle(fontSize: 20)),
                        Text('  Giờ đi: ${DateFormat('HH:mm').format(item.secondTrip!.timeStart)}', style: const TextStyle(fontSize: 20)),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        'Tổng giá: ${NumberFormat('#,###').format(item.firstTrip.price + (item.secondTrip?.price ?? 0.0))} VND',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}