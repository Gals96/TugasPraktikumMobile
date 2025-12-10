import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../utils.dart'; // Helper

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

  void _pickDateRange() async {
    final picked = await showDateRangePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2026));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih tanggal dulu!")));
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
      'status': 'Menunggu Konfirmasi',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Booking berhasil! Menunggu admin.")));
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
            carImageWidget(widget.car['imageUrl'], width: double.infinity, height: 200, fit: BoxFit.contain),
            const SizedBox(height: 20),
            Text("Harga Sewa: ${formatRupiah(widget.car['price'])} / hari", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 20),
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
                    Text(
                      _selectedDateRange == null
                          ? "Klik untuk pilih tanggal"
                          : "${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)} ($_totalDays Hari)",
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
                const Text("Total Pembayaran:", style: TextStyle(fontSize: 16)),
                Text(formatRupiah(_totalPrice), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                onPressed: _submitBooking,
                child: const Text("KONFIRMASI BOOKING"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}