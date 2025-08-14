// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:mobile/models/trip.dart';
// import 'package:mobile/models/TransferTrip.dart';
// import 'package:mobile/models/seat.dart';
// import 'package:mobile/services/seat_service.dart';
// import '../../../../models/BookingData.dart';
// import '../../../../models/station.dart';
// import '../booking/booking_screen.dart';
//
// class SearchResultDetailScreen extends StatefulWidget {
//   static const path = '/customer/search-result-detail';
//   final dynamic tripOrTransferTrip; // đi
//   final dynamic returnTripOrTransferTrip; // về (khứ hồi)
//   final bool isRoundTrip;
//   final Map<int, Station> stations;
//   const SearchResultDetailScreen({
//     Key? key,
//     required this.tripOrTransferTrip,
//     this.returnTripOrTransferTrip,
//     required this.isRoundTrip,
//     required this.stations,
//   }) : super(key: key);
//   @override
//   _SearchResultDetailScreenState createState() => _SearchResultDetailScreenState();
// }
//
// class _SearchResultDetailScreenState extends State<SearchResultDetailScreen> {
//   bool _isLoading = false;
//   String? _errorMessage;
//   List<Seat> _directTripSeats = [];
//   Seat? _selectedDirectSeat;
//   List<Seat> _firstTripSeats = [];
//   Seat? _selectedFirstTripSeat;
//   List<Seat> _secondTripSeats = [];
//   Seat? _selectedSecondTripSeat;
//   // int _transferTripStep = 0; // no longer used in non-steps UI
//
//   // Khứ hồi - phần về
//   List<Seat> _returnDirectSeats = [];
//   Seat? _selectedReturnDirectSeat;
//   List<Seat> _returnFirstSeats = [];
//   Seat? _selectedReturnFirstSeat;
//   List<Seat> _returnSecondSeats = [];
//   Seat? _selectedReturnSecondSeat;
//   int _returnTransferStep = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchSeatAvailability();
//     if (widget.isRoundTrip && widget.returnTripOrTransferTrip != null) {
//       _fetchReturnSeatAvailability();
//     }
//   }
//
//   bool _isDepartureSelectionComplete() {
//     if (widget.tripOrTransferTrip is Trip) {
//       return _selectedDirectSeat != null;
//     }
//     if (widget.tripOrTransferTrip is TransferTrip) {
//       final TransferTrip t = widget.tripOrTransferTrip as TransferTrip;
//       if (t.secondTrip == null) return _selectedFirstTripSeat != null;
//       return _selectedFirstTripSeat != null && _selectedSecondTripSeat != null;
//     }
//     return false;
//   }
//
//   bool _isReturnSelectionComplete() {
//     if (!widget.isRoundTrip || widget.returnTripOrTransferTrip == null) return true;
//     final dynamic r = widget.returnTripOrTransferTrip;
//     if (r is Trip) {
//       return _selectedReturnDirectSeat != null;
//     }
//     if (r is TransferTrip) {
//       if (r.secondTrip == null) return _selectedReturnFirstSeat != null;
//       return _selectedReturnFirstSeat != null && _selectedReturnSecondSeat != null;
//     }
//     return false;
//   }
//
//   Widget _buildBottomPayBar() {
//     final canPay = _isDepartureSelectionComplete() && _isReturnSelectionComplete();
//     return Align(
//       alignment: Alignment.centerRight,
//       child: ElevatedButton(
//         onPressed: canPay
//             ? () {
//                 final Map<int, Station> stationsToSend = widget.stations.isNotEmpty ? widget.stations : _buildStationsFallback();
//                 if (!widget.isRoundTrip) {
//                   if (widget.tripOrTransferTrip is Trip && _selectedDirectSeat != null) {
//                     final bookingData = BookingData(
//                       tripOrTransferTrip: widget.tripOrTransferTrip,
//                       selectedFirstSeat: _selectedDirectSeat,
//                       isRoundTrip: false,
//                       stations: stationsToSend,
//                     );
//                     context.push(BookingScreen.path, extra: bookingData);
//                   } else if (widget.tripOrTransferTrip is TransferTrip) {
//                     final bookingData = BookingData(
//                       tripOrTransferTrip: widget.tripOrTransferTrip,
//                       selectedFirstSeat: _selectedFirstTripSeat,
//                       selectedSecondSeat: _selectedSecondTripSeat,
//                       isRoundTrip: false,
//                       stations: stationsToSend,
//                     );
//                     context.push(BookingScreen.path, extra: bookingData);
//                   }
//                 } else {
//                   // Khứ hồi: đóng gói cả đi + về
//                   final bookingData = BookingData(
//                     tripOrTransferTrip: widget.tripOrTransferTrip,
//                     selectedFirstSeat: widget.tripOrTransferTrip is Trip ? _selectedDirectSeat : _selectedFirstTripSeat,
//                     selectedSecondSeat: widget.tripOrTransferTrip is TransferTrip ? _selectedSecondTripSeat : null,
//                     returnTripOrTransferTrip: widget.returnTripOrTransferTrip,
//                     returnSelectedFirstSeat: widget.returnTripOrTransferTrip is Trip ? _selectedReturnDirectSeat : _selectedReturnFirstSeat,
//                     returnSelectedSecondSeat: widget.returnTripOrTransferTrip is TransferTrip ? _selectedReturnSecondSeat : null,
//                     isRoundTrip: true,
//                     stations: stationsToSend,
//                   );
//                   context.push(BookingScreen.path, extra: bookingData);
//                 }
//               }
//             : null,
//         child: Text(canPay ? 'Thanh toán' : 'Chọn ghế đi và về để thanh toán'),
//       ),
//     );
//   }
//
//   Map<int, Station> _buildStationsFallback() {
//     final Map<int, Station> map = {};
//     void addTripStations(Trip trip) {
//       if (trip.fromStationId != null) {
//         map[trip.fromStationId!] = Station(
//           id: trip.fromStationId!,
//           stationId: trip.fromStationId!.toString(),
//           name: trip.fromLocation,
//           locationName: '',
//         );
//       }
//       if (trip.toStationId != null) {
//         map[trip.toStationId!] = Station(id: trip.toStationId!, stationId: trip.toStationId!.toString(), name: trip.endLocation, locationName: '');
//       }
//     }
//
//     // Outbound
//     if (widget.tripOrTransferTrip is Trip) {
//       addTripStations(widget.tripOrTransferTrip as Trip);
//     } else if (widget.tripOrTransferTrip is TransferTrip) {
//       final t = widget.tripOrTransferTrip as TransferTrip;
//       addTripStations(t.firstTrip);
//       if (t.secondTrip != null) addTripStations(t.secondTrip!);
//     }
//
//     // Inbound (round trip)
//     if (widget.isRoundTrip && widget.returnTripOrTransferTrip != null) {
//       final r = widget.returnTripOrTransferTrip;
//       if (r is Trip) {
//         addTripStations(r);
//       } else if (r is TransferTrip) {
//         addTripStations(r.firstTrip);
//         if (r.secondTrip != null) addTripStations(r.secondTrip!);
//       }
//     }
//     return map;
//   }
//
//   void _checkAndNotifyNoAvailableSeats(List<Seat> seats) {
//     bool hasAvailableSeats = seats.any((seat) => seat.isAvailable);
//     if (!hasAvailableSeats) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext dialogContext) {
//             return AlertDialog(
//               title: const Text('Thông báo'),
//               content: const Text('Chuyến xe đã đầy. Vui lòng chọn chuyến khác!'),
//               actions: <Widget>[
//                 TextButton(
//                   child: const Text('Đồng ý'),
//                   onPressed: () {
//                     Navigator.of(dialogContext).pop();
//                     context.pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       });
//     }
//   }
//
//   Future<void> _fetchSeatAvailability() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     if (widget.tripOrTransferTrip is Trip) {
//       final Trip directTrip = widget.tripOrTransferTrip as Trip;
//       if (directTrip.fromStationId == null || directTrip.toStationId == null) {
//         setState(() {
//           _errorMessage = 'Thiếu thông tin ID chuyến đi hoặc ID trạm để lấy ghế.';
//           _isLoading = false;
//         });
//         print(
//           'ERROR: Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến trực tiếp. Trip ID: ${directTrip.id}, From Station ID: ${directTrip.fromStationId}, To Station ID: ${directTrip.toStationId}',
//         );
//         return;
//       }
//
//       try {
//         final seats = await SeatService.getSeatAvailability(
//           tripId: directTrip.id,
//           fromStationId: directTrip.fromStationId!,
//           toStationId: directTrip.toStationId!,
//         );
//         setState(() {
//           _directTripSeats = seats;
//         });
//         _checkAndNotifyNoAvailableSeats(seats);
//       } catch (e) {
//         setState(() {
//           _errorMessage = e.toString();
//         });
//         print('ERROR: Lỗi khi lấy ghế chuyến trực tiếp: $e');
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } else if (widget.tripOrTransferTrip is TransferTrip) {
//       final TransferTrip transferTrip = widget.tripOrTransferTrip as TransferTrip;
//
//       if (transferTrip.firstTrip.fromStationId == null || transferTrip.firstTrip.toStationId == null) {
//         setState(() {
//           _errorMessage = 'Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến đầu tiên của trung chuyển.';
//           _isLoading = false;
//         });
//         print(
//           'ERROR: Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến đầu tiên của trung chuyển. Trip ID: ${transferTrip.firstTrip.id}, From Station ID: ${transferTrip.firstTrip.fromStationId}, To Station ID: ${transferTrip.firstTrip.toStationId}',
//         );
//         return;
//       }
//
//       try {
//         final seats = await SeatService.getSeatAvailability(
//           tripId: transferTrip.firstTrip.id,
//           fromStationId: transferTrip.firstTrip.fromStationId!,
//           toStationId: transferTrip.firstTrip.toStationId!,
//         );
//         setState(() {
//           _firstTripSeats = seats;
//         });
//         _checkAndNotifyNoAvailableSeats(seats); // Kiểm tra và thông báo cho chuyến đầu tiên
//         // Tải luôn ghế chặng 2 (nếu có) để hiển thị đồng thời
//         if (transferTrip.secondTrip != null) {
//           // Không cần chờ, để UI hiển thị dần
//           _fetchSecondTripSeatAvailability();
//         }
//       } catch (e) {
//         setState(() {
//           _errorMessage = e.toString();
//         });
//         print('ERROR: Lỗi khi lấy ghế chuyến đầu tiên của trung chuyển: $e');
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//
//     // Nếu khứ hồi và có chuyến về, load trước ghế "đi" xong sẽ load "về" (nếu cần)
//     if (widget.isRoundTrip && widget.returnTripOrTransferTrip != null) {
//       // Tùy yêu cầu UX có thể lazy-load phần về sau, tạm thời chưa tự động gọi để giữ trải nghiệm mượt
//     }
//   }
//
//   Future<void> _fetchSecondTripSeatAvailability() async {
//     final TransferTrip transferTrip = widget.tripOrTransferTrip as TransferTrip;
//     if (transferTrip.secondTrip == null) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chuyến trung chuyển này chỉ có một chặng. Chuyển sang xác nhận.')));
//       return;
//     }
//     if (transferTrip.secondTrip!.fromStationId == null || transferTrip.secondTrip!.toStationId == null) {
//       setState(() {
//         _errorMessage = 'Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến thứ hai của trung chuyển.';
//         _isLoading = false;
//       });
//       print(
//         'ERROR: Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến thứ hai của trung chuyển. Trip ID: ${transferTrip.secondTrip!.id}, From Station ID: ${transferTrip.secondTrip!.fromStationId}, To Station ID: ${transferTrip.secondTrip!.toStationId}',
//       );
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       final seats = await SeatService.getSeatAvailability(
//         tripId: transferTrip.secondTrip!.id,
//         fromStationId: transferTrip.secondTrip!.fromStationId!,
//         toStationId: transferTrip.secondTrip!.toStationId!,
//       );
//       setState(() {
//         _secondTripSeats = seats;
//       });
//       _checkAndNotifyNoAvailableSeats(seats); // Kiểm tra và thông báo cho chuyến thứ hai
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//       });
//       print('ERROR: Lỗi khi lấy ghế chuyến thứ hai của trung chuyển: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Chi tiết và Chọn ghế')),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//           ? Center(child: Text('Lỗi tải thông tin ghế: $_errorMessage'))
//           : _buildContent(),
//     );
//   }
//
//   Widget _buildContent() {
//     if (widget.tripOrTransferTrip is Trip) {
//       final Trip directTrip = widget.tripOrTransferTrip as Trip;
//       bool hasAvailableSeats = _directTripSeats.any((seat) => seat.isAvailable);
//       final Map<int, Station> stationsToSend = widget.stations.isNotEmpty ? widget.stations : _buildStationsFallback();
//
//       return SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Chuyến đi trực tiếp', style: Theme.of(context).textTheme.headlineSmall),
//             const SizedBox(height: 10),
//             _buildTripDetails(directTrip),
//             const SizedBox(height: 20),
//             Text('Chọn ghế:', style: Theme.of(context).textTheme.titleLarge),
//             _buildSeatLegend(),
//             const SizedBox(height: 10),
//             _buildSeatGrid(_directTripSeats, _selectedDirectSeat, (seat) {
//               setState(() {
//                 _selectedDirectSeat = seat;
//               });
//             }),
//             if (_selectedDirectSeat != null && hasAvailableSeats)
//               Padding(
//                 padding: const EdgeInsets.only(top: 20.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     if (!widget.isRoundTrip)
//                       ElevatedButton(
//                         onPressed: () {
//                           final bookingData = BookingData(
//                             tripOrTransferTrip: directTrip,
//                             selectedFirstSeat: _selectedDirectSeat,
//                             stations: stationsToSend,
//                           );
//                           context.push(BookingScreen.path, extra: bookingData);
//                         },
//                         child: const Text('Thanh toán'),
//                       )
//                     else
//                       Expanded(child: const Text('Đã chọn ghế chuyến đi. Vui lòng chọn ghế cho chuyến về bên dưới.')),
//                   ],
//                 ),
//               ),
//             if (!hasAvailableSeats)
//               Padding(
//                 padding: const EdgeInsets.only(top: 20.0),
//                 child: Text(
//                   'Xin lỗi, tất cả ghế đã được đặt cho chuyến này.',
//                   style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             if (widget.isRoundTrip && widget.returnTripOrTransferTrip != null) ...[
//               const SizedBox(height: 24),
//               const Divider(),
//               const SizedBox(height: 8),
//               _buildReturnContent(widget.returnTripOrTransferTrip),
//               const SizedBox(height: 16),
//               _buildBottomPayBar(),
//             ],
//           ],
//         ),
//       );
//     } else if (widget.tripOrTransferTrip is TransferTrip) {
//       final TransferTrip transferTrip = widget.tripOrTransferTrip as TransferTrip;
//
//       return SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Chuyến đi trung chuyển', style: Theme.of(context).textTheme.headlineSmall),
//             const SizedBox(height: 10),
//
//             // Hiển thị đồng thời hai chặng (nếu có)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Vui lòng chọn ghế chuyến đi', style: Theme.of(context).textTheme.titleLarge),
//                 const SizedBox(height: 10),
//                 Text('Chặng 1', style: Theme.of(context).textTheme.titleMedium),
//                 _buildTripDetails(transferTrip.firstTrip),
//                 const SizedBox(height: 8),
//                 _buildSeatLegend(),
//                 const SizedBox(height: 8),
//                 _buildSeatGrid(_firstTripSeats, _selectedFirstTripSeat, (seat) {
//                   setState(() {
//                     _selectedFirstTripSeat = seat;
//                   });
//                 }),
//                 if (transferTrip.secondTrip != null) ...[
//                   const SizedBox(height: 16),
//                   Text('Chặng 2', style: Theme.of(context).textTheme.titleMedium),
//                   _buildTripDetails(transferTrip.secondTrip!),
//                   const SizedBox(height: 8),
//                   _buildSeatLegend(),
//                   const SizedBox(height: 8),
//                   _buildSeatGrid(_secondTripSeats, _selectedSecondTripSeat, (seat) {
//                     setState(() {
//                       _selectedSecondTripSeat = seat;
//                     });
//                   }),
//                 ],
//               ],
//             ),
//             if (widget.isRoundTrip && widget.returnTripOrTransferTrip != null) ...[
//               const SizedBox(height: 24),
//               const Divider(),
//               const SizedBox(height: 8),
//               _buildReturnContent(widget.returnTripOrTransferTrip),
//               const SizedBox(height: 16),
//               _buildBottomPayBar(),
//             ],
//           ],
//         ),
//       );
//     }
//     return const Center(child: Text('Không tìm thấy thông tin chuyến đi.'));
//   }
//
//   // Tải ghế CHUYẾN VỀ + UI hiển thị ngay bên dưới (flow mới)
//   Future<void> _fetchReturnSeatAvailability() async {
//     if (!widget.isRoundTrip || widget.returnTripOrTransferTrip == null) return;
//     final dynamic returnTrip = widget.returnTripOrTransferTrip;
//     try {
//       if (returnTrip is Trip) {
//         if (returnTrip.fromStationId == null || returnTrip.toStationId == null) return;
//         final seats = await SeatService.getSeatAvailability(
//           tripId: returnTrip.id,
//           fromStationId: returnTrip.fromStationId!,
//           toStationId: returnTrip.toStationId!,
//         );
//         setState(() {
//           _returnDirectSeats = seats;
//         });
//         _checkAndNotifyNoAvailableSeats(seats);
//       } else if (returnTrip is TransferTrip) {
//         if (returnTrip.firstTrip.fromStationId == null || returnTrip.firstTrip.toStationId == null) return;
//         final seats = await SeatService.getSeatAvailability(
//           tripId: returnTrip.firstTrip.id,
//           fromStationId: returnTrip.firstTrip.fromStationId!,
//           toStationId: returnTrip.firstTrip.toStationId!,
//         );
//         setState(() {
//           _returnFirstSeats = seats;
//           _returnTransferStep = 0;
//         });
//         _checkAndNotifyNoAvailableSeats(seats);
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//       });
//     }
//   }
//
//   // Removed unused _fetchReturnSecondTripSeatAvailability to satisfy linter; loading for second leg can be added when needed.
//
//   Widget _buildReturnContent(dynamic returnTrip) {
//     if (returnTrip is Trip) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Chuyến về', style: Theme.of(context).textTheme.headlineSmall),
//           const SizedBox(height: 10),
//           _buildTripDetails(returnTrip),
//           const SizedBox(height: 10),
//           Text('Vui lòng chọn ghế chuyến về', style: Theme.of(context).textTheme.titleLarge),
//           _buildSeatLegend(),
//           const SizedBox(height: 10),
//           _buildSeatGrid(_returnDirectSeats, _selectedReturnDirectSeat, (seat) {
//             setState(() {
//               _selectedReturnDirectSeat = seat;
//             });
//           }),
//           const SizedBox(height: 10),
//         ],
//       );
//     } else if (returnTrip is TransferTrip) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Chuyến về (Trung chuyển)', style: Theme.of(context).textTheme.headlineSmall),
//           const SizedBox(height: 10),
//           if (_returnTransferStep == 0) ...[
//             _buildTripDetails(returnTrip.firstTrip),
//             const SizedBox(height: 10),
//             Text('Vui lòng chọn ghế chuyến về', style: Theme.of(context).textTheme.titleLarge),
//             _buildSeatLegend(),
//             const SizedBox(height: 10),
//             _buildSeatGrid(_returnFirstSeats, _selectedReturnFirstSeat, (seat) {
//               setState(() {
//                 _selectedReturnFirstSeat = seat;
//               });
//             }),
//             const SizedBox(height: 10),
//           ] else ...[
//             if (returnTrip.secondTrip != null) ...[
//               _buildTripDetails(returnTrip.secondTrip!),
//               const SizedBox(height: 10),
//               Text('Chọn ghế chặng 2:', style: Theme.of(context).textTheme.titleLarge),
//               _buildSeatLegend(),
//               const SizedBox(height: 10),
//               _buildSeatGrid(_returnSecondSeats, _selectedReturnSecondSeat, (seat) {
//                 setState(() {
//                   _selectedReturnSecondSeat = seat;
//                 });
//               }),
//             ],
//             const SizedBox(height: 10),
//           ],
//         ],
//       );
//     }
//
//     return const Text('Dữ liệu chuyến về không hợp lệ.');
//   }
//
//   Widget _buildTripDetails(Trip trip) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Mã chuyến: ${trip.tripId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         Text('Từ: ${trip.fromLocation} ', style: const TextStyle(fontSize: 16)),
//         const SizedBox(height: 5),
//         Text('Đến: ${trip.endLocation}', style: const TextStyle(fontSize: 16)),
//         const SizedBox(height: 5),
//         Text(
//           'Giờ đi: ${DateFormat('HH:mm').format(trip.timeStart)} - Giờ đến: ${DateFormat('HH:mm').format(trip.timeEnd)}',
//           style: const TextStyle(fontSize: 16),
//         ),
//         const SizedBox(height: 5),
//         Text('Xe: ${trip.busName}', style: const TextStyle(fontSize: 16)),
//         const SizedBox(height: 5),
//         Text('Giá: ${NumberFormat('#,###').format(trip.price)} VND', style: const TextStyle(fontSize: 18, color: Colors.red)),
//         const SizedBox(height: 5),
//         if (trip.routeDescription != null && trip.routeDescription!.isNotEmpty)
//           Text('Lộ trình: ${trip.routeDescription}', style: const TextStyle(fontSize: 18)),
//       ],
//     );
//   }
//
//   //
//   Widget _buildSeatGrid(List<Seat> seats, Seat? selectedSeat, ValueChanged<Seat> onSeatSelected) {
//     if (seats.isEmpty) {
//       return const Text('Không có thông tin ghế trống cho chuyến này.');
//     }
//     int totalSeats = seats.length;
//     int crossAxisCount;
//     String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
//
//     if (totalSeats <= 16) {
//       crossAxisCount = 4;
//     } else if (totalSeats <= 25) {
//       crossAxisCount = 5;
//     } else if (totalSeats <= 35) {
//       crossAxisCount = 5;
//     } else {
//       crossAxisCount = 5;
//     }
//
//     String getSeatName(int index) {
//       int row = (index / crossAxisCount).floor();
//       int colIndex = index % crossAxisCount;
//
//       String colChar = alphabet[colIndex];
//       return '$colChar${row + 1}';
//     }
//
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         crossAxisSpacing: 4,
//         mainAxisSpacing: 4,
//         childAspectRatio: 0.9, // Tỷ lệ ô ghế
//       ),
//       itemCount: totalSeats,
//       itemBuilder: (context, index) {
//         final seat = seats[index];
//         bool isSelected = seat.id == selectedSeat?.id;
//         final seatName = getSeatName(index);
//
//         return GestureDetector(
//           onTap: () {
//             if (seat.isAvailable) {
//               onSeatSelected(seat);
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ghế $seatName đã có người!')));
//             }
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: seat.isAvailable ? (isSelected ? Colors.blue.shade300 : Colors.green.shade100) : Colors.red.shade100,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(8),
//                 topRight: Radius.circular(8),
//                 bottomLeft: Radius.circular(16),
//                 bottomRight: Radius.circular(16),
//               ),
//               border: Border.all(color: seat.isAvailable ? (isSelected ? Colors.blue.shade700 : Colors.green) : Colors.red, width: 1),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.event_seat, size: 18, color: seat.isAvailable ? (isSelected ? Colors.white : Colors.green.shade900) : Colors.red.shade900),
//                 const SizedBox(height: 2),
//                 Text(
//                   seatName, // Sử dụng tên ghế đã được định dạng
//                   style: TextStyle(
//                     color: seat.isAvailable ? (isSelected ? Colors.white : Colors.green.shade900) : Colors.red.shade900,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 10,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSeatLegend() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildLegendItem(Colors.green.shade100, Colors.green, 'Ghế trống'),
//           _buildLegendItem(Colors.blue.shade300, Colors.blue.shade700, 'Chờ thanh toán'),
//           _buildLegendItem(Colors.red.shade100, Colors.red, 'Ghế đã đặt'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLegendItem(Color bgColor, Color borderColor, String text) {
//     return Row(
//       children: [
//         Container(
//           width: 20,
//           height: 15,
//           decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: BorderRadius.circular(4),
//             border: Border.all(color: borderColor, width: 1),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(text, style: const TextStyle(fontSize: 14)),
//       ],
//     );
//   }
// }
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
  final dynamic tripOrTransferTrip; // đi
  final dynamic returnTripOrTransferTrip; // về (khứ hồi)
  final bool isRoundTrip;
  final Map<int, Station> stations;
  const SearchResultDetailScreen({
    Key? key,
    required this.tripOrTransferTrip,
    this.returnTripOrTransferTrip,
    required this.isRoundTrip,
    required this.stations,
  }) : super(key: key);
  @override
  _SearchResultDetailScreenState createState() => _SearchResultDetailScreenState();
}

class _SearchResultDetailScreenState extends State<SearchResultDetailScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Seat> _directTripSeats = [];
  List<Seat> _selectedDirectSeats = [];
  List<Seat> _firstTripSeats = [];
  List<Seat> _selectedFirstTripSeats = [];
  List<Seat> _secondTripSeats = [];
  List<Seat> _selectedSecondTripSeats = [];
  // int _transferTripStep = 0; // no longer used in non-steps UI

  // Khứ hồi - phần về
  List<Seat> _returnDirectSeats = [];
  List<Seat> _selectedReturnDirectSeats = [];
  List<Seat> _returnFirstSeats = [];
  List<Seat> _selectedReturnFirstSeats = [];
  List<Seat> _returnSecondSeats = [];
  List<Seat> _selectedReturnSecondSeats = [];

  @override
  void initState() {
    super.initState();
    _fetchSeatAvailability();
    if (widget.isRoundTrip && widget.returnTripOrTransferTrip != null) {
      _fetchReturnSeatAvailability();
    }
  }

  bool _isDepartureSelectionComplete() {
    if (widget.tripOrTransferTrip is Trip) {
      return _selectedDirectSeats.isNotEmpty;
    }
    if (widget.tripOrTransferTrip is TransferTrip) {
      final TransferTrip t = widget.tripOrTransferTrip as TransferTrip;
      if (t.secondTrip == null) return _selectedFirstTripSeats.isNotEmpty;
      return _selectedFirstTripSeats.isNotEmpty && _selectedSecondTripSeats.isNotEmpty;
    }
    return false;
  }

  bool _isReturnSelectionComplete() {
    if (!widget.isRoundTrip || widget.returnTripOrTransferTrip == null) return true;
    final dynamic r = widget.returnTripOrTransferTrip;
    if (r is Trip) {
      return _selectedReturnDirectSeats.isNotEmpty;
    }
    if (r is TransferTrip) {
      if (r.secondTrip == null) return _selectedReturnFirstSeats.isNotEmpty;
      return _selectedReturnFirstSeats.isNotEmpty && _selectedReturnSecondSeats.isNotEmpty;
    }
    return false;
  }

  Widget _buildBottomPayBar() {
    final canPay = _isDepartureSelectionComplete() && _isReturnSelectionComplete();
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: canPay
            ? () {
          final Map<int, Station> stationsToSend = widget.stations.isNotEmpty ? widget.stations : _buildStationsFallback();
          if (!widget.isRoundTrip) {
            if (widget.tripOrTransferTrip is Trip && _selectedDirectSeats.isNotEmpty) {
              final bookingData = BookingData(
                tripOrTransferTrip: widget.tripOrTransferTrip,
                selectedFirstSeats: _selectedDirectSeats,
                isRoundTrip: false,
                stations: stationsToSend,
              );
              context.push(BookingScreen.path, extra: bookingData);
            } else if (widget.tripOrTransferTrip is TransferTrip) {
              final bookingData = BookingData(
                tripOrTransferTrip: widget.tripOrTransferTrip,
                selectedFirstSeats: _selectedFirstTripSeats,
                selectedSecondSeats: _selectedSecondTripSeats,
                isRoundTrip: false,
                stations: stationsToSend,
              );
              context.push(BookingScreen.path, extra: bookingData);
            }
          } else {
            // Khứ hồi: đóng gói cả đi + về
            final bookingData = BookingData(
              tripOrTransferTrip: widget.tripOrTransferTrip,
              selectedFirstSeats: widget.tripOrTransferTrip is Trip ? _selectedDirectSeats : _selectedFirstTripSeats,
              selectedSecondSeats: widget.tripOrTransferTrip is TransferTrip ? _selectedSecondTripSeats : [],
              returnTripOrTransferTrip: widget.returnTripOrTransferTrip,
              returnSelectedFirstSeats: widget.returnTripOrTransferTrip is Trip ? _selectedReturnDirectSeats : _selectedReturnFirstSeats,
              returnSelectedSecondSeats: widget.returnTripOrTransferTrip is TransferTrip ? _selectedReturnSecondSeats : [],
              isRoundTrip: true,
              stations: stationsToSend,
            );
            context.push(BookingScreen.path, extra: bookingData);
          }
        }
            : null,
        child: Text(canPay ? 'Thanh toán' : 'Chọn ghế đi và về để thanh toán'),
      ),
    );
  }

  Map<int, Station> _buildStationsFallback() {
    final Map<int, Station> map = {};
    void addTripStations(Trip trip) {
      if (trip.fromStationId != null) {
        map[trip.fromStationId!] = Station(
          id: trip.fromStationId!,
          stationId: trip.fromStationId!.toString(),
          name: trip.fromLocation,
          locationName: '',
        );
      }
      if (trip.toStationId != null) {
        map[trip.toStationId!] = Station(id: trip.toStationId!, stationId: trip.toStationId!.toString(), name: trip.endLocation, locationName: '');
      }
    }

    // Outbound
    if (widget.tripOrTransferTrip is Trip) {
      addTripStations(widget.tripOrTransferTrip as Trip);
    } else if (widget.tripOrTransferTrip is TransferTrip) {
      final t = widget.tripOrTransferTrip as TransferTrip;
      addTripStations(t.firstTrip);
      if (t.secondTrip != null) addTripStations(t.secondTrip!);
    }

    // Inbound (round trip)
    if (widget.isRoundTrip && widget.returnTripOrTransferTrip != null) {
      final r = widget.returnTripOrTransferTrip;
      if (r is Trip) {
        addTripStations(r);
      } else if (r is TransferTrip) {
        addTripStations(r.firstTrip);
        if (r.secondTrip != null) addTripStations(r.secondTrip!);
      }
    }
    return map;
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
      if (directTrip.fromStationId == null || directTrip.toStationId == null) {
        setState(() {
          _errorMessage = 'Thiếu thông tin ID chuyến đi hoặc ID trạm để lấy ghế.';
          _isLoading = false;
        });
        print(
          'ERROR: Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến trực tiếp. Trip ID: ${directTrip.id}, From Station ID: ${directTrip.fromStationId}, To Station ID: ${directTrip.toStationId}',
        );
        return;
      }

      try {
        final seats = await SeatService.getSeatAvailability(
          tripId: directTrip.id,
          fromStationId: directTrip.fromStationId!,
          toStationId: directTrip.toStationId!,
        );
        setState(() {
          _directTripSeats = seats;
        });
        _checkAndNotifyNoAvailableSeats(seats);
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
        print('ERROR: Lỗi khi lấy ghế chuyến trực tiếp: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (widget.tripOrTransferTrip is TransferTrip) {
      final TransferTrip transferTrip = widget.tripOrTransferTrip as TransferTrip;

      if (transferTrip.firstTrip.fromStationId == null || transferTrip.firstTrip.toStationId == null) {
        setState(() {
          _errorMessage = 'Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến đầu tiên của trung chuyển.';
          _isLoading = false;
        });
        print(
          'ERROR: Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến đầu tiên của trung chuyển. Trip ID: ${transferTrip.firstTrip.id}, From Station ID: ${transferTrip.firstTrip.fromStationId}, To Station ID: ${transferTrip.firstTrip.toStationId}',
        );
        return;
      }

      try {
        final seats = await SeatService.getSeatAvailability(
          tripId: transferTrip.firstTrip.id,
          fromStationId: transferTrip.firstTrip.fromStationId!,
          toStationId: transferTrip.firstTrip.toStationId!,
        );
        setState(() {
          _firstTripSeats = seats;
        });
        _checkAndNotifyNoAvailableSeats(seats); // Kiểm tra và thông báo cho chuyến đầu tiên
        // Tải luôn ghế chặng 2 (nếu có) để hiển thị đồng thời
        if (transferTrip.secondTrip != null) {
          // Không cần chờ, để UI hiển thị dần
          _fetchSecondTripSeatAvailability();
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
        print('ERROR: Lỗi khi lấy ghế chuyến đầu tiên của trung chuyển: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    // Nếu khứ hồi và có chuyến về, load trước ghế "đi" xong sẽ load "về" (nếu cần)
    if (widget.isRoundTrip && widget.returnTripOrTransferTrip != null) {
      // Tùy yêu cầu UX có thể lazy-load phần về sau, tạm thời chưa tự động gọi để giữ trải nghiệm mượt
    }
  }

  Future<void> _fetchSecondTripSeatAvailability() async {
    final TransferTrip transferTrip = widget.tripOrTransferTrip as TransferTrip;
    if (transferTrip.secondTrip == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chuyến trung chuyển này chỉ có một chặng. Chuyển sang xác nhận.')));
      return;
    }
    if (transferTrip.secondTrip!.fromStationId == null || transferTrip.secondTrip!.toStationId == null) {
      setState(() {
        _errorMessage = 'Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến thứ hai của trung chuyển.';
        _isLoading = false;
      });
      print(
        'ERROR: Thiếu thông tin ID chuyến đi hoặc ID trạm cho chuyến thứ hai của trung chuyển. Trip ID: ${transferTrip.secondTrip!.id}, From Station ID: ${transferTrip.secondTrip!.fromStationId}, To Station ID: ${transferTrip.secondTrip!.toStationId}',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final seats = await SeatService.getSeatAvailability(
        tripId: transferTrip.secondTrip!.id,
        fromStationId: transferTrip.secondTrip!.fromStationId!,
        toStationId: transferTrip.secondTrip!.toStationId!,
      );
      setState(() {
        _secondTripSeats = seats;
      });
      _checkAndNotifyNoAvailableSeats(seats); // Kiểm tra và thông báo cho chuyến thứ hai
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print('ERROR: Lỗi khi lấy ghế chuyến thứ hai của trung chuyển: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết và Chọn ghế')),
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
      final Map<int, Station> stationsToSend = widget.stations.isNotEmpty ? widget.stations : _buildStationsFallback();

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
            _buildSeatGridMulti(_directTripSeats, _selectedDirectSeats, (seat) {
              setState(() {
                if (_selectedDirectSeats.any((s) => s.id == seat.id)) {
                  _selectedDirectSeats.removeWhere((s) => s.id == seat.id);
                } else {
                  _selectedDirectSeats.add(seat);
                }
              });
            }),
            if (_selectedDirectSeats.isNotEmpty && hasAvailableSeats)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!widget.isRoundTrip)
                      ElevatedButton(
                        onPressed: () {
                          final bookingData = BookingData(
                            tripOrTransferTrip: directTrip,
                            selectedFirstSeats: _selectedDirectSeats,
                            stations: stationsToSend,
                          );
                          context.push(BookingScreen.path, extra: bookingData);
                        },
                        child: const Text('Thanh toán'),
                      )
                    else
                      Expanded(child: const Text('Đã chọn ghế chuyến đi. Vui lòng chọn ghế cho chuyến về bên dưới.')),
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
            if (widget.isRoundTrip && widget.returnTripOrTransferTrip != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              _buildReturnContent(widget.returnTripOrTransferTrip),
              const SizedBox(height: 16),
              _buildBottomPayBar(),
            ],
          ],
        ),
      );
    } else if (widget.tripOrTransferTrip is TransferTrip) {
      final TransferTrip transferTrip = widget.tripOrTransferTrip as TransferTrip;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Chuyến đi trung chuyển', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),

            // Hiển thị đồng thời hai chặng (nếu có)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vui lòng chọn ghế chuyến đi', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text('Chặng 1', style: Theme.of(context).textTheme.titleMedium),
                _buildTripDetails(transferTrip.firstTrip),
                const SizedBox(height: 8),
                _buildSeatLegend(),
                const SizedBox(height: 8),
                _buildSeatGridMulti(_firstTripSeats, _selectedFirstTripSeats, (seat) {
                  setState(() {
                    if (_selectedFirstTripSeats.any((s) => s.id == seat.id)) {
                      _selectedFirstTripSeats.removeWhere((s) => s.id == seat.id);
                    } else {
                      _selectedFirstTripSeats.add(seat);
                    }
                  });
                }),
                if (transferTrip.secondTrip != null) ...[
                  const SizedBox(height: 16),
                  Text('Chặng 2', style: Theme.of(context).textTheme.titleMedium),
                  _buildTripDetails(transferTrip.secondTrip!),
                  const SizedBox(height: 8),
                  _buildSeatLegend(),
                  const SizedBox(height: 8),
                  _buildSeatGridMulti(_secondTripSeats, _selectedSecondTripSeats, (seat) {
                    setState(() {
                      if (_selectedSecondTripSeats.any((s) => s.id == seat.id)) {
                        _selectedSecondTripSeats.removeWhere((s) => s.id == seat.id);
                      } else {
                        _selectedSecondTripSeats.add(seat);
                      }
                    });
                  }),
                ],
              ],
            ),
            if (widget.isRoundTrip && widget.returnTripOrTransferTrip != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              _buildReturnContent(widget.returnTripOrTransferTrip),
            ],
            const SizedBox(height: 16),
            _buildBottomPayBar(),
          ],
        ),
      );
    }
    return const Center(child: Text('Không tìm thấy thông tin chuyến đi.'));
  }

  // Tải ghế CHUYẾN VỀ + UI hiển thị ngay bên dưới (flow mới)
  Future<void> _fetchReturnSeatAvailability() async {
    if (!widget.isRoundTrip || widget.returnTripOrTransferTrip == null) return;
    final dynamic returnTrip = widget.returnTripOrTransferTrip;
    try {
      if (returnTrip is Trip) {
        if (returnTrip.fromStationId == null || returnTrip.toStationId == null) return;
        final seats = await SeatService.getSeatAvailability(
          tripId: returnTrip.id,
          fromStationId: returnTrip.fromStationId!,
          toStationId: returnTrip.toStationId!,
        );
        setState(() {
          _returnDirectSeats = seats;
        });
        _checkAndNotifyNoAvailableSeats(seats);
      } else if (returnTrip is TransferTrip) {
        if (returnTrip.firstTrip.fromStationId == null || returnTrip.firstTrip.toStationId == null) return;
        final seats = await SeatService.getSeatAvailability(
          tripId: returnTrip.firstTrip.id,
          fromStationId: returnTrip.firstTrip.fromStationId!,
          toStationId: returnTrip.firstTrip.toStationId!,
        );
        setState(() {
          _returnFirstSeats = seats;
        });
        _checkAndNotifyNoAvailableSeats(seats);
        if (returnTrip.secondTrip != null) {
          // Load ghế chặng 2 nếu có
          _fetchReturnSecondTripSeatAvailability();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchReturnSecondTripSeatAvailability() async {
    if (widget.returnTripOrTransferTrip is! TransferTrip) return;
    final TransferTrip returnTransfer = widget.returnTripOrTransferTrip as TransferTrip;
    if (returnTransfer.secondTrip == null) {
      return;
    }
    if (returnTransfer.secondTrip!.fromStationId == null || returnTransfer.secondTrip!.toStationId == null) {
      setState(() {
        _errorMessage = 'Thiếu thông tin ID trạm cho chặng 2 chuyến về.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final seats = await SeatService.getSeatAvailability(
        tripId: returnTransfer.secondTrip!.id,
        fromStationId: returnTransfer.secondTrip!.fromStationId!,
        toStationId: returnTransfer.secondTrip!.toStationId!,
      );
      setState(() {
        _returnSecondSeats = seats;
      });
      _checkAndNotifyNoAvailableSeats(seats);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildReturnContent(dynamic returnTrip) {
    if (returnTrip is Trip) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chuyến về', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          _buildTripDetails(returnTrip),
          const SizedBox(height: 10),
          Text('Vui lòng chọn ghế chuyến về', style: Theme.of(context).textTheme.titleLarge),
          _buildSeatLegend(),
          const SizedBox(height: 10),
          _buildSeatGridMulti(_returnDirectSeats, _selectedReturnDirectSeats, (seat) {
            setState(() {
              if (_selectedReturnDirectSeats.any((s) => s.id == seat.id)) {
                _selectedReturnDirectSeats.removeWhere((s) => s.id == seat.id);
              } else {
                _selectedReturnDirectSeats.add(seat);
              }
            });
          }),
          const SizedBox(height: 10),
        ],
      );
    } else if (returnTrip is TransferTrip) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chuyến về (Trung chuyển)', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text('Chặng 1', style: Theme.of(context).textTheme.titleMedium),
          _buildTripDetails(returnTrip.firstTrip),
          const SizedBox(height: 8),
          _buildSeatLegend(),
          const SizedBox(height: 8),
          _buildSeatGridMulti(_returnFirstSeats, _selectedReturnFirstSeats, (seat) {
            setState(() {
              if (_selectedReturnFirstSeats.any((s) => s.id == seat.id)) {
                _selectedReturnFirstSeats.removeWhere((s) => s.id == seat.id);
              } else {
                _selectedReturnFirstSeats.add(seat);
              }
            });
          }),
          if (returnTrip.secondTrip != null) ...[
            const SizedBox(height: 16),
            Text('Chặng 2', style: Theme.of(context).textTheme.titleMedium),
            _buildTripDetails(returnTrip.secondTrip!),
            const SizedBox(height: 8),
            _buildSeatLegend(),
            const SizedBox(height: 8),
            _buildSeatGridMulti(_returnSecondSeats, _selectedReturnSecondSeats, (seat) {
              setState(() {
                if (_selectedReturnSecondSeats.any((s) => s.id == seat.id)) {
                  _selectedReturnSecondSeats.removeWhere((s) => s.id == seat.id);
                } else {
                  _selectedReturnSecondSeats.add(seat);
                }
              });
            }),
          ],
        ],
      );
    }

    return const Text('Dữ liệu chuyến về không hợp lệ.');
  }

  Widget _buildTripDetails(Trip trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mã chuyến: ${trip.tripId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('Từ: ${trip.fromLocation} ', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        Text('Đến: ${trip.endLocation}', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        Text(
          'Giờ đi: ${DateFormat('HH:mm').format(trip.timeStart)} - Giờ đến: ${DateFormat('HH:mm').format(trip.timeEnd)}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 5),
        Text('Xe: ${trip.busName}', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        Text('Giá: ${NumberFormat('#,###').format(trip.price)} VND', style: const TextStyle(fontSize: 18, color: Colors.red)),
        const SizedBox(height: 5),
        if (trip.routeDescription != null && trip.routeDescription!.isNotEmpty)
          Text('Lộ trình: ${trip.routeDescription}', style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  //
  Widget _buildSeatGridMulti(List<Seat> seats, List<Seat> selectedSeats, ValueChanged<Seat> onToggleSeat) {
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
        bool isSelected = selectedSeats.any((s) => s.id == seat.id);
        final seatName = getSeatName(index);

        return GestureDetector(
          onTap: () {
            if (seat.isAvailable) {
              onToggleSeat(seat);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ghế $seatName đã có người!')));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: seat.isAvailable ? (isSelected ? Colors.blue.shade300 : Colors.green.shade100) : Colors.red.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: seat.isAvailable ? (isSelected ? Colors.blue.shade700 : Colors.green) : Colors.red, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_seat, size: 18, color: seat.isAvailable ? (isSelected ? Colors.white : Colors.green.shade900) : Colors.red.shade900),
                const SizedBox(height: 2),
                Text(
                  seatName, // Sử dụng tên ghế đã được định dạng
                  style: TextStyle(
                    color: seat.isAvailable ? (isSelected ? Colors.white : Colors.green.shade900) : Colors.red.shade900,
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