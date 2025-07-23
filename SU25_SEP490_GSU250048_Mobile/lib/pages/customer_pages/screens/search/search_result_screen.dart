import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/trip.dart';

class SearchResultScreen extends StatelessWidget {
  static const path = '/customer/search-result';

  const SearchResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Trip trip = ModalRoute.of(context)!.settings.arguments as Trip;
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả tìm kiếm')),
      body: ListTile(
        title: Text('${trip.fromLocation} ➔ ${trip.endLocation}'),
        subtitle: Text(
          '${DateFormat.Hm().format(trip.timeStart)} - ${DateFormat
              .Hm()
              .format(trip.timeEnd)}\n ${trip.price.toStringAsFixed(0)}₫',
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/customer/search-result-detail',
            arguments: trip,
          );
        },
      ),

    );
  }
}