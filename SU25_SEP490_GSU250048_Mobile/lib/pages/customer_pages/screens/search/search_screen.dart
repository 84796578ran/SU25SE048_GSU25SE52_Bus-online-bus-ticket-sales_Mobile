import 'package:flutter/material.dart';
import 'package:mobile/services/trip_service.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/services/station_service.dart';
import 'package:mobile/models/location.dart';
import 'package:mobile/models/station.dart';
import 'package:mobile/widget/datePicker_widget.dart';
import 'package:collection/collection.dart';
import '../../../../models/trip.dart';// Sửa lỗi chính tả
import 'package:go_router/go_router.dart';

import '../../../../services/navigation_service.dart';
import '../../../../widget/gerneric_dropdown.dart';

enum TripType { oneWay, roundTrip }

class SearchScreen extends StatefulWidget {
  static const path = '/customer/search-trip';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? _selectedFromProvinceName;
  int? _selectedFromLocationId;

  String? _selectedToProvinceName;
  int? _selectedToLocationId;

  Station? _selectedDepartureStation;
  Station? _selectedArrivalStation;

  DateTime? _timeStart;
  DateTime? _returnDate;

  List<Location> _allProvincesList = [];
  List<Station> _allStationsList = [];

  List<Station> _departureStations = [];
  List<Station> _arrivalStations = [];

  bool _isLoading = false;
  bool _hasSearched = false;

  TripType _tripType = TripType.oneWay;

  @override
  void initState() {
    super.initState();
    _timeStart = DateTime.now();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final results = await Future.wait([
        LocationService.getProvinces(),
        StationService.getAllStations(),
      ]);

      final provinces = results[0] as List<Location>;
      final stations = results[1] as List<Station>;

      setState(() {
        _allProvincesList = provinces;
        _allStationsList = stations;
        print('DEBUG: Tải thành công ${provinces.length} tỉnh và ${stations.length} điểm.');
      });
    } catch (e) {
      print('ERROR: Lỗi khi tải tất cả dữ liệu: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải dữ liệu ban đầu. Vui lòng thử lại.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterStationsByLocation(String? locationName, bool isDeparture) {
    setState(() {
      if (isDeparture) {
        _selectedDepartureStation = null;
        if (locationName != null) {
          _departureStations = _allStationsList
              .where((station) =>
          station.locationName.toLowerCase() == locationName.toLowerCase())
              .toList();
          print('DEBUG: Đã lọc ${_departureStations.length} điểm đón cho tỉnh/thành phố "$locationName".');
        } else {
          _departureStations = [];
        }
      } else {
        _selectedArrivalStation = null;
        if (locationName != null) {
          _arrivalStations = _allStationsList
              .where((station) =>
          station.locationName.toLowerCase() == locationName.toLowerCase())
              .toList();
          print('DEBUG: Đã lọc ${_arrivalStations.length} điểm trả cho tỉnh/thành phố "$locationName".');
        } else {
          _arrivalStations = [];
        }
      }
    });
  }

  void _pickDate() async {
    final DateTime initialDate = _timeStart ?? DateTime.now();
    final DateTime firstDate = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(firstDate.year, firstDate.month, firstDate.day),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null && pickedDate != _timeStart) {
      setState(() {
        _timeStart = pickedDate;
        if (_returnDate != null && _returnDate!.isBefore(_timeStart!)) {
          _returnDate = _timeStart;
        }
      });
    }
  }

  void _pickReturnDate() async {
    final DateTime initialDate = _returnDate ?? _timeStart ?? DateTime.now();
    final DateTime firstDateForReturn = _timeStart ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(firstDateForReturn.year, firstDateForReturn.month, firstDateForReturn.day),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null && pickedDate != _returnDate) {
      setState(() {
        _returnDate = pickedDate;
      });
    }
  }

  void _showSameStationErrorDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thông báo'),
        content: const Text('Không thể chọn trạm đi và trạm đến giống nhau.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              setState(() {
                _selectedDepartureStation = null;
                _selectedArrivalStation = null;
              });
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showSearchingLoader() {
    final BuildContext? currentContext = navigatorKey.currentContext;
    if (currentContext != null) {
      showDialog(
        context: currentContext,
        barrierDismissible: false,
        builder: (dialogContext) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Không có chuyến phù hợp, chúng tôi đang tìm chuyến xe gần nhất.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _hideSearchingLoader() {
    final BuildContext? currentContext = navigatorKey.currentContext;
    if (currentContext != null && Navigator.of(currentContext).canPop()) {
      Navigator.of(currentContext).pop();
    }
  }

  Future<void> _searchTrip() async {
    List<String> errors = [];

    if (_selectedFromLocationId == null) {
      errors.add('Vui lòng chọn tỉnh/thành phố xuất phát.');
    }
    if (_selectedToLocationId == null) {
      errors.add('Vui lòng chọn tỉnh/thành phố đích đến.');
    }
    if (_selectedDepartureStation == null) {
      errors.add('Vui lòng chọn điểm đón.');
    }
    if (_selectedArrivalStation == null) {
      errors.add('Vui lòng chọn điểm trả.');
    }
    if (_timeStart == null) {
      errors.add('Vui lòng chọn ngày đi.');
    }
    if (errors.isNotEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Thông báo'),
            content: Text(errors.join('\n')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (_selectedDepartureStation!.id == _selectedArrivalStation!.id) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Thông báo'),
            content: const Text('Không thể chọn trạm đi và trạm đến giống nhau. Vui lòng chọn lại !!!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasSearched = true;
      });
    }

    try {
      final fullResults = await TripServices.searchTrips(
        fromLocationId: _selectedFromLocationId!,
        fromStationId: _selectedDepartureStation!.id,
        toLocationId: _selectedToLocationId!,
        toStationId: _selectedArrivalStation!.id,
        date: _timeStart!,
      );

      if (fullResults.isNotEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
          context.push(
            '/customer/search-result',
            extra: fullResults,
          );
        }
        return;
      }

      _showSearchingLoader();
      final looseResults = await TripServices.searchTripsLoose(
        fromLocationId: _selectedFromLocationId!,
        toLocationId: _selectedToLocationId!,
        date: _timeStart!,
      );

      await Future.delayed(const Duration(milliseconds: 100));
      _hideSearchingLoader();

      if (looseResults.isNotEmpty) {
        if (mounted) {
          context.push(
            '/customer/search-result-hint',
            extra: looseResults,
          );
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Thông báo'),
              content: const Text('Không có chuyến nào phù hợp.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('Lỗi khi tìm chuyến: $e');
      if (mounted) {
        _hideSearchingLoader();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tìm chuyến. Vui lòng thử lại. Chi tiết: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sửa lỗi ở đây
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Đặt màu nền cho body
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent.shade100, // Đặt màu nền cho appbar
        title: const Text(
          'Tìm chuyến xe',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading && _allProvincesList.isEmpty && _allStationsList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    onPressed: (index) => setState(() {
                      _tripType = TripType.values[index];
                      if (_tripType == TripType.oneWay) {
                        _returnDate = null;
                      }
                    }),
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

            GenericDropdownSearch<Location>(
              labelText: 'Xuất phát (Tỉnh/Thành phố)',
              hintText: 'Chọn tỉnh/thành phố xuất phát',
              items: _allProvincesList,
              selectedItem: _allProvincesList.firstWhereOrNull(
                    (p) => p.name == _selectedFromProvinceName,
              ),
              itemAsString: (Location loc) => loc.name,
              onChanged: (Location? selectedLocation) {
                setState(() {
                  _selectedFromProvinceName = selectedLocation?.name;
                  _selectedFromLocationId = selectedLocation?.id;
                  _filterStationsByLocation(_selectedFromProvinceName, true);
                  // Xóa trạm đón/trả khi đổi tỉnh
                  _selectedDepartureStation = null;
                  _selectedArrivalStation = null;
                });
              },
              validator: (Location? value) {
                if (value == null) {
                  return 'Vui lòng chọn tỉnh/thành phố xuất phát';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            GenericDropdownSearch<Station>(
              labelText: 'Điểm đón',
              hintText: _selectedFromLocationId == null
                  ? 'Vui lòng chọn xuất phát (tỉnh) trước'
                  : _departureStations.isEmpty
                  ? 'Không có điểm đón'
                  : 'Chọn điểm đón',
              items: _departureStations,
              selectedItem: _selectedDepartureStation,
              itemAsString: (Station station) => station.name,
              onChanged: (Station? value) {
                setState(() {
                  _selectedDepartureStation = value;
                });
                if (value != null && value.id == _selectedArrivalStation?.id) {
                  _showSameStationErrorDialog();
                }
              },
              enabled: _selectedFromLocationId != null && _departureStations.isNotEmpty,
              validator: (Station? value) {
                if (_selectedFromLocationId != null && value == null && _departureStations.isNotEmpty) {
                  return 'Vui lòng chọn điểm đón';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            GenericDropdownSearch<Location>(
              labelText: 'Đích đến (Tỉnh/Thành phố)',
              hintText: 'Chọn tỉnh/thành phố đến',
              items: _allProvincesList,
              selectedItem: _allProvincesList.firstWhereOrNull(
                    (p) => p.name == _selectedToProvinceName,
              ),
              itemAsString: (Location loc) => loc.name,
              onChanged: (Location? selectedLocation) {
                setState(() {
                  _selectedToProvinceName = selectedLocation?.name;
                  _selectedToLocationId = selectedLocation?.id;
                  _filterStationsByLocation(_selectedToProvinceName, false);
                  // Xóa trạm đón/trả khi đổi tỉnh
                  _selectedDepartureStation = null;
                  _selectedArrivalStation = null;
                });
              },
              validator: (Location? value) {
                if (value == null) {
                  return 'Vui lòng chọn tỉnh/thành phố đích đến';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            GenericDropdownSearch<Station>(
              labelText: 'Điểm trả',
              hintText: _selectedToLocationId == null
                  ? 'Vui lòng chọn đích đến (tỉnh) trước'
                  : _arrivalStations.isEmpty
                  ? 'Không có điểm trả'
                  : 'Chọn điểm trả',
              items: _arrivalStations,
              selectedItem: _selectedArrivalStation,
              itemAsString: (Station station) => station.name,
              onChanged: (Station? value) {
                setState(() {
                  _selectedArrivalStation = value;
                });
                if (value != null && value.id == _selectedDepartureStation?.id) {
                  _showSameStationErrorDialog();
                }
              },
              enabled: _selectedToLocationId != null && _arrivalStations.isNotEmpty,
              validator: (Station? value) {
                if (_selectedToLocationId != null && value == null && _arrivalStations.isNotEmpty) {
                  return 'Vui lòng chọn điểm trả';
                }
                return null;
              },
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