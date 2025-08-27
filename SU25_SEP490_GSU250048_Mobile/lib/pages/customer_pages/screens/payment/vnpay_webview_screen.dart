import 'dart:io'; // Import này cần cho nền tảng di động
import 'dart:async'; // Import cho Timer

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class VnPayWebViewScreen extends StatefulWidget {
  // Đường dẫn route của màn hình này, sử dụng trong GoRouter
  static const path = '/customer/vnpay-webview';
  final String initialUrl;
  final Function(bool isSuccess, String? responseCode)? onPaymentResult;

  const VnPayWebViewScreen({Key? key, required this.initialUrl, this.onPaymentResult}) : super(key: key);

  @override
  State<VnPayWebViewScreen> createState() => _VnPayWebViewScreenState();
}

class _VnPayWebViewScreenState extends State<VnPayWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _paymentCompleted = false;
  Timer? _timeoutTimer;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
    // Bắt đầu timer để theo dõi thời gian thanh toán (10 phút)
    _timeoutTimer = Timer(const Duration(minutes: 10), () {
      if (!_paymentCompleted && mounted) {
        debugPrint('Timeout thanh toán VNPay');
        _paymentCompleted = true;
        widget.onPaymentResult?.call(false, 'TIMEOUT');
        Navigator.of(context).pop();
      }
    });
  }

  void _initializeWebViewController() {
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(allowsInlineMediaPlayback: true, mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{});
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Cập nhật tiến độ tải trang (tùy chọn)
            debugPrint('WebView đang tải (tiến độ: $progress%)');
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            debugPrint('Bắt đầu tải trang: $url');
            setState(() {
              _isLoading = true;
            });

            // Kiểm tra xem có phải là trang kết quả thanh toán không
            if (url.contains('vnp_ResponseCode=')) {
              debugPrint('Phát hiện trang kết quả thanh toán (onPageStarted): $url');
              _handleVnPayCallback(url);
            }
          },
          onPageFinished: (String url) {
            debugPrint('Hoàn thành tải trang: $url');
            setState(() {
              _isLoading = false;
            });

            // Kiểm tra xem có phải là trang kết quả thanh toán không
            if (url.contains('vnp_ResponseCode=')) {
              debugPrint('Phát hiện trang kết quả thanh toán: $url');
              _handleVnPayCallback(url);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Lỗi tài nguyên web: ${error.description}');
            if (!_paymentCompleted) {
              _paymentCompleted = true;
              // Gọi callback trước khi pop
              widget.onPaymentResult?.call(false, 'Lỗi tài nguyên: ${error.description}');
              Navigator.of(context).pop();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Yêu cầu điều hướng đến: ${request.url}');

            // Chỉ xử lý callback khi URL chứa tham số kết quả thanh toán
            // VNPay callback thường có format: https://your-domain.com/callback?vnp_ResponseCode=00&...
            if (request.url.contains('vnp_ResponseCode=')) {
              debugPrint('Phát hiện VNPay callback URL với response code: ${request.url}');
              _handleVnPayCallback(request.url);
              return NavigationDecision.prevent;
            }

            // Kiểm tra các URL callback khác có thể có (chỉ khi không phải trang thanh toán)
            if (!request.url.contains('PaymentMethod.html') &&
                request.url.contains('vnpay') &&
                (request.url.contains('success') || request.url.contains('cancel') || request.url.contains('error'))) {
              debugPrint('Phát hiện VNPay callback URL khác: ${request.url}');
              _handleVnPayCallback(request.url);
              return NavigationDecision.prevent;
            }

            // Cho phép các yêu cầu điều hướng khác
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setTextZoom(100);
    }
    _controller = controller;
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _handleVnPayCallback(String url) {
    if (_paymentCompleted) return; // Tránh gọi callback nhiều lần

    _paymentCompleted = true;
    debugPrint('Xử lý VNPay callback URL: $url');

    final uri = Uri.parse(url);
    final responseCode = uri.queryParameters['vnp_ResponseCode'];
    debugPrint('Mã phản hồi từ VNPay: $responseCode');

    // Xử lý các trường hợp khác nhau
    bool isSuccess = false;
    String? finalResponseCode = responseCode;

    if (responseCode == '00') {
      isSuccess = true;
      finalResponseCode = '00';
      debugPrint('Thanh toán thành công với mã: $responseCode');
    } else if (responseCode != null) {
      // Có responseCode nhưng không phải '00'
      isSuccess = false;
      finalResponseCode = responseCode;
      debugPrint('Thanh toán thất bại với mã: $responseCode');
    } else {
      // Không có responseCode, kiểm tra URL để xác định kết quả
      if (url.contains('success') || url.contains('complete')) {
        isSuccess = true;
        finalResponseCode = 'SUCCESS';
        debugPrint('Thanh toán thành công (dựa trên URL)');
      } else if (url.contains('cancel') || url.contains('canceled')) {
        isSuccess = false;
        finalResponseCode = 'CANCELED';
        debugPrint('Thanh toán bị hủy (dựa trên URL)');
      } else if (url.contains('error') || url.contains('failed')) {
        isSuccess = false;
        finalResponseCode = 'ERROR';
        debugPrint('Thanh toán thất bại (dựa trên URL)');
      } else {
        // Không xác định được, coi như thất bại
        isSuccess = false;
        finalResponseCode = 'UNKNOWN';
        debugPrint('Không xác định được kết quả thanh toán');
      }
    }

    debugPrint('Kết quả thanh toán: ${isSuccess ? 'THÀNH CÔNG' : 'THẤT BẠI'} - Mã: $finalResponseCode');
    widget.onPaymentResult?.call(isSuccess, finalResponseCode);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VNPay'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Xử lý khi người dùng đóng WebView
            if (!_paymentCompleted) {
              _paymentCompleted = true;
              widget.onPaymentResult?.call(false, 'Người dùng đã hủy thanh toán');
            }
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
