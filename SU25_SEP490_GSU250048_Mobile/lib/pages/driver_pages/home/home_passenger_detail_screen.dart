import 'package:flutter/material.dart';
import 'package:mobile/models/stationPassengerCount.dart';

class HomePassengerDetailScreen extends StatefulWidget {
  static const path = '/driver/home-detail';


  final StationPassengerCount stationData;

  const HomePassengerDetailScreen({
    super.key,
    required this.stationData,
  });

  @override
  State<HomePassengerDetailScreen> createState() => _HomePassengerDetailScreenState();
}

class _HomePassengerDetailScreenState extends State<HomePassengerDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final passengers = widget.stationData.passengers;
    final stationName = widget.stationData.stationName;

    return Scaffold(
      appBar: AppBar(
        // Hiển thị tên trạm trên tiêu đề
        title: Text('Hành khách tại $stationName'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: passengers.isEmpty
          ? const Center(
        // Hiển thị thông báo khi không có hành khách
        child: Text(
          'Không có hành khách nào tại trạm này.',
          style: TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: passengers.length,
        itemBuilder: (context, index) {
          final passenger = passengers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 2.0,
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blueAccent),
              title: Text(
                passenger.customerFullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Mã vé: ${passenger.ticketId}',
              ),
              onTap: () {
                // Xử lý khi nhấn vào hành khách (ví dụ: hiển thị chi tiết hơn)
              },
            ),
          );
        },
      ),
    );
  }
}

