import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import 'admin_cars.dart';
import 'admin_history.dart';
import 'admin_finance.dart';

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
    const AdminCarsScreen(),
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
      floatingActionButton: _index == 2
          ? FloatingActionButton.extended(
              backgroundColor: Colors.black,
              label: const Text("Tambah Mobil", style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCarScreen()));
                setState(() {});
              },
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Colors.black,
        onTap: (v) => setState(() => _index = v),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Manajemen"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Keuangan"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Mobil"),
        ],
      ),
    );
  }
}