
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class VnPayWebViewScreen extends StatefulWidget {
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

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress: $progress%)');
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
            //_handleVnPayCallback(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
            ''');
            if (!_paymentCompleted) {
              _paymentCompleted = true;
              widget.onPaymentResult?.call(false, 'WebResourceError: ${error.description}');
              Navigator.of(context).pop(); // Quay lại màn hình trước
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('allowing navigation to ${request.url}');

            // xử lí callback của vnpay ở đây

            if (request.url.contains('vnp_ResponseCode')) {
              _handleVnPayCallback(request.url);
              return NavigationDecision.prevent;
            }
            // cho phép điều hướng khác
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