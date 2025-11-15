//main latihan 1
import 'package:flutter/material.dart';
import 'kucing.dart';
import 'hewan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    Kucing kucing1 = Kucing('Ahmad', 4.5, 'Coklat Susu');
    Kucing kucing2 = Kucing('Oyen', 3.5, 'Oren');
    Kucing kucing3 = Kucing('Miko', 5.7, 'Hitam Putih');

    String pesan1 = kucing1.makan(kucing1, 200);
    String pesan2 = kucing2.makan(kucing2, 150);
    String pesan3 = kucing3.makan(kucing3, 210);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Latihan Kucing'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pesan1, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text(pesan2, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text(pesan3, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
