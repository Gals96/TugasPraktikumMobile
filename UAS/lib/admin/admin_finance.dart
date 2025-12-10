import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../utils.dart'; // Helper

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
      selesai = selesai.where((e) {
        DateTime d = DateFormat('dd MMM yyyy').parse(e['startDate']);
        return d.day == now.day && d.month == now.month && d.year == now.year;
      }).toList();
    } else if (tab.index == 1) {
      selesai = selesai.where((e) {
        DateTime d = DateFormat('dd MMM yyyy').parse(e['startDate']);
        return d.difference(now).inDays.abs() <= 7;
      }).toList();
    } else if (tab.index == 2) {
      selesai = selesai.where((e) {
        DateTime d = DateFormat('dd MMM yyyy').parse(e['startDate']);
        return d.month == now.month && d.year == now.year;
      }).toList();
    } else {
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
            tabs: const [Tab(text: "Harian"), Tab(text: "Mingguan"), Tab(text: "Bulanan"), Tab(text: "Tahunan")],
          ),
        ),
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
              }),
            ],
          ),
        ),
      ],
    );
  }
}