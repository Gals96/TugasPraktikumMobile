import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import 'auth_screens.dart';

// ======================================================
//                CUSTOMER HOME WITH NAVBAR
// ======================================================

class CustomerHomeScreen extends StatefulWidget {
  final String userName;
  final int userId;

  const CustomerHomeScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;

  // Pages untuk bottom navbar
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.car_rental), label: "Mobil"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
        ],
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

// ======================================================
//                    HOME PAGE PELANGGAN
// ======================================================

class CustomerHomePage extends StatefulWidget {
  final String userName;
  final int userId;

  const CustomerHomePage({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  List<Map<String, dynamic>> _cars = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshCars();
  }

  void _refreshCars({String? query}) async {
    final data = await DatabaseHelper().getCars(query: query);
    setState(() => _cars = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hai, ${widget.userName}",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("Mau sewa mobil apa?",
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30)),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (value) => _refreshCars(query: value),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Cari mobil (ex: Yaris)...",
                  icon: Icon(Icons.search),
                ),
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Image.network(
                                  car['imageUrl'],
                                  height: 120,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.car_rental, size: 80),
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(car['name'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                          formatRupiah(car['price']),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DetailBookingScreen(
                                                car: car, userId: widget.userId),
                                          ),
                                        );
                                      },
                                      child: const Text("Sewa"),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
//                    DETAIL BOOKING PAGE
// ======================================================

class DetailBookingScreen extends StatefulWidget {
  final Map<String, dynamic> car;
  final int userId;

  const DetailBookingScreen({
    super.key,
    required this.car,
    required this.userId,
  });

  @override
  State<DetailBookingScreen> createState() => _DetailBookingScreenState();
}

class _DetailBookingScreenState extends State<DetailBookingScreen> {
  DateTimeRange? _selectedDateRange;
  int _totalDays = 0;
  int _totalPrice = 0;

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _totalDays = picked.end.difference(picked.start).inDays;
        if (_totalDays == 0) _totalDays = 1;
        _totalPrice = _totalDays * (widget.car['price'] as int);
      });
    }
  }

  void _submitBooking() async {
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Pilih tanggal dulu!")));
      return;
    }

    await DatabaseHelper().createTransaction({
      'userId': widget.userId,
      'carId': widget.car['id'],
      'carName': widget.car['name'],
      'carImage': widget.car['imageUrl'],
      'startDate': DateFormat('dd MMM yyyy').format(_selectedDateRange!.start),
      'endDate': DateFormat('dd MMM yyyy').format(_selectedDateRange!.end),
      'totalPayment': _totalPrice,
      'status': 'Menunggu Konfirmasi'
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Booking berhasil! Menunggu admin.")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.car['name'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.car['imageUrl'],
                height: 200, fit: BoxFit.contain),
            const SizedBox(height: 20),

            Text("Harga Sewa: ${formatRupiah(widget.car['price'])} / hari",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),

            const SizedBox(height: 20),
            Text("Pilih Tanggal Sewa",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            InkWell(
              onTap: _pickDateRange,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDateRange == null
                          ? "Klik untuk pilih tanggal"
                          : "${DateFormat('dd MMM').format(_selectedDateRange!.start)} - "
                              "${DateFormat('dd MMM').format(_selectedDateRange!.end)} ($_totalDays Hari)",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Pembayaran:",
                    style: TextStyle(fontSize: 16)),
                Text(formatRupiah(_totalPrice),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ],
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
                onPressed: _submitBooking,
                child: const Text("KONFIRMASI BOOKING"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ======================================================
//                  HISTORY PAGE PELANGGAN
// ======================================================

class CustomerHistoryScreen extends StatefulWidget {
  final int userId;

  const CustomerHistoryScreen({super.key, required this.userId});

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    _history = await DatabaseHelper().getBookingHistoryByUser(widget.userId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Penyewaan")),
      body: _history.isEmpty
          ? const Center(child: Text("Belum ada riwayat."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (ctx, i) {
                final item = _history[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: ListTile(
                    leading: Image.network(
                      item['carImage'],
                      width: 60,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.car_rental, size: 40),
                    ),
                    title: Text(item['carName']),
                    subtitle: Text(
                      "${item['startDate']} - ${item['endDate']}\nTotal: ${formatRupiah(item['totalPayment'])}",
                    ),
                    trailing: Text(
                      item['status'],
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
    );
  }
}

// ======================================================
//                   FORMAT RUPIAH
// ======================================================

String formatRupiah(num number) {
  final format = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return format.format(number);
}
