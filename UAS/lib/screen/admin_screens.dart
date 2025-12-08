// lib/screens/admin_screens.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import 'auth_screens.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  final List<Widget> _pages = [
    const AdminHistoryScreen(),
    const AdminFinanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _pages[_index],
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              backgroundColor: Colors.black,
              label: const Text("Tambah Mobil", style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCarScreen()),
                );
                setState(() {});
              },
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Colors.black,
        onTap: (v) => setState(() => _index = v),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.car_rental), label: "Manajemen"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Keuangan"),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
///                        ADD CAR – HANYA GALERI
///////////////////////////////////////////////////////////////////////////////

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});
  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _picker = ImagePicker();
  File? _imageFile;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _brand = TextEditingController();
  final TextEditingController _price = TextEditingController();
  String _transmission = "Matic";

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _saveCar() async {
    if (_name.text.isEmpty || _price.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan Harga wajib diisi")),
      );
      return;
    }

    await DatabaseHelper().addCar({
      'name': _name.text,
      'brand': _brand.text,
      'price': int.tryParse(_price.text) ?? 0,
      'imageUrl': _imageFile?.path ?? "",
      'seatCount': 4,
      'transmission': _transmission,
      'year': "2024",
      'rating': 5.0,
      'status': "Available",
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mobil Berhasil Ditambahkan")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Mobil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _imageFile == null
                  ? const Center(child: Text("Tidak Ada Foto"))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text("Pilih dari Galeri"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              ),
            ),

            const SizedBox(height: 20),

            _input("Nama Mobil", _name),
            _input("Merek", _brand),
            _input("Harga Sewa / Hari", _price, number: true),

            DropdownButtonFormField(
              value: _transmission,
              items: ["Matic", "Manual"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _transmission = v!),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Transmisi",
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: _saveCar,
                child: const Text("SIMPAN", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String title, TextEditingController ctrl, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
///                 ADMIN – RIWAYAT TRANSAKSI
///////////////////////////////////////////////////////////////////////////////

class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});
  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  List<Map<String, dynamic>> _trx = [];

  @override
  void initState() {
    super.initState();
    loadTrx();
  }

  Future<void> loadTrx() async {
    _trx = await DatabaseHelper().getAllTransactionsWithUsers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_trx.isEmpty) return const Center(child: Text("Belum ada transaksi"));

    return RefreshIndicator(
      onRefresh: loadTrx,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _trx.length,
        itemBuilder: (c, i) {
          final t = _trx[i];
          final selesai = (t['status'] ?? "").toLowerCase() == "selesai";

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _carImage(t['carImage']),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['carName'] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Pelanggan: ${t['userName']}"),
                        Text("${t['startDate']} - ${t['endDate']}"),
                        Text("Total: ${formatRupiah(t['totalPayment'])}"),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selesai ? Colors.green[200] : Colors.orange[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(t['status']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _carImage(String? img) {
    if (img == null || img.isEmpty) {
      return const Icon(Icons.car_rental, size: 60);
    }
    if (File(img).existsSync()) {
      return Image.file(File(img), width: 80, height: 60, fit: BoxFit.cover);
    }
    return Image.network(img, width: 80, height: 60, fit: BoxFit.cover);
  }
}

String formatRupiah(int n) => NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(n);

///////////////////////////////////////////////////////////////////////////////
///                         MENU KEUANGAN BARU
///     TANPA CHART — HANYA LAPORAN HARI, MINGGU, BULAN, TAHUN
///////////////////////////////////////////////////////////////////////////////

class AdminFinanceScreen extends StatefulWidget {
  const AdminFinanceScreen({super.key});
  @override
  State<AdminFinanceScreen> createState() => _AdminFinanceScreenState();
}

class _AdminFinanceScreenState extends State<AdminFinanceScreen> with SingleTickerProviderStateMixin {
  late TabController tab;
  List<Map<String, dynamic>> _data = [];
  int total = 0;

  @override
  void initState() {
    super.initState();
    tab = TabController(length: 4, vsync: this);
    loadData();
    tab.addListener(() {
      if (!tab.indexIsChanging) computeReport();
    });
  }

  Future<void> loadData() async {
    _data = await DatabaseHelper().getAllTransactionsWithUsers();
    computeReport();
  }

  void computeReport() {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> selesai = _data.where((e) => (e['status'] ?? "").toLowerCase() == "selesai").toList();

    if (tab.index == 0) {
      // HARI – hari ini
      selesai = selesai.where((e) {
        DateTime d = DateFormat('dd MMM yyyy').parse(e['startDate']);
        return d.day == now.day && d.month == now.month && d.year == now.year;
      }).toList();
    } else if (tab.index == 1) {
      // MINGGU
      selesai = selesai.where((e) {
        DateTime d = DateFormat('dd MMM yyyy').parse(e['startDate']);
        return d.difference(now).inDays.abs() <= 7;
      }).toList();
    } else if (tab.index == 2) {
      // BULAN
      selesai = selesai.where((e) {
        DateTime d = DateFormat('dd MMM yyyy').parse(e['startDate']);
        return d.month == now.month && d.year == now.year;
      }).toList();
    } else {
      // TAHUN
      selesai = selesai.where((e) {
        DateTime d = DateFormat('dd MMM yyyy').parse(e['startDate']);
        return d.year == now.year;
      }).toList();
    }

    total = selesai.fold(0, (a, b) => a + (b['totalPayment'] as int? ?? 0));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          child: TabBar(
            controller: tab,
            labelColor: Colors.black,
            tabs: const [
              Tab(text: "Harian"),
              Tab(text: "Mingguan"),
              Tab(text: "Bulanan"),
              Tab(text: "Tahunan"),
            ],
          ),
        ),

        // Total Pendapatan
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Pendapatan", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(formatRupiah(total), style: const TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: loadData, icon: const Icon(Icons.refresh)),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Text("Detail Transaksi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              ..._data.map((e) {
                return Card(
                  child: ListTile(
                    title: Text(e['carName']),
                    subtitle: Text("${e['startDate']} - ${e['endDate']}"),
                    trailing: Text(formatRupiah(e['totalPayment'])),
                  ),
                );
              }).toList()
            ],
          ),
        )
      ],
    );
  }
}
