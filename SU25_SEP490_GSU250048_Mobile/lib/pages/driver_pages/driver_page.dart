// lib/pages/driver_pages/driver_home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/pages/commmon_pages/profile_page.dart';
// Sử dụng ValueNotifier riêng để quản lý trạng thái của Driver
final selectedDriverIndex = ValueNotifier(0);

class DriverHomePage extends StatefulWidget {
  final Widget child;

  const DriverHomePage({
    super.key,
    required this.child,
  });

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {

  // Danh sách các điểm đến của tài xế
  static final List<Destination> allDestinations = <Destination>[
    Destination('Trang chủ', Icons.home_filled, Icons.home, Colors.orange, Colors.white, '/driver/home'),
    Destination('Quét QR', Icons.qr_code_scanner_outlined, Icons.qr_code_scanner, Colors.orange, Colors.white, '/driver/qr'),
    Destination('Hồ sơ', Icons.person_outlined, Icons.person, Colors.orange, Colors.white, '/driver/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: selectedDriverIndex,
        builder: (context, value, child) {
          return NavigationBar(
            onDestinationSelected: (int index) {
              selectedDriverIndex.value = index;
              context.go(allDestinations[index].path);
            },
            surfaceTintColor: Colors.white,
            indicatorColor: Colors.orange, // Màu khác với Customer
            selectedIndex: selectedDriverIndex.value,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: allDestinations.map((e) => GestureDetector(
              child: NavigationDestination(
                icon: Icon(
                  e.icon,
                  color: e.color,
                ),
                selectedIcon: Icon(
                  e.selectedIcon,
                  color: e.selectedColor,
                ),
                label: e.title,
              ),
            )).toList(),
          );
        },
      ),
      body: widget.child,
    );
  }
}

class Destination {
  const Destination(this.title, this.icon, this.selectedIcon, this.color, this.selectedColor, this.path);
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final Color color;
  final Color selectedColor;
  final String path;
}