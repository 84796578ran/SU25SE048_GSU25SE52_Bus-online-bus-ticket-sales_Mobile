import  'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/pages/customer_pages/screens/history_screen.dart';
import 'package:mobile/pages/customer_pages/screens/home_screen.dart';
import 'package:mobile/pages/customer_pages/screens/notification/notification_screen.dart';
import 'package:mobile/pages/customer_pages/screens/search/search_screen.dart';
import '../commmon_pages/profile_page.dart';


final selectedGlobalIndex = ValueNotifier(0);


class ProviderHomePage extends StatefulWidget {
  final Widget child;

  const ProviderHomePage({
    super.key,
    required this.child
  });

  @override
  State<ProviderHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<ProviderHomePage> {
   var _currentScreenIndex = 0;

  static final List<Destination> allDestinations = <Destination>[
     Destination('Trang chủ', Icons.home_filled, Icons.home, Colors.blue, Colors.white, HomeScreen.path),
     Destination('Tìm kiếm', Icons.search_outlined, Icons.search, Colors.blue, Colors.white, SearchScreen.path),
     Destination('Lịch sử đặt vé', Icons.calendar_month_outlined, Icons.calendar_month, Colors.blue, Colors.white, HistoryScreen.path),
    Destination('Thông báo', Icons.notifications_active, Icons.calendar_month, Colors.blue, Colors.white, NotificationScreen.path),
    Destination('Hồ sơ', Icons.person_outlined, Icons.person, Colors.blue, Colors.white, ProfilePage.path),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: selectedGlobalIndex,
        builder: (context, value, child) {
          selectedGlobalIndex.value = value;
          return NavigationBar(
            onDestinationSelected: (int index) {
              selectedGlobalIndex.value = index;
              context.go(allDestinations[index].path);
            },
            surfaceTintColor: Colors.white,
            indicatorColor: Colors.blue,
            selectedIndex: selectedGlobalIndex.value,
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
