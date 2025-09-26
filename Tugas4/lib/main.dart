import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Halaman formulir',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const FormMahasiswaPage(),
      );
}

class FormMahasiswaPage extends StatefulWidget {
  const FormMahasiswaPage({super.key});

  @override
  State<FormMahasiswaPage> createState() => _FormMahasiswaPageState();
}

class _FormMahasiswaPageState extends State<FormMahasiswaPage> {
  final _formKey = GlobalKey<FormState>();
  final cNama = TextEditingController();
  final cNpm = TextEditingController();
  final cEmail = TextEditingController();
  final cAlamat = TextEditingController();
  final cHp = TextEditingController();

  String? gender; // Jenis kelamin
  DateTime? tglLahir;
  TimeOfDay? jamBimbingan;

  String get tglLahirLabel => tglLahir == null
      ? 'Pilih Tanggal Lahir'
      : '${tglLahir!.day}/${tglLahir!.month}/${tglLahir!.year}';
  String get jamLabel => jamBimbingan == null
      ? 'Pilih Jam Bimbingan'
      : '${jamBimbingan!.hour}:${jamBimbingan!.minute}';

  @override
  void dispose() {
    cNama.dispose();
    cNpm.dispose();
    cEmail.dispose();
    cAlamat.dispose();
    cHp.dispose();
    super.dispose();
  }

  Future<void> pilihTglLahir() async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (tanggal != null) {
      setState(() {
        tglLahir = tanggal;
      });
    }
  }

  Future<void> pilihJamBimbingan() async {
    final jam = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (jam != null) {
      setState(() {
        jamBimbingan = jam;
      });
    }
  }

  void saveForm() {
    if (!_formKey.currentState!.validate() ||
        tglLahir == null ||
        jamBimbingan == null ||
        gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data belum lengkap')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ringkasan Data'),
        content: Text(
          'Nama: ${cNama.text}\n'
          'NPM: ${cNpm.text}\n'
          'Email: ${cEmail.text}\n'
          'No HP: ${cHp.text}\n'
          'Jenis Kelamin: $gender\n'
          'Alamat: ${cAlamat.text}\n'
          'Tanggal Lahir: $tglLahirLabel\n'
          'Jam Bimbingan: $jamLabel\n',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Formulir Mahasiswa')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: cNama,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    icon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Nama harus diisi' : null,
                ),
                TextFormField(
                  controller: cNpm,
                  decoration: const InputDecoration(
                    labelText: 'NPM',
                    icon: Icon(Icons.confirmation_number),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'NPM harus diisi' : null,
                ),
                TextFormField(
                  controller: cEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    icon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email harus diisi';
                    }
                    if (!value.endsWith('@unsika.ac.id')) {
                      return 'Email harus menggunakan domain @unsika.ac.id';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: cHp,
                  decoration: const InputDecoration(
                    labelText: 'No HP',
                    icon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor HP harus diisi';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Nomor HP hanya boleh angka';
                    }
                    if (value.length < 10) {
                      return 'Nomor HP minimal 10 digit';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Jenis Kelamin',
                    icon: Icon(Icons.people),
                  ),
                  initialValue: gender,
                  items: const [
                    DropdownMenuItem(
                        value: 'Laki-laki', child: Text('Laki-laki')),
                    DropdownMenuItem(
                        value: 'Perempuan', child: Text('Perempuan')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Jenis kelamin harus dipilih' : null,
                ),
                TextFormField(
                  controller: cAlamat,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    icon: Icon(Icons.home),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Alamat harus diisi' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: pilihTglLahir,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(tglLahirLabel),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: pilihJamBimbingan,
                  icon: const Icon(Icons.access_time),
                  label: Text(jamLabel),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: saveForm,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      );
}
