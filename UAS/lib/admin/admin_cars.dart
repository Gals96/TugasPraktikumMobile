import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../utils.dart'; // Import formatRupiah & carImageWidget

class AdminCarsScreen extends StatefulWidget {
  const AdminCarsScreen({super.key});
  @override
  State<AdminCarsScreen> createState() => _AdminCarsScreenState();
}

class _AdminCarsScreenState extends State<AdminCarsScreen> {
  List<Map<String, dynamic>> _cars = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCars();
    _searchCtrl.addListener(loadCars);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> loadCars() async {
    final q = _searchCtrl.text;
    _cars = await DatabaseHelper().getCars(query: q.isEmpty ? null : q);
    setState(() {});
  }

  Future<void> _deleteCar(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete('cars', where: 'id = ?', whereArgs: [id]);
    loadCars();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadCars,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari mobil...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: _cars.isEmpty
                ? const Center(child: Text('Tidak ada mobil'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _cars.length,
                    itemBuilder: (c, i) {
                      final car = _cars[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: carImageWidget(car['imageUrl'], width: 64, height: 64),
                          title: Text(car['name'] ?? '-'),
                          subtitle: Text('${car['brand'] ?? '-'} • ${formatRupiah(car['price'] ?? 0)}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'hapus') {
                                final ok = await showDialog<bool?>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus Mobil'),
                                    content: const Text('Yakin ingin menghapus mobil ini?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await _deleteCar(car['id'] as int);
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mobil dihapus')));
                                }
                              } else if (v == 'edit') {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => AddCarScreen(car: car)));
                                loadCars();
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'hapus', child: Text('Hapus')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AddCarScreen extends StatefulWidget {
  final Map<String, dynamic>? car;
  const AddCarScreen({super.key, this.car});
  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _picker = ImagePicker();
  File? _imageFile;
  String? _initialImageUrl;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _brand = TextEditingController();
  final TextEditingController _price = TextEditingController();
  String _transmission = "Matic";

  bool get isEdit => widget.car != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final car = widget.car!;
      _name.text = car['name'] ?? '';
      _brand.text = car['brand'] ?? '';
      _price.text = (car['price'] ?? '').toString();
      _transmission = car['transmission'] ?? _transmission;
      _initialImageUrl = car['imageUrl'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _initialImageUrl = null;
      });
    }
  }

  void _saveCar() async {
    if (_name.text.isEmpty || _price.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nama dan Harga wajib diisi")));
      return;
    }
    final data = {
      'name': _name.text,
      'brand': _brand.text,
      'price': int.tryParse(_price.text) ?? 0,
      'imageUrl': _imageFile?.path ?? _initialImageUrl ?? "",
      'seatCount': 4,
      'transmission': _transmission,
      'year': "2024",
      'rating': 5.0,
      'status': "Available",
    };

    if (isEdit) {
      await DatabaseHelper().updateCar(widget.car!['id'] as int, data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mobil Berhasil Diperbarui")));
        Navigator.pop(context);
      }
      return;
    }

    await DatabaseHelper().addCar(data);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mobil Berhasil Ditambahkan")));
      Navigator.pop(context);
    }
  }

  Widget _input(String title, TextEditingController ctrl, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: title, border: const OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Mobil" : "Tambah Mobil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
              child: _imageFile != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_imageFile!, fit: BoxFit.cover))
                  : (_initialImageUrl == null || _initialImageUrl!.isEmpty)
                      ? const Center(child: Text("Tidak Ada Foto"))
                      : carImageWidget(_initialImageUrl, width: double.infinity, height: 180),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text("Pilih dari Galeri"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            _input("Nama Mobil", _name),
            _input("Merek", _brand),
            _input("Harga Sewa / Hari", _price, number: true),
            DropdownButtonFormField(
              value: _transmission,
              items: ["Matic", "Manual"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _transmission = v!),
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Transmisi"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: _saveCar,
                child: const Text("SIMPAN", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}