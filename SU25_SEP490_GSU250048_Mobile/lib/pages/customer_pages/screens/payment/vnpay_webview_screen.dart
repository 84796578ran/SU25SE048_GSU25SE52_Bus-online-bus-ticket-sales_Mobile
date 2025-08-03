

import 'dart:io'; // Import này cần cho nền tảng di động

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';


class VnPayWebViewScreen extends StatefulWidget {
  // Đường dẫn route của màn hình này, sử dụng trong GoRouter
  static const path = '/customer/vnpay-webview';
  final String initialUrl;
  final Function(bool isSuccess, String? responseCode)? onPaymentResult;

  const VnPayWebViewScreen({
    Key? key,
    required this.initialUrl,
    this.onPaymentResult,
  }) : super(key: key);

  @override
  State<VnPayWebViewScreen> createState() => _VnPayWebViewScreenState();
}

class _VnPayWebViewScreenState extends State<VnPayWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
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
          },
          onPageFinished: (String url) {
            debugPrint('Hoàn thành tải trang: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Lỗi tài nguyên web: ${error.description}');
            if (!_paymentCompleted) {
              _paymentCompleted = true;
              widget.onPaymentResult?.call(false, 'Lỗi tài nguyên: ${error.description}');
              Navigator.of(context).pop();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Yêu cầu điều hướng đến: ${request.url}');

            // Xử lý callback của VNPay ở đây
            // Đây là phần quan trọng nhất để bắt kết quả thanh toán
            if (request.url.contains('vnp_ResponseCode')) {
              _handleVnPayCallback(request.url);
              // Ngăn không cho WebView điều hướng đến URL này nữa, vì ta đã xử lý nó rồi
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
      (controller.platform as AndroidWebViewController)
          .setTextZoom(100);
    }
    _controller = controller;
  }

  void _handleVnPayCallback(String url) {
    if (_paymentCompleted) return; // Tránh gọi callback nhiều lần

    _paymentCompleted = true;

    final uri = Uri.parse(url);
    final responseCode = uri.queryParameters['vnp_ResponseCode'];
    debugPrint('Mã phản hồi từ VNPay: $responseCode');
    if (responseCode == '00') {
      widget.onPaymentResult?.call(true, responseCode);
    } else {
      widget.onPaymentResult?.call(false, responseCode);
    }
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
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}