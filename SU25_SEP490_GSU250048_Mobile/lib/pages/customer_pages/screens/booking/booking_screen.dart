import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/TransferTrip.dart';
import 'package:mobile/models/trip.dart';
import 'package:mobile/models/seat.dart';
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
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
    print('BookingScreen initState - Dữ liệu đã nhận:');
    print('Trip: ${widget.bookingData.tripOrTransferTrip.tripId}');
    print('Customer ID: ${widget.customerId}');
  }

  String _getStationNameById(dynamic stations, int? stationId) {
    if (stationId == null || stations == null) {
      return "N/A";
    }
    return stations[stationId] ?? "Không tìm thấy";
  }

  Future<void> _handleVnPayPayment() async {
    if (_isMakingPayment) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isMakingPayment = true;
    });

    final dynamic tripOrTransferTrip = widget.bookingData.tripOrTransferTrip;

    // Tạo request body khớp với định nghĩa của backend
    final Map<String, dynamic> requestBody;
    // Lấy customerId từ widget thay vì gán cứng
    final int customerId = widget.customerId;

    if (tripOrTransferTrip is Trip) {
      final trip = tripOrTransferTrip;
      final selectedSeat = widget.bookingData.selectedFirstSeat;

      // Sửa lỗi: Cập nhật tên trường thành "TripSeats"
      requestBody = {
        "customerId": customerId,
        "isReturn": false,
        "tripSeats": [
          {
            // SỬA LỖI: Chuyển đổi tripId thành int vì backend yêu cầu
            "tripId": int.tryParse(trip.tripId) ?? 0,
            "fromStationId": trip.fromStationId,
            "toStationId": trip.toStationId,
            "seatIds": <int>[(selectedSeat?.seatId as int?) ?? 0],
          }
        ],
        "returnTripSeats": [],
        "paymentMethod": "VNPay",
      };
    } else if (tripOrTransferTrip is TransferTrip) {
      final transferTrip = tripOrTransferTrip;
      final selectedSeat1 = widget.bookingData.selectedFirstSeat;
      final selectedSeat2 = widget.bookingData.selectedSecondSeat;

      // Sửa lỗi: Cập nhật tên trường thành "TripSeats" và "ReturnTripSeats"
      requestBody = {
        "customerId": customerId,
        "isReturn": true,
        "tripSeats": [
          {
            // SỬA LỖI: Chuyển đổi tripId thành int vì backend yêu cầu
            "tripId": int.tryParse(transferTrip.firstTrip.tripId) ?? 0,
            "fromStationId": transferTrip.firstTrip.fromStationId,
            "toStationId": transferTrip.firstTrip.toStationId,
            "seatIds": <int>[(selectedSeat2?.seatId as int?) ?? 0],
          }
        ],
        "returnTripSeats": [
          {
            // SỬA LỖI: Chuyển đổi tripId thành int vì backend yêu cầu
            "tripId": int.tryParse(transferTrip.secondTrip?.tripId ?? '0') ?? 0,
            "fromStationId": transferTrip.secondTrip?.fromStationId,
            "toStationId": transferTrip.secondTrip?.toStationId,
            "seatIds": <int>[(selectedSeat2?.seatId as int?) ?? 0],
          }
        ],
        "paymentMethod": "VNPay",
      };
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không tìm thấy thông tin chuyến đi.')),
      );
      setState(() {
        _isMakingPayment = false;
      });
      return;
    }

    // URL đã đúng
  //  final Uri createPaymentUrl = Uri.parse('https://bobts-server-e7dxfwh7e5g9e3ad.malaysiawest-01.azurewebsites.net/api/Reservations');

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

      final response = await http.post(
        createPaymentUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(finalRequestBody),
      );

      print('Sending payment request to: $createPaymentUrl');
      print('Request body: ${json.encode(finalRequestBody)}');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final String? vnpayUrl = responseBody['vnpayUrl'];

        if (vnpayUrl != null && vnpayUrl.isNotEmpty) {
          print('Successfully received VNPay URL. Navigating to WebView...');
          context.push(VnPayWebViewScreen.path, extra: vnpayUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi: Không nhận được URL thanh toán từ máy chủ.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khởi tạo thanh toán: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối khi khởi tạo thanh toán: $e')),
      );
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
    final selectedSeat1 = widget.bookingData.selectedFirstSeat;
    final selectedSeat2 = widget.bookingData.selectedSecondSeat;
    final dynamic stations = widget.bookingData.stations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận đặt vé'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Thông tin chuyến đi'),
            const SizedBox(height: 10),
            if (tripOrTransferTrip is Trip)
              _buildDirectTripInfo(context, tripOrTransferTrip, selectedSeat1, stations)
            else if (tripOrTransferTrip is TransferTrip)
              _buildTransferTripInfo(context, tripOrTransferTrip, selectedSeat1, selectedSeat2, stations),

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isMakingPayment
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Xác nhận và Thanh toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDirectTripInfo(BuildContext context, Trip trip, Seat? selectedSeat, dynamic stations) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chuyến trực tiếp: ${trip.fromLocation} -> ${trip.endLocation}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Mã chuyến: ${trip.tripId}'),
            Text('Ghế đã chọn: ${selectedSeat?.seatId ?? "N/A"}'),
            if (trip.fromStationId != null)
              Text('Trạm xuất phát: ${_getStationNameById(stations, trip.fromStationId)}'),
            if (trip.toStationId != null)
              Text('Trạm đến: ${_getStationNameById(stations, trip.toStationId)}'),

            Text('Giờ khởi hành: ${DateFormat('HH:mm, dd/MM/yyyy').format(trip.timeStart)}'),
            Text('Giá vé: ${NumberFormat('#,###').format(trip.price ?? 0)} VND'),
            if (trip.routeDescription != null && trip.routeDescription!.isNotEmpty)
              Text('Lộ trình: ${trip.routeDescription}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferTripInfo(BuildContext context, TransferTrip transferTrip, Seat? selectedSeat1, Seat? selectedSeat2, dynamic stations) {
    double totalPrice = (transferTrip.firstTrip.price ?? 0) + (transferTrip.secondTrip?.price ?? 0.0);
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chuyến trung chuyển', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _buildTripSegment(context, 'Chặng 1', transferTrip.firstTrip, selectedSeat1, stations),
            if (transferTrip.secondTrip != null) ...[
              const Divider(height: 20),
              _buildTripSegment(context, 'Chặng 2', transferTrip.secondTrip!, selectedSeat2, stations),
            ],
            const SizedBox(height: 10),
            Text('Tổng giá: ${NumberFormat('#,###').format(totalPrice)} VND',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSegment(BuildContext context, String title, Trip trip, Seat? selectedSeat, dynamic stations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Mã chuyến: ${trip.tripId}'),
        Text('Từ: ${trip.fromLocation} -> Đến: ${trip.endLocation}'),

        if (trip.fromStationId != null)
          Text('Trạm xuất phát: ${_getStationNameById(stations, trip.fromStationId)}'),
        if (trip.toStationId != null)
          Text('Trạm đến: ${_getStationNameById(stations, trip.toStationId)}'),

        Text('Ghế đã chọn: ${selectedSeat?.seatId ?? "N/A"}'),
        Text('Giờ khởi hành: ${DateFormat('HH:mm, dd/MM/yyyy').format(trip.timeStart)}'),
        Text('Giá vé: ${NumberFormat('#,###').format(trip.price ?? 0)} VND'),
        if (trip.routeDescription != null && trip.routeDescription!.isNotEmpty)
          Text('Lộ trình: ${trip.routeDescription}'),
      ],
    );
  }

  Widget _buildCustomerInfoForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và Tên',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              prefixIcon: Icon(Icons.person),
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
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              prefixIcon: Icon(Icons.phone),
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
