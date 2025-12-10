import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'customer';
  bool _isLoading = false;

  void _register() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }
    setState(() => _isLoading = true);
    int res = await DatabaseHelper().registerUser(_nameCtrl.text, _emailCtrl.text, _passCtrl.text, _role);
    setState(() => _isLoading = false);
    
    if (mounted) {
      if (res == -1) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email sudah terdaftar!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil! Silakan Login.")));
        Navigator.pop(context);
      }
    }
  }

  Widget _input(String label, TextEditingController ctrl, {bool obscure = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        Container(
          margin: const EdgeInsets.only(top: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextField(controller: ctrl, obscureText: obscure, decoration: const InputDecoration(border: InputBorder.none)),
        )
      ],
    ),
  );

  Widget _roleBtn(String label, String val) => GestureDetector(
    onTap: () => setState(() => _role = val),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: _role == val ? Colors.black : Colors.white, border: Border.all(), borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(color: _role == val ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const BackButton(),
            Text("Buat Akun", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _input("NAMA", _nameCtrl),
            _input("EMAIL", _emailCtrl),
            _input("PASSWORD", _passCtrl, obscure: true),
            const SizedBox(height: 15),
            Text("Daftar Sebagai:", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: _roleBtn("Pelanggan", "customer")),
                const SizedBox(width: 10),
                Expanded(child: _roleBtn("Pemilik Rental", "admin")),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
              child: _isLoading ? const CircularProgressIndicator() : const Text("DAFTAR"),
            )
          ],
        ),
      ),
    );
  }
}