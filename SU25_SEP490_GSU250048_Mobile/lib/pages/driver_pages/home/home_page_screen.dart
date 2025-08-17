import 'package:flutter/material.dart';
import 'package:mobile/services/ticket_service.dart';
import '../../../models/stationPassengerCount.dart';
import '../../../provider/systemUser_provider.dart';
import '../../../provider/trip_provider.dart';
import 'home_passenger_detail_screen.dart';
import 'package:provider/provider.dart';

class DriverHomeScreen extends StatefulWidget {
  static const path = '/driver/home';
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  Future<List<StationPassengerCount>>? _futureStationCounts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_futureStationCounts == null) {
      _futureStationCounts = _loadCurrentTripAndPassengers();
    }
  }

  Future<List<StationPassengerCount>> _loadCurrentTripAndPassengers() async {
    final systemUserProvider = Provider.of<SystemUserProvider>(context, listen: false);
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    final driverId = systemUserProvider.systemUserId;
    final token = systemUserProvider.token;
    if (driverId == null || token == null) {
      return [];
    }
    if (token == null) return [];
    final trips = await TicketService.fetchTripsByDriver(driverId,token);

    if (trips.isEmpty) {
      return [];
    }

    final currentTrip = trips.first;
    tripProvider.setTripId(currentTrip.id);
    final counts = await TicketService.fetchStationPassengerCount(currentTrip.id);
    return counts;
  }


  @override
  Widget build(BuildContext context) {
    final tripId = context.watch<TripProvider>().currentTripId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan chuyến đi'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: tripId == null
          ? const Center(child: Text("Bạn không có chuyến đi nào trong hôm nay."))
          : FutureBuilder<List<StationPassengerCount>>(
        future: _futureStationCounts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('📭 Không có dữ liệu hành khách.'));
          }

          final counts = snapshot.data!;
          return ListView.builder(
            itemCount: counts.length,
            itemBuilder: (context, index) {
              final stationCount = counts[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                elevation: 2.0,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  leading: const Icon(Icons.location_on,
                      color: Colors.deepOrange),
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
                        builder: (ctx) => HomePassengerDetailScreen(
                          stationData: stationCount,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
