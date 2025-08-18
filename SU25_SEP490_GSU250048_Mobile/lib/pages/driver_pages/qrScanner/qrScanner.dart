import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../services/ticket_service.dart';

class DriverQRScannerPage extends StatefulWidget {
  static final path = '/driver/qr';
  final int? tripId;
  final String? ticketId;

  const DriverQRScannerPage({super.key, this.tripId, this.ticketId});

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mã nhận được: $code')),
    );

    if (widget.tripId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Mã vé không hợp lệ')),
      );
      return;
    }

    try {
      final ticket = await TicketService.checkInTicket(code, widget.tripId!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-in thành công: Vé #${ticket.id}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Check-in thất bại: $e')),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không phát hiện được mã QR trong ảnh')),
          );
        }
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã QR'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Nhập mã QR in trên hóa đơn',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),

          // Ô nhập code
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
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
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

          // Camera quét QR
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
                  child: Text(
                    'Hướng camera vào mã QR',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Chọn ảnh từ thư viện
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: _pickImageAndScan,
              icon: const Icon(Icons.image),
              label: const Text('Chọn ảnh mã QR từ thư viện'),
            ),
          ),
        ],
      ),
    );
  }
}
