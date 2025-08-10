import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/trip.dart';
import 'package:mobile/models/TransferTrip.dart';
import 'package:mobile/models/seat.dart';
import 'package:mobile/services/seat_service.dart';
import '../../../../models/BookingData.dart';
import '../../../../models/station.dart';
import '../booking/booking_screen.dart';
class SearchResultDetailScreen extends StatefulWidget {
  static const path = '/customer/search-result-detail';
  final dynamic tripOrTransferTrip;
  final Map<int, Station> stations;
  const SearchResultDetailScreen({Key? key, required this.tripOrTransferTrip, required this.stations}) : super(key: key);
  @override
  _SearchResultDetailScreenState createState() => _SearchResultDetailScreenState();
}
class _SearchResultDetailScreenState extends State<SearchResultDetailScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Seat> _directTripSeats = [];
  Seat? _selectedDirectSeat;
  List<Seat> _firstTripSeats = [];
  Seat? _selectedFirstTripSeat;
  List<Seat> _secondTripSeats = [];
  Seat? _selectedSecondTripSeat;
  int _transferTripStep = 0;

  @override
  void initState() {
    super.initState();
    _fetchSeatAvailability();
  }

  void _checkAndNotifyNoAvailableSeats(List<Seat> seats) {
    bool hasAvailableSeats = seats.any((seat) => seat.isAvailable);
    if (!hasAvailableSeats) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Thông báo'),
              content: const Text('Chuyến xe đã đầy. Vui lòng chọn chuyến khác!'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Đồng ý'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.pop();
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }
  Future<void> _fetchSeatAvailability() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (widget.tripOrTransferTrip is Trip) {
      final Trip directTrip = widget.tripOrTransferTrip as Trip;
      if (directTrip.id == null || directTrip.fromStationId == null || directTrip.toStationId == null) {
        setState(() {
          _errorMessage = 'Thiếu thông tin ID chuyến đi hoặc ID trạm để lấy ghế.';
          _isLoading = false;
        });
        print('ERROR: Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến trực tiếp. Trip ID: ${directTrip.id}, From Station ID: ${directTrip.fromStationId}, To Station ID: ${directTrip.toStationId}');
        return;
      }

      try {
        final seats = await SeatService.getSeatAvailability(
          tripId: directTrip.id!,
          fromStationId: directTrip.fromStationId!,
          toStationId: directTrip.toStationId!,
        );
        setState(() { _directTripSeats = seats; });
        _checkAndNotifyNoAvailableSeats(seats);
      } catch (e) {
        setState(() { _errorMessage = e.toString(); });
        print('ERROR: Lỗi khi lấy ghế chuyến trực tiếp: $e');
      } finally {
        setState(() { _isLoading = false; });
      }
    } else if (widget.tripOrTransferTrip is TransferTrip) {
      final TransferTrip transferTrip = widget.tripOrTransferTrip as TransferTrip;

      if (transferTrip.firstTrip.id == null || transferTrip.firstTrip.fromStationId == null || transferTrip.firstTrip.toStationId == null) {
        setState(() {
          _errorMessage = 'Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến đầu tiên của trung chuyển.';
          _isLoading = false;
        });
        print('ERROR: Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến đầu tiên của trung chuyển. Trip ID: ${transferTrip.firstTrip.id}, From Station ID: ${transferTrip.firstTrip.fromStationId}, To Station ID: ${transferTrip.firstTrip.toStationId}');
        return;
      }

      try {
        final seats = await SeatService.getSeatAvailability(
          tripId: transferTrip.firstTrip.id!,
          fromStationId: transferTrip.firstTrip.fromStationId!,
          toStationId: transferTrip.firstTrip.toStationId!,
        );
        setState(() {
          _firstTripSeats = seats;
          _transferTripStep = 0; });
        _checkAndNotifyNoAvailableSeats(seats); // Kiểm tra và thông báo cho chuyến đầu tiên
      } catch (e) {
        setState(() { _errorMessage = e.toString(); });
        print('ERROR: Lỗi khi lấy ghế chuyến đầu tiên của trung chuyển: $e');
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _fetchSecondTripSeatAvailability() async {
    final TransferTrip transferTrip = widget.tripOrTransferTrip as TransferTrip;
    if (transferTrip.secondTrip == null) {
      setState(() {
        _transferTripStep = 2;
        _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chuyến trung chuyển này chỉ có một chặng. Chuyển sang xác nhận.')),
      );
      return;
    }
    if (transferTrip.secondTrip!.id == null || transferTrip.secondTrip!.fromStationId == null || transferTrip.secondTrip!.toStationId == null) {
      setState(() {
        _errorMessage = 'Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến thứ hai của trung chuyển.';
        _isLoading = false;
      });
      print('ERROR: Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến thứ hai của trung chuyển. Trip ID: ${transferTrip.secondTrip!.id}, From Station ID: ${transferTrip.secondTrip!.fromStationId}, To Station ID: ${transferTrip.secondTrip!.toStationId}');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final seats = await SeatService.getSeatAvailability(
        tripId: transferTrip.secondTrip!.id!,
        fromStationId: transferTrip.secondTrip!.fromStationId!,
        toStationId: transferTrip.secondTrip!.toStationId!,
      );
      setState(() { _secondTripSeats = seats; _transferTripStep = 1; });
      _checkAndNotifyNoAvailableSeats(seats); // Kiểm tra và thông báo cho chuyến thứ hai
    } catch (e) {
      setState(() { _errorMessage = e.toString(); });
      print('ERROR: Lỗi khi lấy ghế chuyến thứ hai của trung chuyển: $e');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết và Chọn ghế'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('Lỗi tải thông tin ghế: $_errorMessage'))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (widget.tripOrTransferTrip is Trip) {
      final Trip directTrip = widget.tripOrTransferTrip as Trip;
      bool hasAvailableSeats = _directTripSeats.any((seat) => seat.isAvailable);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Chuyến đi trực tiếp', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            _buildTripDetails(directTrip),
            const SizedBox(height: 20),
            Text('Chọn ghế:', style: Theme.of(context).textTheme.titleLarge),
            _buildSeatLegend(),
            const SizedBox(height: 10),
            _buildSeatGrid(_directTripSeats, _selectedDirectSeat, (seat) {
              setState(() {
                _selectedDirectSeat = seat;
              });
            }),
            if (_selectedDirectSeat != null && hasAvailableSeats)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final bookingData = BookingData(
                          tripOrTransferTrip: directTrip,
                          selectedFirstSeat: _selectedDirectSeat,
                          stations: widget.stations,
                        );
                        context.push(BookingScreen.path, extra: bookingData);
                      },
                      child: const Text('Thanh toán'),
                    ),
                  ],
                ),
              ),
            if (!hasAvailableSeats)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Xin lỗi, tất cả ghế đã được đặt cho chuyến này.',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    } else if (widget.tripOrTransferTrip is TransferTrip) {
      final TransferTrip transferTrip = widget.tripOrTransferTrip as TransferTrip;
      bool hasAvailableFirstTripSeats = _firstTripSeats.any((seat) => seat.isAvailable);
      bool hasAvailableSecondTripSeats = transferTrip.secondTrip != null
          ? _secondTripSeats.any((seat) => seat.isAvailable)
          : false;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Chuyến đi trung chuyển', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),

            if (_transferTripStep == 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chuyến đi đầu tiên: ${transferTrip.firstTrip.tripId}', style: Theme.of(context).textTheme.titleLarge),
                  _buildTripDetails(transferTrip.firstTrip),
                  const SizedBox(height: 10),
                  Center( // Bọc Text bằng Center
                    child: Text('Vui lòng chọn ghế thứ nhất:', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  _buildSeatLegend(),
                  const SizedBox(height: 10),
                  _buildSeatGrid(_firstTripSeats, _selectedFirstTripSeat, (seat) {
                    setState(() {
                      _selectedFirstTripSeat = seat;
                    });
                  }),
                  if (_selectedFirstTripSeat != null && hasAvailableFirstTripSeats)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _fetchSecondTripSeatAvailability();
                            },
                            child: const Text('Tiếp tục'),
                          ),
                        ],
                      ),
                    ),
                  if (!hasAvailableFirstTripSeats)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        'Xin lỗi, tất cả ghế đã được đặt cho chặng đầu tiên.',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              )
            else if (_transferTripStep == 1 || _transferTripStep == 2)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ghế chuyến đầu tiên đã chọn: ${_selectedFirstTripSeat?.seatId ?? "Chưa chọn"}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                  const Divider(),
                  if (transferTrip.secondTrip != null) ...[
                    _buildTripDetails(transferTrip.secondTrip!),
                    const SizedBox(height: 10),
                    Center( // Bọc Text bằng Center
                      child: Text('Vui lòng chọn ghế thứ 2:', style: Theme.of(context).textTheme.titleMedium),
                    ),
                    _buildSeatLegend(),
                    const SizedBox(height: 10),
                    _buildSeatGrid(_secondTripSeats, _selectedSecondTripSeat, (seat) {
                      setState(() {
                        _selectedSecondTripSeat = seat;
                      });
                    }),
                    if (_selectedSecondTripSeat != null && hasAvailableSecondTripSeats)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                print('Xác nhận đặt ghế ${_selectedFirstTripSeat!.seatId} cho chuyến đầu tiên và ${_selectedSecondTripSeat!.seatId} cho chuyến thứ hai.');
                                // TODO: Logic chuyển sang thanh toán
                              },
                              child: const Text('Thanh toán'),
                            ),
                          ],
                        ),
                      ),
                    if (!hasAvailableSecondTripSeats)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          'Xin lỗi, tất cả ghế đã được đặt cho chặng thứ hai.',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ] else if (_transferTripStep == 2) ...[
                    const Text('Chuyến trung chuyển này chỉ có một chặng.', style: TextStyle(fontStyle: FontStyle.italic)),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              print('Xác nhận đặt ghế ${_selectedFirstTripSeat!.seatId} cho chuyến trung chuyển một chặng.');
                              // TODO: Thêm logic điều hướng hoặc đặt vé ở đây
                            },
                            child: const Text('Tiếp tục đặt vé cho chuyến trung chuyển'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      );
    }
    return const Center(child: Text('Không tìm thấy thông tin chuyến đi.'));
  }

  Widget _buildTripDetails(Trip trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mã chuyến: ${trip.tripId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('Từ: ${trip.fromLocation} ', style: const TextStyle(fontSize: 16)), const SizedBox(height: 5),
        Text('Đến: ${trip.endLocation}', style: const TextStyle(fontSize: 16)), const SizedBox(height: 5),
        Text('Giờ đi: ${DateFormat('HH:mm').format(trip.timeStart)} - Giờ đến: ${DateFormat('HH:mm').format(trip.timeEnd)}', style: const TextStyle(fontSize: 16)), const SizedBox(height: 5),
        Text('Xe: ${trip.busName}', style: const TextStyle(fontSize: 16)), const SizedBox(height: 5),
        Text('Giá: ${NumberFormat('#,###').format(trip.price ?? 0)} VND', style: const TextStyle(fontSize: 18, color: Colors.red)), const SizedBox(height: 5),
        if (trip.routeDescription != null && trip.routeDescription!.isNotEmpty)
          Text('Lộ trình: ${trip.routeDescription}', style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  //
  Widget _buildSeatGrid(List<Seat> seats, Seat? selectedSeat, ValueChanged<Seat> onSeatSelected) {
    if (seats.isEmpty) {
      return const Text('Không có thông tin ghế trống cho chuyến này.');
    }
    int totalSeats = seats.length;
    int crossAxisCount;
    String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    if (totalSeats <= 16) {
      crossAxisCount = 4;
    } else if (totalSeats <= 25) {
      crossAxisCount = 5;
    } else if (totalSeats <= 35) {
      crossAxisCount = 5;
    } else {
      crossAxisCount = 5;
    }

    String getSeatName(int index) {
      int row = (index / crossAxisCount).floor();
      int colIndex = index % crossAxisCount;

      String colChar = alphabet[colIndex];
      return '$colChar${row + 1}';
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.9, // Tỷ lệ ô ghế
      ),
      itemCount: totalSeats,
      itemBuilder: (context, index) {
        final seat = seats[index];
        bool isSelected = seat.id == selectedSeat?.id;
        final seatName = getSeatName(index);

        return GestureDetector(
          onTap: () {
            if (seat.isAvailable) {
              onSeatSelected(seat);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ghế $seatName đã có người!')),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: seat.isAvailable
                  ? (isSelected ? Colors.blue.shade300 : Colors.green.shade100)
                  : Colors.red.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: seat.isAvailable
                    ? (isSelected ? Colors.blue.shade700 : Colors.green)
                    : Colors.red,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_seat,
                  size: 18,
                  color: seat.isAvailable
                      ? (isSelected ? Colors.white : Colors.green.shade900)
                      : Colors.red.shade900,
                ),
                const SizedBox(height: 2),
                Text(
                  seatName, // Sử dụng tên ghế đã được định dạng
                  style: TextStyle(
                    color: seat.isAvailable
                        ? (isSelected ? Colors.white : Colors.green.shade900)
                        : Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeatLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(Colors.green.shade100, Colors.green, 'Ghế trống'),
          _buildLegendItem(Colors.blue.shade300, Colors.blue.shade700, 'Chờ thanh toán'),
          _buildLegendItem(Colors.red.shade100, Colors.red, 'Ghế đã đặt'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color bgColor, Color borderColor, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 15,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}