import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../utils.dart'; // Helper

class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});
  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  List<Map<String, dynamic>> _trx = [];
  List<Map<String, dynamic>> _filteredTrx = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTrx();
    _searchCtrl.addListener(_filterTrx);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> loadTrx() async {
    _trx = await DatabaseHelper().getAllTransactionsWithUsers();
    _filterTrx();
  }

  void _filterTrx() {
    final query = _searchCtrl.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredTrx = _trx);
      return;
    }
    _filteredTrx = _trx.where((item) {
      final carName = (item['carName'] ?? "").toLowerCase();
      final userName = (item['userName'] ?? "").toLowerCase();
      final startDate = (item['startDate'] ?? "").toLowerCase();
      return carName.contains(query) || userName.contains(query) || startDate.contains(query);
    }).toList();
    setState(() {});
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    await DatabaseHelper().updateTransactionStatus(id, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status diubah menjadi: $newStatus")));
    loadTrx();
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await showDialog<bool?>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: const Text('Yakin ingin menghapus pesanan ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper().deleteTransaction(id);
      loadTrx();
    }
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
    if (_trx.isEmpty) return const Center(child: Text("Belum ada transaksi"));
    return RefreshIndicator(
      onRefresh: loadTrx,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(30)),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Cari nama pelanggan, mobil, atau bulan sewa...",
                  icon: Padding(padding: EdgeInsets.only(left: 12), child: Icon(Icons.search)),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredTrx.isEmpty
                ? const Center(child: Text("Tidak ada hasil pencarian"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredTrx.length,
                    itemBuilder: (c, i) {
                      final t = _filteredTrx[i];
                      final statusLower = (t['status'] ?? "").toLowerCase();
                      final isDikonfirmasi = statusLower == "dikonfirmasi";
                      final isSelesai = statusLower == "selesai";
                      final isDitolak = statusLower == "ditolak";

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  carImageWidget(t['carImage'], width: 60, height: 60, fit: BoxFit.contain),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(t['carName'] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text("Pelanggan: ${t['userName'] ?? '-'}"),
                                        Text("${t['startDate']} - ${t['endDate']}"),
                                        Text("Total: ${formatRupiah(t['totalPayment'])}"),
                                      ],
                                    ),
                                  ),
                                  IconButton(onPressed: () => _confirmDelete(t['id']), icon: const Icon(Icons.delete, color: Colors.red)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (!isSelesai && !isDitolak) ...[
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: _getStatusColor(t['status']), borderRadius: BorderRadius.circular(8)),
                                    child: Text(t['status'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              if (statusLower == "menunggu konfirmasi")
                                Row(
                                  children: [
                                    Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], foregroundColor: Colors.white), onPressed: () => _updateStatus(t['id'], "Dikonfirmasi"), child: const Text("Konfirmasi"))),
                                    const SizedBox(width: 8),
                                    Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600], foregroundColor: Colors.white), onPressed: () => _updateStatus(t['id'], "Ditolak"), child: const Text("Tolak"))),
                                  ],
                                )
                              else if (isDikonfirmasi)
                                SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], foregroundColor: Colors.white), onPressed: () => _updateStatus(t['id'], "Selesai"), child: const Text("Tandai Selesai"))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}