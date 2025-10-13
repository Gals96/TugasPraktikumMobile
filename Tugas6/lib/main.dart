import 'package:flutter/material.dart';
import 'form_mahasiswa_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Formulir Mahasiswa',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const FormMahasiswaPage(),
      );
}
