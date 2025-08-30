import 'package:flutter/material.dart';
import 'package:mobile/services/system_user_service.dart';
import 'package:mobile/services/ticket_service.dart';
import '../../../models/stationPassengerCount.dart';
import '../../../models/trip.dart';
import '../../../widget/SuccessDialog.dart';
import 'home_passenger_detail_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  static const path = '/driver/home';
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  late Future<List<StationPassengerCount>> _futureStationCounts;
  Trip? _currentTrip;
  bool _hasActiveTrip = false;
  @override
  void initState() {
    super.initState();
    _futureStationCounts = _loadData();
  }

  Future<List<StationPassengerCount>> _loadData() async {
    try {
      final systemUserId = await SystemUserService.getSystemUserId(); // lấy id từ token
      print(systemUserId);
      if (systemUserId == null) {
        throw Exception("Không tìm thấy SystemUserId");
      }
      final trip = await TicketService.fetchTripByDriver(systemUserId);
      if (trip == null) {
        print("Không có chuyến đi nào cho tài xế $systemUserId.");
        return [];
      }
      setState(() {
        _hasActiveTrip = true;
        _currentTrip = trip;
      });
      // từ trip.id gọi tiếp station-passenger-count
      return await TicketService.fetchStationPassengerCount(trip.id);
    } catch (e) {
      throw Exception("Lỗi khi load dữ liệu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan chuyến đi'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_hasActiveTrip && _currentTrip != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_currentTrip != null) {
                      try {
                        await TicketService.completeTrip(_currentTrip!.id);
                        SuccessDialog.show(
                          context,
                          title: 'Hoàn thành!',
                          message: 'Chuyến đi đã được kết thúc thành công.',
                          redirectPath: '/driver/home',
                          delay: const Duration(seconds: 2),
                        );

                        setState(() {
                          _futureStationCounts = _loadData();
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Hoàn thành Chuyến đi'),
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<StationPassengerCount>>(
              future: _futureStationCounts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi kết nối mạng: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Hiển thị thông báo phù hợp
                  return Center(
                    child: Text(
                      _hasActiveTrip
                          ? 'Chuyến đi hiện tại không có dữ liệu hành khách.'
                          : 'Không có chuyến đi nào đang hoạt động.',
                      textAlign: TextAlign.center,
                    ),
                  );
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
          ),
        ],
      ),
    );
  }
}