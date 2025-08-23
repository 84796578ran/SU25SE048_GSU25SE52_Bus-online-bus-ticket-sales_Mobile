import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/services/author_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class DriverQRScannerPage extends StatefulWidget {
  static final path = '/driver/qr';
  const DriverQRScannerPage({super.key});

  @override
  State<DriverQRScannerPage> createState() => _DriverQRScannerPageState();
}

class _DriverQRScannerPageState extends State<DriverQRScannerPage> {
  bool isScanned = false;
  final int codeLength = 6;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < codeLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  void _handleCode(String code) async {
    // Expect code to be a JSON string like { "ticketId": "string", "tripId": 0 }
    try {
      final decoded = json.decode(code);
      if (decoded is! Map) throw FormatException('Invalid payload');

      final ticketId = decoded['ticketId']?.toString();
      final tripId = decoded['tripId'];

      if (ticketId == null || ticketId.isEmpty || tripId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mã QR không hợp lệ')));
        return;
      }

      final baseUrl = dotenv.env['API_URL']?.trim() ?? 'https://localhost:7197';
      final uri = Uri.parse('$baseUrl/api/Ticket/check');

      final token = await AuthService.getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

      final body = json.encode({'ticketId': ticketId, 'tripId': tripId});

      final resp = await http.post(uri, headers: headers, body: body);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // try to parse response for message
        String msg = 'Vé hợp lệ';
        try {
          final respJson = json.decode(resp.body);
          if (respJson is Map && respJson['message'] != null) msg = respJson['message'].toString();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$msg')));
      } else {
        String err = 'Kiểm tra vé thất bại (code ${resp.statusCode})';
        try {
          final respJson = json.decode(resp.body);
          if (respJson is Map && respJson['message'] != null) err = respJson['message'].toString();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    } catch (e) {
      debugPrint('Error handling code: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xử lý mã: $e')));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get fullCode => _controllers.map((c) => c.text).join().trim();

  Future<void> _pickImageAndScan() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final capture = await MobileScannerController().analyzeImage(file.path);

        if (capture != null && capture.barcodes.isNotEmpty) {
          final barcode = capture.barcodes.first;
          final code = barcode.rawValue;
          if (code != null) {
            _handleCode(code);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không phát hiện được mã QR trong ảnh')));
        }
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét mã QR'), backgroundColor: Colors.orange),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text('Nhập mã QR in trên hóa đơn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),

          // Các ô nhập mã
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(codeLength, (index) {
              return Container(
                width: 45,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.number,
                  inputFormatters: [LengthLimitingTextInputFormatter(1), FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    if (value.isNotEmpty && index < codeLength - 1) {
                      _focusNodes[index + 1].requestFocus();
                    }
                    if (fullCode.length == codeLength) {
                      _handleCode(fullCode);
                    }
                  },
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      final String? code = barcode.rawValue;
                      if (code != null && !isScanned) {
                        setState(() => isScanned = true);
                        _handleCode(code);
                      }
                    }
                  },
                ),
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const Positioned(
                  top: 40,
                  child: Text('Hướng camera vào mã QR', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(onPressed: _pickImageAndScan, icon: const Icon(Icons.image), label: const Text('Chọn ảnh mã QR từ thư viện')),
          ),
        ],
      ),
    );
  }
}
