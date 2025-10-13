import 'package:flutter/material.dart';

class HasilPage extends StatelessWidget {
  final String nama;
  final String npm;
  final String email;
  final String hp;
  final String alamat;
  final String gender;
  final String tglLahir;
  final String jamBimbingan;

  const HasilPage({
    super.key,
    required this.nama,
    required this.npm,
    required this.email,
    required this.hp,
    required this.alamat,
    required this.gender,
    required this.tglLahir,
    required this.jamBimbingan,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Hasil Data Mahasiswa')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama: $nama', style: const TextStyle(fontSize: 16)),
                  Text('NPM: $npm', style: const TextStyle(fontSize: 16)),
                  Text('Email: $email', style: const TextStyle(fontSize: 16)),
                  Text('No HP: $hp', style: const TextStyle(fontSize: 16)),
                  Text('Jenis Kelamin: $gender',
                      style: const TextStyle(fontSize: 16)),
                  Text('Alamat: $alamat', style: const TextStyle(fontSize: 16)),
                  Text('Tanggal Lahir: $tglLahir',
                      style: const TextStyle(fontSize: 16)),
                  Text('Jam Bimbingan: $jamBimbingan',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Kembali ke Form'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
