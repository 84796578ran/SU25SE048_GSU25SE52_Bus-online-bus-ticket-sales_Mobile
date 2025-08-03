import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/pages/customer_pages/screens/search/search_result_detail.dart';
import '../../../../../models/trip.dart';
import '../../../../models/TransferTrip.dart';

class SearchResultHintScreen extends StatelessWidget {
  static const path = '/customer/search-result-hint';
  final List<dynamic> results;

  const SearchResultHintScreen({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('DEBUG: SearchResultHintScreen nhận được ${results.length} kết quả.');

    // Sắp xếp kết quả: Chuyến trực tiếp lên đầu, sau đó đến chuyến trung chuyển
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
        appBar: AppBar(
          title: const Text('Chuyến xe gợi ý'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sentiment_dissatisfied_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                'Không tìm thấy chuyến nào phù hợp.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyến xe gợi ý'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: Colors.amber.shade100,
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Không có chuyến xe khớp hoàn toàn. Đây là các chuyến gợi ý gần nhất.',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: sortedResults.length,
              itemBuilder: (context, index) {
                final item = sortedResults[index];
                if (item is Trip) {
                  return _buildDirectTripCard(context, item);
                } else if (item is TransferTrip) {
                  return _buildTransferTripCard(context, item);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectTripCard(BuildContext context, Trip trip) {
    return InkWell(
      onTap: () {
        context.push(SearchResultDetailScreen.path, extra: trip);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chuyến trực tiếp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  '${NumberFormat('#,###').format(trip.price ?? 0)} VND',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: Colors.grey),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${trip.fromLocation} -> ${trip.endLocation}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Giờ đi: ${DateFormat('HH:mm').format(trip.timeStart)}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferTripCard(BuildContext context, TransferTrip transferTrip) {
    double totalprice = transferTrip.firstTrip.price + (transferTrip.secondTrip?.price ?? 0.0);
    return InkWell(
      onTap: () {
        context.push(SearchResultDetailScreen.path, extra: transferTrip);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chuyến trung chuyển',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue.shade700,
                  ),
                ),
                Text(
                  'Tổng giá: ${NumberFormat('#,###').format(totalprice)} VND',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: Colors.grey),
            _buildTripSegment(transferTrip.firstTrip, 'Chuyến đi đầu tiên'),
            if (transferTrip.secondTrip != null) ...[
              const SizedBox(height: 12),
              _buildTripSegment(transferTrip.secondTrip!, 'Chuyến đi thứ hai'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTripSegment(Trip trip, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Từ: ${trip.fromLocation} - Đến: ${trip.endLocation}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.schedule, color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            Text(
              'Giờ đi: ${DateFormat('HH:mm').format(trip.timeStart)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.attach_money, color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            Text(
              'Giá: ${NumberFormat('#,###').format(trip.price ?? 0)} VND',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }
}
