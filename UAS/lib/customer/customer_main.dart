import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';
import '../database/database_helper.dart';
import '../utils.dart';
import 'customer_booking.dart';

class CustomerHomeScreen extends StatefulWidget {
  final String userName;
  final int userId;
  const CustomerHomeScreen({super.key, required this.userName, required this.userId});
  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  List<Widget> get _pages => [
    CustomerHomePage(userName: widget.userName, userId: widget.userId),
    CustomerHistoryScreen(userId: widget.userId),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [BottomNavigationBarItem(icon: Icon(Icons.car_rental), label: "Mobil"), BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat")],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class CustomerHomePage extends StatefulWidget {
  final String userName;
  final int userId;
  const CustomerHomePage({super.key, required this.userName, required this.userId});
  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  List<Map<String, dynamic>> _cars = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _refreshCars(); }

  void _refreshCars({String? query}) async {
    final data = await DatabaseHelper().getCars(query: query);
    setState(() => _cars = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Hai, ${widget.userName}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
          Text("Mau sewa mobil apa?", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(30)),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (value) => _refreshCars(query: value),
                decoration: const InputDecoration(border: InputBorder.none, hintText: "Cari mobil (ex: Yaris)...", icon: Icon(Icons.search)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _cars.isEmpty
                  ? const Center(child: Text("Mobil tidak ditemukan"))
                  : ListView.builder(
                      itemCount: _cars.length,
                      itemBuilder: (ctx, i) {
                        final car = _cars[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                carImageWidget(car['imageUrl'], width: double.infinity, height: 160, fit: BoxFit.cover),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(car['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(formatRupiah(car['price']), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ]),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailBookingScreen(car: car, userId: widget.userId))),
                                      child: const Text("Sewa"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerHistoryScreen extends StatefulWidget {
  final int userId;
  const CustomerHistoryScreen({super.key, required this.userId});
  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() { super.initState(); loadHistory(); }

  Future<void> loadHistory() async {
    _history = await DatabaseHelper().getBookingHistoryByUser(widget.userId);
    setState(() {});
  }

  Color _getStatusColor(String? status) {
    final statusLower = (status ?? "").toLowerCase();
    switch (statusLower) {
      case "menunggu konfirmasi": return Colors.orange;
      case "dikonfirmasi": return Colors.blue;
      case "selesai": return Colors.green;
      case "ditolak": return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Penyewaan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
        ],
      ),
      body: _history.isEmpty
          ? const Center(child: Text("Belum ada riwayat."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (ctx, i) {
                final item = _history[i];
                final statusLower = (item['status'] ?? "").toLowerCase();
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            carImageWidget(item['carImage'], width: 60, height: 50, fit: BoxFit.cover),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(item['carName'] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text("${item['startDate']} - ${item['endDate']}"),
                                Text("Total: ${formatRupiah(item['totalPayment'])}"),
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: statusLower == "selesai"
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10)),
                                  onPressed: null,
                                  child: const Text("Pesanan Selesai"),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(color: _getStatusColor(item['status']), borderRadius: BorderRadius.circular(8)),
                                  child: Center(child: Text(item['status'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}