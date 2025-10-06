import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTS - Daftar Berita',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});
  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const NewsPage(),
    const AddNewsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Berita'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Tambah'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});
  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<Map<String, String>> _berita = [];

  @override
  void initState() {
    super.initState();
    _loadBerita();
  }

  Future<void> _loadBerita() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('daftar_berita');
    if (data != null) {
      setState(() {
        _berita = data.map((e) {
          final m = jsonDecode(e) as Map<String, dynamic>;
          return m.map((k, v) => MapEntry(k, v.toString()));
        }).toList();
      });
    } else {
      setState(() {
        _berita = [
          {
            "judul": "Berita A",
            "deskripsi": "Manusia Super Beraksi",
            "gambar": "https://img.antaranews.com/cache/1200x800/2016/08/20160803presiden.jpg.webp"
          },
          {
            "judul": "Berita B",
            "deskripsi": "Penjual Tahu Bakso yang Sukses",
            "gambar": "https://static.promediateknologi.id/crop/0x0:0x0/0x0/webp/photo/p2/132/2025/09/03/Untitled-1846000588.jpg"
          },
        ];
      });
    }
  }

  Future<void> _refresh() async => await _loadBerita();

  Future<void> _hapusBerita(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('daftar_berita') ?? [];
    if (index < data.length) {
      data.removeAt(index);
      await prefs.setStringList('daftar_berita', data);
    }
    await _loadBerita();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berita berhasil dihapus')),
      );
    }
  }

  void _konfirmasiHapus(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Berita"),
        content: const Text("Apakah Anda yakin ingin menghapus berita ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _hapusBerita(index);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Berita')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            itemCount: _berita.length,
            itemBuilder: (context, index) {
              final item = _berita[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Image.network(
                    item['gambar'] ?? '',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item['judul'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['deskripsi'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bookmark_border),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _konfirmasiHapus(index),
                      ),
                    ],
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Mengalihkan ke halaman berita')),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AddNewsPage extends StatefulWidget {
  const AddNewsPage({super.key});
  @override
  State<AddNewsPage> createState() => _AddNewsPageState();
}

class _AddNewsPageState extends State<AddNewsPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _gambarController = TextEditingController();

  Future<void> _saveBerita() async {
    if (!_formKey.currentState!.validate()) return;

    final newItem = {
      "judul": _judulController.text.trim(),
      "deskripsi": _deskripsiController.text.trim(),
      "gambar": _gambarController.text.trim(),
    };

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('daftar_berita') ?? <String>[];
    list.insert(0, jsonEncode(newItem));
    await prefs.setStringList('daftar_berita', list);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berita tersimpan')),
      );
      Navigator.pop(context);
    }
  }

  String? _validateNotEmpty(String? v) {
    if (v == null || v.trim().isEmpty) return 'Tidak boleh kosong';
    return null;
  }

  String? _validateImageUrl(String? v) {
    if (v == null || v.trim().isEmpty) return 'URL wajib diisi';
    if (!v.startsWith('http')) return 'URL harus diawali http/https';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Berita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: _validateNotEmpty,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: _validateNotEmpty,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _gambarController,
                decoration: const InputDecoration(labelText: 'URL Gambar'),
                validator: _validateImageUrl,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBerita,
                child: const Text('Simpan Berita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage("assets/images/profil.png"),
            ),
            SizedBox(height: 20),
            Text(
              "Galih Yusuf Ghifari",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("2310631250059@student.unsika.ac.id"),
          ],
        ),
      ),
    );
  }
}
