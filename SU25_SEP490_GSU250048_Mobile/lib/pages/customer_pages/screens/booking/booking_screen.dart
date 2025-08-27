import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/TransferTrip.dart';
import 'package:mobile/models/trip.dart';
import 'package:mobile/models/seat.dart';
import 'package:mobile/models/station.dart';
import 'package:mobile/services/author_service.dart';
import '../../../../models/BookingData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../payment/vnpay_webview_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String baseUrl = dotenv.env['API_URL'] ?? '';
final Uri createPaymentUrl = Uri.parse('$baseUrl/Reservations');

class BookingScreen extends StatefulWidget {
  static const path = '/customer/booking';
  final BookingData bookingData;
  final int customerId;

  const BookingScreen({super.key, required this.bookingData, required this.customerId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isMakingPayment = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    _nameController.text = await AuthService.getUserName() ?? '';
    _phoneController.text = await AuthService.getPhone() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _getStationNameById(dynamic stations, int? stationId) {
    if (stationId == null || stations == null) {
      return "N/A";
    }

    final station = stations[stationId];
    if (station == null) {
      return "Không tìm thấy";
    }

    // Nếu station là Station object, trả về name
    if (station is Station) {
      return station.name;
    }

    // Nếu station là String, trả về trực tiếp
    if (station is String) {
      return station;
    }

    return "Không tìm thấy";
  }

  Future<void> _handleVnPayPayment() async {
    if (_isMakingPayment) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isMakingPayment = true;
    });

    final dynamic outbound = widget.bookingData.tripOrTransferTrip;
    final dynamic inbound = widget.bookingData.isRoundTrip ? widget.bookingData.returnTripOrTransferTrip : null;

    final Map<String, dynamic> requestBody;
    final int customerId = widget.customerId;

    List<Map<String, dynamic>> buildTripSeats(dynamic tripOrTransfer, List<Seat> seatsLeg1, List<Seat> seatsLeg2) {
      if (tripOrTransfer is Trip) {
        return [
          {
            "tripId": tripOrTransfer.id,
            "fromStationId": tripOrTransfer.fromStationId,
            "toStationId": tripOrTransfer.toStationId,
            "seatIds": seatsLeg1.map((s) => s.id).toList(),
          },
        ];
      }
      if (tripOrTransfer is TransferTrip) {
        final List<Map<String, dynamic>> seats = [
          {
            "tripId": tripOrTransfer.firstTrip.id,
            "fromStationId": tripOrTransfer.firstTrip.fromStationId,
            "toStationId": tripOrTransfer.firstTrip.toStationId,
            "seatIds": seatsLeg1.map((s) => s.id).toList(),
          },
        ];
        if (tripOrTransfer.secondTrip != null) {
          seats.add({
            "tripId": tripOrTransfer.secondTrip!.id,
            "fromStationId": tripOrTransfer.secondTrip!.fromStationId,
            "toStationId": tripOrTransfer.secondTrip!.toStationId,
            "seatIds": seatsLeg2.map((s) => s.id).toList(),
          });
        }
        return seats;
      }
      return [];
    }

    final List<Map<String, dynamic>> outboundSeats = buildTripSeats(
      outbound,
      widget.bookingData.selectedFirstSeats,
      widget.bookingData.selectedSecondSeats,
    );
    final List<Map<String, dynamic>> inboundSeats = widget.bookingData.isRoundTrip && inbound != null
        ? buildTripSeats(inbound, widget.bookingData.returnSelectedFirstSeats, widget.bookingData.returnSelectedSecondSeats)
        : <Map<String, dynamic>>[];

    if (outboundSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Chưa có thông tin ghế cho chuyến đi.')));
      setState(() {
        _isMakingPayment = false;
      });
      return;
    }

    requestBody = {
      "customerId": customerId,
      "isReturn": widget.bookingData.isRoundTrip,
      "tripSeats": outboundSeats,
      "returnTripSeats": inboundSeats,
      "paymentMethod": "VNPay",
    };

    try {
      // Sửa lỗi: Cấu trúc lại payload để khớp với yêu cầu của backend
      // Bổ sung thêm customerName và customerPhone
      final finalRequestBody = {
        "customerId": requestBody['customerId'],
        "isReturn": requestBody['isReturn'],
        "customerName": _nameController.text, // Thêm tên khách hàng
        "customerPhone": _phoneController.text, // Thêm số điện thoại
        "TripSeats": requestBody['tripSeats'],
        "ReturnTripSeats": requestBody['returnTripSeats'],
        "paymentMethod": requestBody['paymentMethod'],
      };

      final response = await http.post(createPaymentUrl, headers: {'Content-Type': 'application/json'}, body: json.encode(finalRequestBody));

      print('Sending payment request to: $createPaymentUrl');
      print('Request body: ${json.encode(finalRequestBody)}');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final String? vnpayUrl = responseBody['paymentUrl'];

        if (vnpayUrl != null && vnpayUrl.isNotEmpty) {
          print('Successfully received VNPay URL. Navigating to WebView...');
          context.push(VnPayWebViewScreen.path, extra: vnpayUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Không nhận được URL thanh toán từ máy chủ.')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khởi tạo thanh toán: ${response.statusCode} - ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi kết nối khi khởi tạo thanh toán: $e')));
      print('ERROR: Lỗi kết nối khi khởi tạo thanh toán: $e');
    } finally {
      setState(() {
        _isMakingPayment = false;
      });
    }
  }

  // ... (các hàm khác giữ nguyên) ...

  // Các hàm build widget khác giữ nguyên
  @override
  Widget build(BuildContext context) {
    final dynamic tripOrTransferTrip = widget.bookingData.tripOrTransferTrip;
    final List<Seat> selectedSeat1 = widget.bookingData.selectedFirstSeats;
    final List<Seat> selectedSeat2 = widget.bookingData.selectedSecondSeats;
    final bool isRoundTrip = widget.bookingData.isRoundTrip;
    final dynamic returnTrip = isRoundTrip ? widget.bookingData.returnTripOrTransferTrip : null;
    final List<Seat> returnSeat1 = widget.bookingData.returnSelectedFirstSeats;
    final List<Seat> returnSeat2 = widget.bookingData.returnSelectedSecondSeats;
    final dynamic stations = widget.bookingData.stations;

    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đặt vé'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Thông tin chuyến đi'),
            const SizedBox(height: 10),
            if (tripOrTransferTrip is Trip)
              _buildDirectTripInfo(context, 'Chuyến đi (Trực tiếp)', tripOrTransferTrip, selectedSeat1, stations)
            else if (tripOrTransferTrip is TransferTrip)
              _buildTransferTripInfo(context, 'Chuyến đi (Trung chuyển)', tripOrTransferTrip, selectedSeat1, selectedSeat2, stations),

            if (isRoundTrip && returnTrip != null) ...[
              const SizedBox(height: 20),
              _buildSectionTitle(context, 'Thông tin chuyến về'),
              const SizedBox(height: 10),
              if (returnTrip is Trip)
                _buildDirectTripInfo(context, 'Chuyến về (Trực tiếp)', returnTrip, returnSeat1, stations)
              else if (returnTrip is TransferTrip)
                _buildTransferTripInfo(context, 'Chuyến về (Trung chuyển)', returnTrip, returnSeat1, returnSeat2, stations),
            ],

            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Thông tin khách hàng'),
            const SizedBox(height: 10),
            _buildCustomerInfoForm(),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isMakingPayment ? null : _handleVnPayPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isMakingPayment
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Xác nhận và Thanh toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildDirectTripInfo(BuildContext context, String title, Trip trip, List<Seat> selectedSeats, dynamic stations) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$title: ${trip.fromLocation} -> ${trip.endLocation}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Mã chuyến: ${trip.tripId}'),
            Text('Ghế đã chọn: ${selectedSeats.isEmpty ? "N/A" : selectedSeats.map((s) => s.seatId).join(', ')}'),
            if (trip.fromStationId != null) Text('Trạm xuất phát: ${_getStationNameById(stations, trip.fromStationId)}'),
            if (trip.toStationId != null) Text('Trạm đến: ${_getStationNameById(stations, trip.toStationId)}'),

            Text('Giờ khởi hành: ${DateFormat('HH:mm, dd/MM/yyyy').format(trip.timeStart)}'),
            Text('Giá vé: ${NumberFormat('#,###').format(trip.price)} VND'),
            if (trip.routeDescription != null && trip.routeDescription!.isNotEmpty) Text('Lộ trình: ${trip.routeDescription}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferTripInfo(
      BuildContext context,
      String title,
      TransferTrip transferTrip,
      List<Seat> selectedSeat1,
      List<Seat> selectedSeat2,
      dynamic stations,
      ) {
    double totalPrice = (transferTrip.firstTrip.price) + (transferTrip.secondTrip?.price ?? 0.0);
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _buildTripSegment(context, 'Chặng 1', transferTrip.firstTrip, selectedSeat1, stations),
            if (transferTrip.secondTrip != null) ...[
              const Divider(height: 20),
              _buildTripSegment(context, 'Chặng 2', transferTrip.secondTrip!, selectedSeat2, stations),
            ],
            const SizedBox(height: 10),
            Text(
              'Tổng giá: ${NumberFormat('#,###').format(totalPrice)} VND',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSegment(BuildContext context, String title, Trip trip, List<Seat> selectedSeats, dynamic stations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Mã chuyến: ${trip.tripId}'),
        Text('Từ: ${trip.fromLocation} -> Đến: ${trip.endLocation}'),

        if (trip.fromStationId != null) Text('Trạm xuất phát: ${_getStationNameById(stations, trip.fromStationId)}'),
        if (trip.toStationId != null) Text('Trạm đến: ${_getStationNameById(stations, trip.toStationId)}'),

        Text('Ghế đã chọn: ${selectedSeats.isEmpty ? "N/A" : selectedSeats.map((s) => s.seatId).join(', ')}'),
        Text('Giờ khởi hành: ${DateFormat('HH:mm, dd/MM/yyyy').format(trip.timeStart)}'),
        Text('Giá vé: ${NumberFormat('#,###').format(trip.price)} VND'),
        if (trip.routeDescription != null && trip.routeDescription!.isNotEmpty) Text('Lộ trình: ${trip.routeDescription}'),
      ],
    );
  }

  Widget _buildCustomerInfoForm() {
    setState(() {});
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Họ và Tên',
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              prefixIcon: const Icon(Icons.person),
              hintText: 'Nhập họ và tên',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập họ tên của bạn';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Số điện thoại',
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              prefixIcon: const Icon(Icons.phone),
              hintText: 'Nhập số điện thoại',
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}