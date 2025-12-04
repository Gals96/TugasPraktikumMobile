import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_helper.dart';
import 'auth_screens.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _idx = 0;
  final List<Widget> _pages = [const AdminHistoryScreen(), const Center(child: Text("Menu Pencairan"))];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())))
        ],
      ),
      body: _pages[_idx],
      // Tombol Tambah Mobil (Hanya muncul di tab Riwayat/Home)
      floatingActionButton: _idx == 0 
        ? FloatingActionButton.extended(
            backgroundColor: Colors.black,
            onPressed: () async {
               await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarScreen()));
               setState(() {}); // Refresh halaman setelah tambah mobil
            }, 
            label: const Text("Tambah Mobil", style: TextStyle(color: Colors.white)),
            icon: const Icon(Icons.add, color: Colors.white),
          )
        : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (v) => setState(() => _idx = v),
        selectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.car_rental), label: "Manajemen"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Keuangan"),
        ],
      ),
    );
  }
}

// --- SCREEN TAMBAH MOBIL (ADMIN) ---
class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});
  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imgCtrl = TextEditingController(); // Input URL Gambar
  
  void _saveCar() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;
    
    await DatabaseHelper().addCar({
      'name': _nameCtrl.text,
      'brand': _brandCtrl.text,
      'price': int.parse(_priceCtrl.text),
      'imageUrl': _imgCtrl.text.isEmpty 
          ? 'https://cdn-icons-png.flaticon.com/512/3202/3202926.png' // Default image
          : _imgCtrl.text,
      'seatCount': 4,
      'transmission': 'Matic',
      'year': '2024',
      'rating': 5.0,
      'status': 'Available'
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mobil Berhasil Ditambahkan!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Mobil Baru")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _input("Nama Mobil (ex: Avanza)", _nameCtrl),
            _input("Merek (ex: Toyota)", _brandCtrl),
            _input("Harga Sewa per Hari (Angka)", _priceCtrl, isNumber: true),
            _input("URL Gambar (Link Internet)", _imgCtrl),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                onPressed: _saveCar,
                child: const Text("SIMPAN MOBIL"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}

// --- SCREEN RIWAYAT & KONFIRMASI (ADMIN) ---
class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTrx();
  }

  void _loadTrx() async {
    final data = await DatabaseHelper().getAllTransactions();
    setState(() => _transactions = data);
  }

  void _updateStatus(int id) async {
    await DatabaseHelper().updateTransactionStatus(id, "Selesai");
    _loadTrx(); // Reload data
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status diperbarui menjadi Selesai")));
  }

  @override
  Widget build(BuildContext context) {
    if (_transactions.isEmpty) return const Center(child: Text("Belum ada penyewaan masuk"));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (ctx, i) {
        final trx = _transactions[i];
        bool isCompleted = trx['status'] == 'Selesai';

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.network(trx['carImage'], width: 60, height: 40, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.car_rental)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trx['carName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("${trx['startDate']} - ${trx['endDate']}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          Text("Total: ${formatRupiah(trx['totalPayment'])}", style: const TextStyle(fontSize: 12, color: Colors.blue)),
                        ],
                      ),
                    ),
                    // Badge Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green[100] : Colors.orange[100],
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(trx['status'], style: TextStyle(fontSize: 10, color: isCompleted ? Colors.green : Colors.deepOrange)),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                // Tombol Konfirmasi (Hanya jika belum selesai)
                if (!isCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(trx['id']),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text("Konfirmasi Selesai Sewa"),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}