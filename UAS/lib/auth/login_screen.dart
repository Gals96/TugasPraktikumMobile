import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/database_helper.dart';
import 'register_screen.dart';
import '../admin/admin_main.dart'; // Import Dashboard Admin
import '../customer/customer_main.dart'; // Import Dashboard Customer

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Masukkan email dan password")));
      return;
    }

    setState(() => _isLoading = true);
    var user = await DatabaseHelper().loginUser(_emailCtrl.text, _passCtrl.text);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (user != null) {
      String role = user['role'];
      int userId = user['id'];
      String userName = user['name'];

      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => role == 'admin'
            ? const AdminHomeScreen()
            : CustomerHomeScreen(userName: userName, userId: userId),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Akun tidak ditemukan atau email/password salah")));
    }
  }

  // Widget Input sama persis dengan kode asli
  Widget _input(String label, TextEditingController ctrl, {bool obscure = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
      Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
        child: TextField(controller: ctrl, obscureText: obscure, decoration: const InputDecoration(border: InputBorder.none)),
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.directions_car, size: 60),
                Text("Rentalku", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                _input("EMAIL", _emailCtrl),
                _input("PASSWORD", _passCtrl, obscure: true),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                  child: const Text("LOGIN"),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text("Belum punya akun? Daftar disini"),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}