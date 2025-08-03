
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class VnPayWebViewScreen extends StatefulWidget {
  static const path = '/customer/vnpay-webview';
  final String initialUrl; // URL mà bạn muốn tải
  final Function(bool isSuccess, String? responseCode)? onPaymentResult; // Callback khi thanh toán hoàn tất

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
            _handleVnPayCallback(url);
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
            // Quan trọng: Kiểm tra URL redirect của VNPay
            if (request.url.startsWith('YOUR_VNPAY_RETURN_URL_FROM_BACKEND')) {
              _handleVnPayCallback(request.url);
              return NavigationDecision.prevent; // Ngăn không cho WebView điều hướng đến URL này nữa
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.initialUrl));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setTextZoom(100);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  void _handleVnPayCallback(String url) {
    if (_paymentCompleted) return; // Đảm bảo chỉ xử lý một lần

    // Cần biết URL mà VNPay sẽ redirect về (hoặc URL mà backend của bạn sẽ redirect về)
    // Ví dụ: your_app_schema://vnpay_return?vnp_ResponseCode=00&...
    // Hoặc nếu VNPay redirect thẳng về backend của bạn và backend của bạn xử lý
    // rồi phản hồi lại app qua một cơ chế khác (ví dụ: polling), thì bạn không cần
    // xử lý URL này trực tiếp trong Flutter app.
    // Nếu bạn muốn xử lý trực tiếp trong app (như khi dùng Deep Link),
    // bạn sẽ kiểm tra các tham số trên URL để biết kết quả.

    // Giả định VNPay sẽ redirect về một URL có chứa vnp_ResponseCode
    // (Đây là ví dụ, bạn cần xác định URL chính xác từ tài liệu VNPay hoặc backend của bạn)
    if (url.contains('vnp_ResponseCode')) {
      final uri = Uri.parse(url);
      final responseCode = uri.queryParameters['vnp_ResponseCode'];
      debugPrint('VNPay Response Code: $responseCode');

      if (responseCode == '00') {
        // Giao dịch thành công
        widget.onPaymentResult?.call(true, responseCode);
      } else {
        // Giao dịch thất bại hoặc chờ xử lý
        widget.onPaymentResult?.call(false, responseCode);
      }
      _paymentCompleted = true; // Đánh dấu đã xử lý
      Navigator.of(context).pop(); // Quay lại màn hình trước đó
    }
    // else if (url.startsWith('YOUR_APP_CUSTOM_SCHEME://payment_result')) {
    //    // Nếu bạn dùng Deep Link tùy chỉnh từ backend để nhận kết quả
    //    // Phân tích URL để lấy kết quả
    //    _paymentCompleted = true;
    //    widget.onPaymentResult?.call(true, 'Deep Link result');
    //    Navigator.of(context).pop();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán VNPay')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(), // Hiển thị vòng tròn loading
            ),
        ],
      ),
    );
  }
}