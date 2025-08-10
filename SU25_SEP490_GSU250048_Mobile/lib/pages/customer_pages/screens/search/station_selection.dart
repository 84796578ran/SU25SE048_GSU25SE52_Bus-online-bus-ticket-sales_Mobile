// mobile/pages/customer_pages/screens/station/station_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/station.dart';
import '../../../../models/trip.dart';
 // Giả sử bạn có màn hình chọn ghế

class StationSelectionScreen extends StatefulWidget {
  static const path = '/customer/station-selection';
  final Trip trip;
  final List<Station> stations;

  const StationSelectionScreen({
    Key? key,
    required this.trip,
    required this.stations,
  }) : super(key: key);

  @override
  State<StationSelectionScreen> createState() => _StationSelectionScreenState();
}

class _StationSelectionScreenState extends State<StationSelectionScreen> {
  Station? selectedPickupStation;
  Station? selectedDropoffStation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn điểm đón & trả'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Menu dropdown cho điểm đón
            DropdownButtonFormField<Station>(
              decoration: const InputDecoration(labelText: 'Điểm đón'),
              value: selectedPickupStation,
              items: widget.stations.map((station) {
                return DropdownMenuItem<Station>(
                  value: station,
                  child: Text('${station.name} - ${station.locationName}'),
                );
              }).toList(),
              onChanged: (Station? newValue) {
                setState(() {
                  selectedPickupStation = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            // Menu dropdown cho điểm trả
            DropdownButtonFormField<Station>(
              decoration: const InputDecoration(labelText: 'Điểm trả'),
              value: selectedDropoffStation,
              items: widget.stations.map((station) {
                return DropdownMenuItem<Station>(
                  value: station,
                  child: Text('${station.name} - ${station.locationName}'),
                );
              }).toList(),
              onChanged: (Station? newValue) {
                setState(() {
                  selectedDropoffStation = newValue;
                });
              },
            ),
            const Spacer(),
            // ElevatedButton(
            //   onPressed: selectedPickupStation != null && selectedDropoffStation != null
            //       ? () {
            //     // Chuyển sang màn hình chọn ghế với dữ liệu đầy đủ
            //     context.push(
            //       SeatSelectionScreen.path,
            //       extra: {
            //         'trip': widget.trip,
            //         'pickupStation': selectedPickupStation,
            //         'dropoffStation': selectedDropoffStation,
            //       },
            //     );
            //   }
            //       : null,
            //   child: const Text('Chọn ghế'),
            // ),
          ],
        ),
      ),
    );
  }
}