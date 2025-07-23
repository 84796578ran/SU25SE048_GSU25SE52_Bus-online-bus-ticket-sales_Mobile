import 'package:flutter/material.dart';
import 'package:mobile/services/booking_service.dart';
import '../../../../widget/datePicker_widget.dart';
import '../../../../widget/provinceDropdown_widget.dart';

// Loại chuyến đi
enum TripType { oneWay, roundTrip }

class SearchScreen extends StatefulWidget {
  static const path = '/customer/search-trip';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? _selectedFrom;
  String? _selectedTo;
  DateTime _timeStart = DateTime.now();
  DateTime? _returnDate;

  bool _isLoading = false;
  bool _hasSearched = false;

  TripType _tripType = TripType.oneWay;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _timeStart.isBefore(today) ? today : _timeStart,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _timeStart = picked);
    }
  }

  Future<void> _pickReturnDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? _timeStart,
      firstDate: _timeStart,
      lastDate: _timeStart.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _returnDate = picked);
    }
  }

  Future<void> _searchTrip() async {
    if (_selectedFrom == null || _selectedTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn điểm đi và điểm đến')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final trips = await BookingService.searchOneWayTrip(
        fromLocation: _selectedFrom!,
        endLocation: _selectedTo!,
        timeStart: _timeStart,
      );

      if (trips.isNotEmpty) {
        Navigator.pushNamed(
          context,
          '/customer/search-result',
          arguments: trips,
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thông báo'),
            content: const Text('Không có chuyến nào phù hợp'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tìm chuyến')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: AppBar(
            title: const Text(
              'Tìm chuyến xe',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ToggleButtons(
                    isSelected: [
                      _tripType == TripType.oneWay,
                      _tripType == TripType.roundTrip,
                    ],
                    onPressed: (index) =>
                        setState(() => _tripType = TripType.values[index]),
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor: Colors.blue,
                    color: Colors.blueGrey,
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth / 2.5,
                      minHeight: 40,
                    ),
                    children: const [
                      Text('Một chiều'),
                      Text('Khứ hồi'),
                    ],
                  ),
                );
              },
            ),


            const SizedBox(height: 24),

            ProvinceDropdown(
              label: 'Điểm đi',
              selected: _selectedFrom,
              onChanged: (value) => setState(() => _selectedFrom = value),
            ),
            const SizedBox(height: 20),

            ProvinceDropdown(
              label: 'Điểm đến',
              selected: _selectedTo,
              onChanged: (value) => setState(() => _selectedTo = value),
            ),
            const SizedBox(height: 20),

            DatePickerRow(
              date: _timeStart,
              label: 'Ngày đi',
              onSelect: _pickDate,
            ),
            const SizedBox(height: 20),

            if (_tripType == TripType.roundTrip)
              DatePickerRow(
                date: _returnDate ?? _timeStart,
                label: 'Ngày về',
                onSelect: _pickReturnDate,
              ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _searchTrip,
                icon: const Icon(Icons.search),
                label: _isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Tìm chuyến', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
