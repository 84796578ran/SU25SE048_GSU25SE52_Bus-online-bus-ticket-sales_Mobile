import  'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


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

  static const List<Destination> allDestinations = <Destination>[
    // Destination('Trang chủ', Icons.history, Icons.home, Colors.blue, Colors.white, ),
    // Destination('Dich vu cua toi', Icons.search_outlined, Icons.search, Colors.blue, Colors.white, ),
    // Destination('Quan ly vi', Icons.calendar_month_outlined, Icons.calendar_month, Colors.blue, Colors.white, ),
    // Destination('Tao dich vu moi', Icons.message_outlined, Icons.message, Colors.blue, Colors.white, ),
    // // Destination('Tin nhắn', Icons.message_outlined, Icons.message, Colors.blue, Colors.white, ),
    // Destination('Hồ sơ', Icons.person_outlined, Icons.person, Colors.blue, Colors.white, ProviderProfileScreen.path),
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
