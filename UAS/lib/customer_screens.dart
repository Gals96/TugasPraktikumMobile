import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'database_helper.dart';
import 'auth_screens.dart'; // Untuk logout

class CustomerHomeScreen extends StatefulWidget {
  final String userName;
  final int userId; // Butuh ID user untuk booking
  const CustomerHomeScreen({super.key, required this.userName, required this.userId});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  List<Map<String, dynamic>> _cars = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshCars(); // Load data awal
  }

  // Fungsi Fetch Data Mobil
  void _refreshCars({String? query}) async {
    final data = await DatabaseHelper().getCars(query: query);
    setState(() {
      _cars = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hai, ${widget.userName}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("Mau sewa mobil apa?", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FITUR PENCARIAN (SEARCH)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(30)),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (value) => _refreshCars(query: value), // Panggil fungsi cari saat mengetik
                decoration: const InputDecoration(border: InputBorder.none, hintText: "Cari mobil (ex: Yaris)...", icon: Icon(Icons.search)),
              ),
            ),
            const SizedBox(height: 20),
            
            // LIST MOBIL DARI DATABASE
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
                          Image.network(car['imageUrl'], height: 120, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.car_rental, size: 80)),
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
                                onPressed: () {
                                  // Ke Halaman Detail & Booking
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => DetailBookingScreen(car: car, userId: widget.userId)));
                                },
                                child: const Text("Sewa"),
                              )
                            ],
                          )
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

// --- SCREEN DETAIL & BOOKING FORM ---
class DetailBookingScreen extends StatefulWidget {
  final Map<String, dynamic> car;
  final int userId;
  const DetailBookingScreen({super.key, required this.car, required this.userId});

  @override
  State<DetailBookingScreen> createState() => _DetailBookingScreenState();
}

class _DetailBookingScreenState extends State<DetailBookingScreen> {
  DateTimeRange? _selectedDateRange;
  int _totalDays = 0;
  int _totalPrice = 0;

  // Fungsi Pilih Tanggal
  void _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(data: ThemeData.light().copyWith(primaryColor: Colors.black, colorScheme: const ColorScheme.light(primary: Colors.black)), child: child!);
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _totalDays = picked.end.difference(picked.start).inDays;
        if (_totalDays == 0) _totalDays = 1; // Minimal 1 hari
        _totalPrice = _totalDays * (widget.car['price'] as int);
      });
    }
  }

  // Fungsi Simpan Booking ke Database
  void _submitBooking() async {
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih tanggal sewa dulu!")));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Booking Berhasil! Menunggu Admin.")));
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
            Image.network(widget.car['imageUrl'], height: 200, width: double.infinity, fit: BoxFit.contain),
            const SizedBox(height: 20),
            Text("Harga Sewa: ${formatRupiah(widget.car['price'])} / hari", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 20),
            
            // FITUR PEMILIHAN TANGGAL
            Text("Pilih Tanggal Sewa", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDateRange,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 10),
                    Text(_selectedDateRange == null 
                      ? "Klik untuk pilih tanggal" 
                      : "${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)} ($_totalDays Hari)")
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            
            // Rincian Pembayaran
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Pembayaran:", style: TextStyle(fontSize: 16)),
                Text(formatRupiah(_totalPrice), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
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