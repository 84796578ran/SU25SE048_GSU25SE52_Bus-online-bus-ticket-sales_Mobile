import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../models/customer.dart';
import '../../../../models/ticket.dart';
import '../../../../services/ticket_service.dart';
import '../../../../provider/author_provider.dart';
import 'history_detail_screen.dart'; // nhớ import màn detail

class HistoryScreen extends StatefulWidget {
  static const path = '/customer/history';
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Ticket>> _ticketHistoryFuture;

  @override
  void initState() {
    super.initState();
    _ticketHistoryFuture = _fetchTickets();
  }

  Future<List<Ticket>> _fetchTickets() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      print('Người dùng chưa đăng nhập.');
      return [];
    }

    try {
      return await TicketService.fetchTicketHistory();
    } catch (e) {
      print('Lỗi khi lấy lịch sử vé: $e');
      return [];
    }
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _ticketHistoryFuture = _fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentCustomer = authProvider.customerId; // Đã lấy customer từ provider
    print('DEBUG: Giá trị của currentCustomer là: $currentCustomer');
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử đặt vé')),
      body: RefreshIndicator(
        onRefresh: _refreshHistory,
        child: FutureBuilder<List<Ticket>>(
          future: _ticketHistoryFuture,
          builder: (context, snapshot) {
            if (!authProvider.isLoggedIn) {
              return const Center(
                  child: Text(' Vui lòng đăng nhập để xem lịch sử vé.'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Không có lịch sử đặt vé.'));
            }

            final tickets = snapshot.data!;
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: InkWell(
                    onTap: () {
                      if (currentCustomer != null) {
                        context.push(
                          '/customer/history/detail',
                          extra: {
                            'ticket': ticket,
                            'customerId' : currentCustomer,
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lỗi: Không tìm thấy thông tin khách hàng.')),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mã vé: ${ticket.ticketId}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 6),
                          Text('Từ trạm: ${ticket.fromTripStation ?? '---'}'),
                          Text('Đến trạm: ${ticket.toTripStation ?? '---'}'),
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
    );
  }
}