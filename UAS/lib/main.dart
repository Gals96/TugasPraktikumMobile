import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screen/auth_screens.dart';

void main() {
  runApp(const RentalkuApp());
}

class RentalkuApp extends StatelessWidget {
  const RentalkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rentalku',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(), // Set Font Global
      ),
      home: const LoginScreen(),
    );
  }
}