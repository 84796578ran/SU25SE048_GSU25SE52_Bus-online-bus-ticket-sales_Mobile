import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/commmon_pages/login_page.dart';
import 'package:mobile/pages/commmon_pages/profile_page.dart';
import 'package:mobile/pages/customer_pages/provider_page.dart';
import 'package:mobile/pages/customer_pages/screens/history/history_screen.dart';
import 'package:mobile/pages/customer_pages/screens/home/home_screen.dart';
import 'package:mobile/pages/customer_pages/screens/notification/notification_screen.dart';
import 'package:mobile/pages/customer_pages/screens/search/search_result_screen.dart';
import 'package:mobile/pages/customer_pages/screens/search/search_screen.dart';
import 'package:mobile/pages/customer_pages/screens/search/search_result_detail.dart';
import 'package:mobile/services/navigation_service.dart';
import '../models/BookingData.dart';
import '../models/station.dart';
import '../models/stationPassengerCount.dart';
import '../models/ticket.dart';
import '../models/trip.dart';
import '../models/TransferTrip.dart';
import '../services/author_service.dart';
import '../widget/webview_widget.dart';
import 'customer_pages/screens/booking/booking_screen.dart';
import 'customer_pages/screens/history/history_detail_screen.dart';
import 'customer_pages/screens/home/get_future_trip_result.dart';
import 'customer_pages/screens/search/search-result-hint.dart';
import 'driver_pages/driver_page.dart';
import 'driver_pages/home/home_page_screen.dart';
import 'driver_pages/home/home_passenger_detail_screen.dart';
import 'driver_pages/profile/profile_screen.dart';
import 'driver_pages/qrScanner/qrScanner.dart';

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
          GoRoute(path: '/customer/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/register', builder: (context, state) => const HomeScreen()),

          GoRoute(path: '/customer/history', builder: (context, state) => const HistoryScreen()),
          GoRoute(
            path: '/customer/history/detail',
            builder: (BuildContext context, GoRouterState state) {
              final dynamic extra = state.extra;
              final Map<String, dynamic>? data = extra is Map<String, dynamic> ? extra : null;
              if (data == null || !data.containsKey('ticket') || !data.containsKey('customerId')) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Lỗi')),
                  body: const Center(child: Text('Không tìm thấy thông tin chi tiết vé.')),
                );
              }
              final ticket = data['ticket'] as Ticket;
              final customerId = data['customerId'] as int;
              return HistoryDetailScreen(ticket: ticket, customerId: customerId);
            },
          ),
          GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
          GoRoute(path: '/customer/search-trip', builder: (context, state) => const SearchScreen()),
          GoRoute(
            path: SearchResultScreen.path,
            builder: (BuildContext context, GoRouterState state) {
              final dynamic extra = state.extra;
              bool isRoundTrip = false;
              Map<int, Station> stations = {};
              List<dynamic>? departResults;
              List<dynamic>? returnResults;
              List<dynamic> results = [];
              if (extra is Map<String, dynamic>) {
                isRoundTrip = extra['isRoundTrip'] as bool? ?? false;
                final Map<int, dynamic> stationsRaw = extra['stations'] as Map<int, dynamic>? ?? {};
                stations = stationsRaw.cast<int, Station>();
                departResults = extra['departResults'] as List<dynamic>?;
                returnResults = extra['returnResults'] as List<dynamic>?;
                results = extra['results'] as List<dynamic>? ?? [];
              } else if (extra is List<dynamic>) {
                // Fallback: allow pushing a plain list of results
                results = extra;
                isRoundTrip = false;
                stations = {};
              } else if (extra is Trip) {
                // Support passing a single Trip directly
                results = [extra];
                isRoundTrip = false;
                stations = {};
              } else if (extra is TransferTrip) {
                // Support passing a single TransferTrip directly
                results = [extra];
                isRoundTrip = false;
                stations = {};
              } else if (extra == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Kết quả tìm kiếm')),
                  body: const Center(child: Text('Không có chuyến nào phù hợp.')),
                );
              } else {
                return Scaffold(
                  appBar: AppBar(title: const Text('Kết quả tìm kiếm')),
                  body: const Center(child: Text('Dữ liệu không hợp lệ.')),
                );
              }

              if (departResults != null && returnResults != null) {
                if (departResults.isEmpty && returnResults.isEmpty) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Kết quả tìm kiếm')),
                    body: const Center(child: Text('Không có chuyến nào phù hợp.')),
                  );
                }
                return SearchResultScreen(isRoundTrip: isRoundTrip, departResults: departResults, returnResults: returnResults, stations: stations);
              }

              if (results.isEmpty) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Kết quả tìm kiếm')),
                  body: const Center(child: Text('Không có chuyến nào phù hợp.')),
                );
              }

              return SearchResultScreen(isRoundTrip: isRoundTrip, results: results, stations: stations);
            },
          ),
          GoRoute(
            path: SearchResultDetailScreen.path,
            builder: (BuildContext context, GoRouterState state) {
              // Xử lý cả hai trường hợp: Map<String, dynamic> và Trip
              dynamic extraData = state.extra;
              dynamic tripOrTransferTrip;
              Map<int, Station> stations = {};

              if (extraData is Map<String, dynamic>) {
                tripOrTransferTrip = extraData['tripOrTransferTrip'];
                final stationsData = extraData['stations'] as Map<int, dynamic>?;
                if (stationsData != null) {
                  stations = stationsData.cast<int, Station>();
                }
              } else if (extraData is Trip) {
                tripOrTransferTrip = extraData;
              } else if (extraData is TransferTrip) {
                tripOrTransferTrip = extraData;
              }

              if (tripOrTransferTrip == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Lỗi')),
                  body: const Center(child: Text('Không tìm thấy thông tin chuyến đi.')),
                );
              }

              if (tripOrTransferTrip is! Trip && tripOrTransferTrip is! TransferTrip) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Lỗi')),
                  body: const Center(child: Text('Dữ liệu chuyến đi không hợp lệ.')),
                );
              }

              final bool isRoundTrip = (state.extra is Map<String, dynamic>) && ((state.extra as Map<String, dynamic>)['isRoundTrip'] == true);
              final dynamic returnTrip = (state.extra is Map<String, dynamic>)
                  ? (state.extra as Map<String, dynamic>)['returnTripOrTransferTrip']
                  : null;
              return SearchResultDetailScreen(
                tripOrTransferTrip: tripOrTransferTrip,
                returnTripOrTransferTrip: returnTrip,
                isRoundTrip: isRoundTrip,
                stations: stations,
              );
            },
          ),
          GoRoute(
            path: SearchResultHintScreen.path,
            builder: (BuildContext context, GoRouterState state) {
              final dynamic extra = state.extra;

              List<dynamic> searchResults = [];
              Map<int, Station> stations = {};

              if (extra is List<dynamic>) {
                searchResults = extra;
              } else if (extra is Map<String, dynamic>) {
                searchResults = (extra['results'] as List<dynamic>?) ?? [];
                final Map<int, dynamic>? stationsRaw = extra['stations'] as Map<int, dynamic>?;
                if (stationsRaw != null) {
                  stations = stationsRaw.cast<int, Station>();
                }
              } else if (extra is Trip) {
                // Support passing a single Trip directly
                searchResults = [extra];
              } else if (extra is TransferTrip) {
                // Support passing a single TransferTrip directly
                searchResults = [extra];
              } else {
                return Scaffold(
                  appBar: AppBar(title: const Text('Chuyến xe gợi ý')),
                  body: const Center(child: Text('Dữ liệu không hợp lệ.')),
                );
              }

              if (searchResults.isEmpty) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Chuyến xe gợi ý')),
                  body: const Center(child: Text('Không có chuyến nào phù hợp.')),
                );
              }

              return SearchResultHintScreen(results: searchResults, stations: stations);
            },
          ),
          GoRoute(
            path: '/customer/future-trips',
            builder: (BuildContext context, GoRouterState state) {
              final dynamic extra = state.extra;
              final Map<String, dynamic>? data = extra is Map<String, dynamic> ? extra : null;
              if (data == null || !data.containsKey('companyId') || !data.containsKey('companyName')) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Lỗi')),
                  body: const Center(child: Text('Không tìm thấy thông tin công ty.')),
                );
              }

              final int companyId = data['companyId'] as int;
              final String companyName = data['companyName'] as String;
              return FutureTripScreen(companyId: companyId, companyName: companyName);
            },
          ),

          GoRoute(
            path: BookingScreen.path,
            builder: (BuildContext context, GoRouterState state) {
              final BookingData? bookingData = state.extra as BookingData?;
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
                    return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
          GoRoute(path: '/customer/notification', builder: (context, state) => const NotificationScreen()),
          GoRoute(
            path: VnPayWebViewScreen.path,
            builder: (BuildContext context, GoRouterState state) {
              final String? initialUrl = state.extra as String?;
              if (initialUrl == null || initialUrl.isEmpty) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Lỗi')),
                  body: const Center(child: Text('Không có URL thanh toán.')),
                );
              }
              return VnPayWebViewScreen(
                initialUrl: initialUrl,
                onPaymentResult: (isSuccess, responseCode) {
                  if (isSuccess) {
                    print('Thanh toán VNPay thành công! Mã: $responseCode');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanh toán thành công!')));
                    context.go('/customer/home');
                  } else {
                    print('Thanh toán VNPay thất bại. Mã: $responseCode');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thanh toán thất bại: $responseCode')));
                    context.pop();
                  }
                },
              );
            },
          ),
        ],
      ),
      ShellRoute(
          builder: (context, state, child) => DriverHomePage(child: child), // Đổi tên widget phù hợp
          routes: [
            GoRoute(
              path: '/driver/home',
              builder: (context, state) => const DriverHomeScreen(), // Đổi tên widget phù hợp
            ),
            // Thêm các GoRoute khác của tài xế vào đây
            GoRoute(
              path: '/driver/profile',
              builder: (context, state) => const DriverProfileScreen(),
            ),
            GoRoute(
              path: HomePassengerDetailScreen.path,
              builder: (BuildContext context, GoRouterState state) {
                final StationPassengerCount? stationData = state.extra as StationPassengerCount?;
                if (stationData == null) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Lỗi')),
                    body: const Center(child: Text('Không tìm thấy thông tin trạm.')),
                  );
                }
                return HomePassengerDetailScreen(stationData: stationData);
              },
            ),
            GoRoute(
              path: '/driver/qr',
              builder: (context, state) {
                final data = state.extra as Map<String, dynamic>?;
                final ticketId = data != null ? data['ticketId']?.toString() : null;
                final tripId = data != null && data['tripId'] != null ? int.tryParse(data['tripId'].toString()) : null;

                return DriverQRScannerPage(
                  ticketId: ticketId,
                  tripId: tripId,
                );
              },
            ),
          ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: Center(child: Text('Không tìm thấy trang: ${state.error}')),
      );
    },
  );
}
