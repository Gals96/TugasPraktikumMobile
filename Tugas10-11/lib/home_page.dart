import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Center(
            child: Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(height: 20),

          // MENU 1
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profil'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),

          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Keluar'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}
