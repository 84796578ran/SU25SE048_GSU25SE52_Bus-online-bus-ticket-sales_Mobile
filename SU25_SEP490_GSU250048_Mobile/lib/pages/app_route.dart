import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/commmon_pages/login_page.dart';
import 'package:mobile/pages/commmon_pages/profile_page.dart';
import 'package:mobile/pages/customer_pages/provider_page.dart';
import 'package:mobile/pages/customer_pages/screens/history/history_screen.dart';
import 'package:mobile/pages/customer_pages/screens/home_screen.dart';
import 'package:mobile/pages/customer_pages/screens/notification/notification_screen.dart';
import 'package:mobile/pages/customer_pages/screens/search/search_result_screen.dart';
import 'package:mobile/pages/customer_pages/screens/search/search_screen.dart';
import 'package:mobile/pages/customer_pages/screens/search/search_result_detail.dart';
import 'package:mobile/services/navigation_service.dart';
import '../models/BookingData.dart';
import '../models/ticket.dart';
import '../services/author_service.dart';
import '../widget/webview_widget.dart';
import 'customer_pages/screens/booking/booking_screen.dart';
import 'customer_pages/screens/history/history_detail_screen.dart';
import 'customer_pages/screens/search/search-result-hint.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: LoginPage.path,
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: LoginPage.path,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      ShellRoute(
          builder: (context, state, child) => ProviderHomePage(child: child),
          routes: [
            GoRoute(
              path: '/customer/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/customer/history',
              builder: (context, state) => const HistoryScreen(),
            ),
            GoRoute(
              path: '/customer/history/detail',
              builder: (BuildContext context, GoRouterState state) {
                final ticket = state.extra as Ticket?;
                if (ticket == null) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Lỗi')),
                    body: const Center(child: Text('Không tìm thấy thông tin vé.')),
                  );
                }
                return HistoryDetailScreen(ticket: ticket);
              },
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
            GoRoute(
              path: '/customer/search-trip',
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
                path: SearchResultScreen.path,
                builder: (BuildContext context, GoRouterState state) {
                  final List<dynamic>? searchResults = state.extra as List<dynamic>?;
                  if (searchResults == null || searchResults.isEmpty) {
                    return Scaffold(
                      appBar: AppBar(title: const Text('Kết quả tìm kiếm')),
                      body: const Center(
                        child: Text('Không có chuyến nào phù hợp.'),
                      ),
                    );
                  }
                  return SearchResultScreen(results: searchResults);
                }
            ),
            GoRoute(
              path: SearchResultDetailScreen.path,
              builder: (BuildContext context, GoRouterState state) {
                final dynamic tripOrTransferTrip = state.extra;
                if (tripOrTransferTrip == null) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Lỗi')),
                    body: const Center(child: Text('Không tìm thấy chi tiết chuyến đi hoặc thông tin ghế.')),
                  );
                }
                return SearchResultDetailScreen(tripOrTransferTrip: tripOrTransferTrip);
              },
            ),
            GoRoute(
              path: SearchResultHintScreen.path,
              builder: (BuildContext context, GoRouterState state) {
                final List<dynamic>? searchResults = state.extra as List<dynamic>?;
                if (searchResults == null || searchResults.isEmpty) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Chuyến xe gợi ý')),
                    body: const Center(
                      child: Text('Không có chuyến nào phù hợp.'),
                    ),
                  );
                }
                return SearchResultHintScreen(results: searchResults);
              },
            ),
            // Cập nhật route cho BookingScreen để xử lý bất đồng bộ
            GoRoute(
              path: BookingScreen.path,
              builder: (BuildContext context, GoRouterState state) {
                final bookingData = state.extra as BookingData?;
                if (bookingData == null) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Lỗi')),
                    body: const Center(child: Text('Không tìm thấy thông tin đặt vé.')),
                  );
                }
                return FutureBuilder<int?>(
                  future: AuthService.getCustomerId(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      // Nếu có lỗi hoặc không tìm thấy customerId, điều hướng về trang đăng nhập
                      return const LoginPage();
                    }

                    final int customerId = snapshot.data!;
                    return BookingScreen(bookingData: bookingData, customerId: customerId);
                  },
                );
              },
            ),
            GoRoute(
              path: '/customer/notification',
              builder: (context, state) => const NotificationScreen(),
            ),
            GoRoute(
              path: VnPayWebViewScreen.path,
              builder: (BuildContext context, GoRouterState state) {
                final String? initialUrl = state.extra as String?;
                if (initialUrl == null || initialUrl.isEmpty) {
                  return Scaffold(
                    appBar: AppBar(title: Text('Lỗi')),
                    body: Center(child: Text('Không có URL thanh toán.')),
                  );
                }
                return VnPayWebViewScreen(
                  initialUrl: initialUrl,
                  onPaymentResult: (isSuccess, responseCode) {
                    if (isSuccess) {
                      print('Thanh toán VNPay thành công! Mã: $responseCode');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thanh toán thành công!')),
                      );
                      context.go('/customer/home');
                    } else {
                      print('Thanh toán VNPay thất bại. Mã: $responseCode');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Thanh toán thất bại: $responseCode')),
                      );
                      context.pop();
                    }
                  },
                );
              },
            ),
          ]
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Page not found: ${state.error}'),
        ),
      );
    },
  );
}
