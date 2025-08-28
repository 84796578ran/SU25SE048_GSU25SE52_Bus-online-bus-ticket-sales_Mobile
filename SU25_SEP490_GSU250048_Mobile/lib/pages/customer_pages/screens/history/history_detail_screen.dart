import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_core_ui/flutter_core_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../models/rating.dart';
import '../../../../models/ticket.dart';
import '../../../../provider/author_provider.dart';
import '../../../../services/rating_service.dart';

class HistoryDetailScreen extends StatefulWidget {
  final Ticket ticket;
  final int customerId;
  const HistoryDetailScreen({super.key, required this.ticket, required this.customerId});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  bool hasRated = false;



  @override
  void initState() {
    super.initState();
    // Ask for gallery/storage permission when opening this screen so user can download QR without friction
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissionOnEnter();
    });
  }

  Future<void> _checkAndRequestPermissionOnEnter() async {
    try {
      final Permission permission = Platform.isIOS ? Permission.photos : Permission.storage;
      final status = await permission.status;
      if (!status.isGranted) {
        await permission.request();
      }
    } catch (e) {
      // ignore errors here; we'll request later on download attempt
    }
  }

  void _showOpenSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yêu cầu quyền'),
          content: const Text('Quyền truy cập ảnh/ bộ nhớ bị từ chối vĩnh viễn. Vui lòng vào Cài đặt ứng dụng để bật quyền.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              child: const Text('Mở Cài đặt'),
            ),
          ],
        );
      },
    );
  }


  String _statusToString(int? status) {
    switch (status) {
      case 0:
        return 'Đã thanh toán';
      case 1:
        return 'Đang thực hiện chuyến đi';
      case 2:
        return 'Đã hủy';
      case 3:
        return 'Đang chờ xử lý';
      case 4:
        return 'Chưa thanh toán';
      case 5:
        return 'Đã hoàn thành chuyến đi';
      default:
        return 'Không xác định';
    }
  }

  Future<void> _downloadQrCode(BuildContext context) async {
    final qrCodeUrl = widget.ticket.qrCodeUrl;
    if (qrCodeUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có mã QR để tải về.')));
      return;
    }

    try {
      // Yêu cầu quyền truy cập bộ nhớ (platform-specific)
      final Permission permission = Platform.isIOS ? Permission.photos : Permission.storage;
      final status = await permission.status;
      if (!status.isGranted) {
        final result = await permission.request();
        if (!result.isGranted) {
          // If permanently denied, ask user to open app settings
          if (result.isPermanentlyDenied) {
            _showOpenSettingsDialog(context);
            return;
          }
          //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng cấp quyền truy cập ảnh để tải về.')));
          // return;
        }
      }

      // Tải ảnh từ URL
      final response = await http.get(Uri.parse(qrCodeUrl));
      if (response.statusCode == 200) {
        final Directory tempDir = await getTemporaryDirectory();
        final File file = File('${tempDir.path}/QR_Code_${widget.ticket.ticketId}.png');
        await file.writeAsBytes(response.bodyBytes);

        // Lưu ảnh vào thư viện ảnh bằng image_gallery_saver_plus
        final result = await ImageGallerySaverPlus.saveFile(file.path, name: "QR_Code_${widget.ticket.ticketId}");

        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã tải mã QR về thư viện ảnh thành công!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi lưu ảnh.')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tải ảnh từ đường dẫn.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataQR = {"ticketId": widget.ticket.ticketId, "tripId": widget.ticket.tripId};
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết vé')),
      body: SingleChildScrollView(
        // Đã thêm widget này
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mã vé: ${widget.ticket.ticketId}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Tên khách hàng: ${widget.ticket.customerName}', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 15),
              Text(
                'Từ trạm: ${widget.ticket.fromTripStation.isNotEmpty ? widget.ticket.fromTripStation : '---'}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 15),
              Text('Đến trạm: ${widget.ticket.toTripStation.isNotEmpty ? widget.ticket.toTripStation : '---'}', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 15),
              Text('Ghế: ${widget.ticket.seatId}', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 15),
              Text(
                'Giá: ${widget.ticket.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}đ',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 15),
              Text('Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.ticket.createDate)}', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 15),
              Text('Trạng thái: ${_statusToString(widget.ticket.status)}', style: const TextStyle(fontSize: 20)),

              const SizedBox(height: 5),
              if (widget.ticket.qrCodeUrl.isNotEmpty)
                Center(
                  child: Column(
                    children: [
                      Text('Mã QR vé của bạn: ${widget.ticket.ticketId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Image.network(
                        widget.ticket.qrCodeUrl,
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('Không thể tải mã QR', style: TextStyle(color: Colors.red));
                        },
                      ),
                      // QrImageView(data: dataQR.toString(), version: QrVersions.auto, size: 200.0.sp),
                    ],
                  ),
                ),

              const SizedBox(height: 5),
              // Nút tải ảnh QR
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadQrCode(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Tải ảnh QR'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              if (!hasRated && DateTime.now().isAfter(widget.ticket.timeEnd) && widget.ticket.status == 5)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final providerCustomer = Provider.of<AuthProvider>(context, listen: false).customerId;

                      if (providerCustomer == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi kết nối mạng. Vui lòng thử lại sau !!!.')));
                        return;
                      }
                      int ratingValue = 5;
                      String? comment;
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Đánh giá chuyến đi'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Bạn thấy chuyến đi này như thế nào?'),
                                const SizedBox(height: 10),
                                RatingBar.builder(
                                  initialRating: 5,
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                                  onRatingUpdate: (rating) {
                                    ratingValue = rating.toInt();
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  decoration: const InputDecoration(labelText: 'Bình luận (tuỳ chọn)'),
                                  onChanged: (value) {
                                    comment = value;
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  Future.delayed(Duration.zero, () async {
                                    try {
                                      final success = await RatingService.submitRating(
                                        Rating(ticketId: widget.ticket.id, customerId: widget.customerId, score: ratingValue, comment: comment),
                                      );
                                      if (success) {
                                        setState(() {
                                          hasRated = true;
                                        });

                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Cảm ơn'),
                                            content: const Text('Cảm ơn bạn đã đánh giá dịch vụ của chúng tôi!'),
                                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi gửi đánh giá: $e')));
                                    }
                                  });
                                },
                                child: const Text('Gửi'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.star_rate_rounded),
                    label: const Text('Đánh giá chuyến đi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
