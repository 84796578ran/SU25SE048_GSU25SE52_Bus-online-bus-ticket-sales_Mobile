import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/trip.dart';
import 'package:intl/intl.dart';

import '../../../../models/TransferTrip.dart';
import '../../../../services/trip_service.dart';
import '../search/search_result_detail.dart';

class FutureTripScreen extends StatefulWidget {
  static const path ='/customer/future-trips';
  final int companyId;
  final String companyName;

  const FutureTripScreen({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<FutureTripScreen> createState() => _FutureTripScreenState();
}

class _FutureTripScreenState extends State<FutureTripScreen> {
  late Future<List<Trip>> _futureTrips;

  @override
  void initState() {
    super.initState();
    _futureTrips = TripServices.getFutureTripsByCompany(widget.companyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chuyến đi của ${widget.companyName}'),
        backgroundColor: Colors.pinkAccent.shade100,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Trip>>(
        future: _futureTrips,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi khi tải chuyến đi: ${snapshot.error}'));
          }

          final trips = snapshot.data ?? [];

          if (trips.isEmpty) {
            return const Center(child: Text('Không có chuyến nào sắp tới.'));
          }

          return Padding(
            padding: const EdgeInsets.only(top:  40),
            child: ListView.separated(
              itemCount: trips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final trip = trips[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                      onTap: () {

                        context.push(
                          SearchResultDetailScreen.path,
                          extra: trip,
                        );
                        debugPrint('Trip tapped: ${trip.id}');
                      },
                      child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_bus, color: Colors.blueAccent, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Từ: ${trip.fromLocation}' ,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                                ),
                                Text('Đến: ${trip.endLocation}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Thời gian khởi hành: ${DateFormat('HH:mm dd/MM/yyyy').format(trip.timeStart)} ',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text(
                                      'Thời gian kết thúc chuyến: ${DateFormat('HH:mm dd/MM/yyyy').format(trip.timeEnd)}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                                ),
                                Text(
                                  '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(trip.price)}',
                                  style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold, color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
