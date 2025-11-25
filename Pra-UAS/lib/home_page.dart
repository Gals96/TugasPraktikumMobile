import 'package:flutter/material.dart';
import 'data_pengguna.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DataPengguna dataPengguna = DataPengguna();
  late Future<List<dynamic>> users;

  @override
  void initState() {
    super.initState();
    users = dataPengguna.fetchUsers();
  }

  void _refreshData() {
    setState(() {
      users = dataPengguna.fetchUsers();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Pengguna"),
        actions: [
          IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data ?? [];

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final u = data[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(u['name']),
                  subtitle: Text(
                      "Email: ${u['email']}\nKota: ${u['address']['city']}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}