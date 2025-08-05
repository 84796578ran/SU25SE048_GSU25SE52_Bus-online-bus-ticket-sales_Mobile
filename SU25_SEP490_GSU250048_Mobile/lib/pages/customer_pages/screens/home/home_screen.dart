import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mobile/models/company.dart'; // Model của bạn
import 'package:mobile/services/company_service.dart';

import '../../../../services/trip_service.dart';
import 'get_future_trip_result.dart'; // Service API của bạn

class HomeScreen extends StatefulWidget {
  static const path = '/customer/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Future<List<Company>> _famousCompaniesFuture;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )
      ..repeat(reverse: false);

    _animation = Tween<Offset>(
      begin: const Offset(1.2, 0), // bắt đầu từ bên phải
      end: const Offset(-1.2, 0), // chạy qua bên trái
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _famousCompaniesFuture = CompanyService.fetchPopularCompanies();
  }

  Future<void> _refreshCompanies() async {
    setState(() {
      _famousCompaniesFuture = CompanyService.fetchPopularCompanies();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent.shade100,
        foregroundColor: Colors.white,
        toolbarHeight: 30,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          SizedBox(
            height: screenHeight / 4,
            child: Stack(
              children: [
                // 🔹 Đường nét đứt phía TRÊN xe
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: CustomPaint(
                      painter: DottedLinePainter(),
                      child: const SizedBox(
                        height: 2,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom:60),
                    child: CustomPaint(
                      painter: DottedLinePainter(),
                      child: const SizedBox(
                        height: 2,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 130),
                    child: CustomPaint(
                      painter: DottedLinePainter(),
                      child: const SizedBox(
                        height: 4,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: SlideTransition(
                    position: _animation,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 90),
                        child: Image.asset(
                          'assets/buss.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                  ),
                ),

                // 🏷 Tiêu đề
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'Các nhà xe phổ biến',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshCompanies,
              child: FutureBuilder<List<Company>>(
                future: _famousCompaniesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Đã xảy ra lỗi khi tải dữ liệu!!!',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Lỗi kết nối!!! Vui lòng tải lại trang'),
                    );
                  }

                  final companies = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: companies.length,
                    itemBuilder: (context, index) {
                      final company = companies[index];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FutureTripScreen(
                                companyId: company.id,
                                companyName: company.name,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(40),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          elevation: 3,
                          color: const Color(0xFFFFF0F0),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.directions_bus, size: 40, color: Colors.blueAccent),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        company.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.schedule, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text('Số chuyến: ${company.numberOfTrips}'),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 16, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text('Đánh giá: ${company.averageRating.toStringAsFixed(1)}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const dashWidth = 5;
    const dashSpace = 5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
