import 'package:flutter/material.dart';
import 'package:mobile/services/ticket_service.dart';
import '../../../models/stationPassengerCount.dart';
import 'home_passenger_detail_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  static const path = '/driver/home';
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  // Future để lưu trữ kết quả API
  late Future<List<StationPassengerCount>> _futureStationCounts;

  @override
  void initState() {
    super.initState();
    _futureStationCounts = TicketService.fetchStationPassengerCount(7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan chuyến đi'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<StationPassengerCount>>(
        future: _futureStationCounts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có dữ liệu hành khách.'));
          } else {
            final counts = snapshot.data!;
            return ListView.builder(
              itemCount: counts.length,
              itemBuilder: (context, index) {
                final stationCount = counts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 2.0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    leading: const Icon(Icons.location_on, color: Colors.deepOrange),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stationCount.stationName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Số hành khách: ${stationCount.passengerCount}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Điều hướng đến màn hình chi tiết và truyền toàn bộ đối tượng stationCount
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => HomePassengerDetailScreen(stationData: stationCount),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}