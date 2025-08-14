// lib/pages/customer_pages/screens/search/search_result_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/pages/customer_pages/screens/search/search_result_detail.dart';
import '../../../../../models/trip.dart';
import '../../../../models/TransferTrip.dart';
import '../../../../models/station.dart';

class SearchResultScreen extends StatefulWidget {
  static const path = '/customer/search-result';
  final bool isRoundTrip;
  final List<dynamic>? results; // one way
  final List<dynamic>? departResults; // round trip
  final List<dynamic>? returnResults; // round trip
  final Map<int, Station> stations;

  const SearchResultScreen({super.key, required this.isRoundTrip, this.results, this.departResults, this.returnResults, required this.stations});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  dynamic _selectedDepart;
  dynamic _selectedReturn;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.isRoundTrip ? 2 : 1, vsync: this);
  }

  List<dynamic> _sorted(List<dynamic> list) {
    final copy = List<dynamic>.from(list);
    copy.sort((a, b) {
      if (a is Trip && b is TransferTrip) return -1;
      if (a is TransferTrip && b is Trip) return 1;
      return 0;
    });
    return copy;
  }

  Widget _buildList(List<dynamic> items) {
    final sortedResults = _sorted(items);
    if (sortedResults.isEmpty) {
      return const Center(child: Text('Không tìm thấy chuyến nào phù hợp.'));
    }
    return ListView.builder(
      itemCount: sortedResults.length,
      itemBuilder: (context, index) {
        final item = sortedResults[index];
        final isDirect = item is Trip;
        final bool isRoundTrip = widget.isRoundTrip;
        final bool isDepartTab = isRoundTrip ? _tabController.index == 0 : true;
        final bool isSelected = (!isRoundTrip) ? false : (isDepartTab ? identical(_selectedDepart, item) : identical(_selectedReturn, item));
        return InkWell(
          onTap: () {
            if (!isRoundTrip) {
              context.push(SearchResultDetailScreen.path, extra: {'tripOrTransferTrip': item, 'stations': widget.stations, 'isRoundTrip': false});
            } else {
              setState(() {
                if (isDepartTab) {
                  _selectedDepart = item;
                } else {
                  _selectedReturn = item;
                }
              });
            }
          },
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDirect ? 'Loại chuyến: Trực tiếp' : 'Loại chuyến: Trung chuyển',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDirect ? Colors.green.shade700 : Colors.blue.shade700),
                  ),
                  if (isRoundTrip)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.blue : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isDepartTab ? 'Đã chọn chuyến đi' : 'Đã chọn chuyến về',
                            style: TextStyle(color: isSelected ? Colors.blue : Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (isDirect) ...[
                    Text(
                      'Từ: ${item.fromLocation}                  Đến: ${item.endLocation}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 7),
                    Text('Giờ đi: ${DateFormat('HH:mm').format(item.timeStart)}', style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 7),
                    Text(
                      'Giá: ${NumberFormat('#,###').format(item.price)} VND',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ] else ...[
                    Text('Chuyến đi đầu tiên:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                    Text('  Từ: ${item.firstTrip.fromLocation} Đến: ${item.firstTrip.endLocation}', style: const TextStyle(fontSize: 20)),
                    Text('  Giờ đi: ${DateFormat('HH:mm').format(item.firstTrip.timeStart)}', style: const TextStyle(fontSize: 20)),
                    if (item.secondTrip != null) ...[
                      const SizedBox(height: 12),
                      const Text('Chuyến đi thứ hai:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                      Text('  Từ: ${item.secondTrip!.fromLocation} Đến: ${item.secondTrip!.endLocation}', style: const TextStyle(fontSize: 20)),
                      Text('  Giờ đi: ${DateFormat('HH:mm').format(item.secondTrip!.timeStart)}', style: const TextStyle(fontSize: 20)),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      'Tổng giá: ${NumberFormat('#,###').format(item.firstTrip.price + (item.secondTrip?.price ?? 0.0))} VND',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRoundTrip) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kết quả tìm kiếm')),
        body: _buildList(widget.results ?? const []),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả tìm kiếm (Khứ hồi)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chuyến đi'),
            Tab(text: 'Chuyến về'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildList(widget.departResults ?? const []), _buildList(widget.returnResults ?? const [])],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedDepart != null && _selectedReturn != null
                    ? () {
                        context.push(
                          SearchResultDetailScreen.path,
                          extra: {
                            'isRoundTrip': true,
                            'tripOrTransferTrip': _selectedDepart,
                            'returnTripOrTransferTrip': _selectedReturn,
                            'stations': widget.stations,
                          },
                        );
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Tiếp tục'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
